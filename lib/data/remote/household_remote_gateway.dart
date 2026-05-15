import 'package:money_manager/core/logging/app_log.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Remote reads + invite RPC for [household_members] (Supabase).
class HouseholdRemoteGateway {
  HouseholdRemoteGateway();

  Future<String?> ensurePersonalHousehold() async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return null;
    try {
      final raw = await Supabase.instance.client.rpc<dynamic>(
        'ensure_personal_household',
      );
      if (raw == null) return null;
      final id = '$raw'.trim();
      return id.isEmpty ? null : id;
    } catch (e, st) {
      logAppError('household.ensure_personal', e, st);
      return null;
    }
  }

  /// All households the signed-in user belongs to (via [household_members]).
  Future<List<HouseholdSummaryRow>> fetchHouseholdsForCurrentUser() async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return [];

    final raw = await Supabase.instance.client
        .from('household_members')
        .select('household_id, role')
        .eq('user_id', uid)
        .order('household_id');
    final list = raw as List<dynamic>;
    if (list.isEmpty) return [];

    final roleByHousehold = <String, String>{};
    for (final e in list) {
      final m = e as Map<String, dynamic>;
      final hid = m['household_id'] as String;
      roleByHousehold[hid] = m['role'] as String;
    }

    final ids = roleByHousehold.keys.toList();
    final hRaw = await Supabase.instance.client
        .from('households')
        .select('id, name, kind')
        .inFilter('id', ids);
    final hList = hRaw as List<dynamic>;
    final nameById = <String, String>{};
    final kindById = <String, HouseholdKind>{};
    for (final e in hList) {
      final m = e as Map<String, dynamic>;
      final n = m['name'] as String?;
      nameById[m['id'] as String] =
          (n != null && n.trim().isNotEmpty) ? n.trim() : 'Household';
      final rawKind = m['kind'] as String?;
      kindById[m['id'] as String] = rawKind == 'personal'
          ? HouseholdKind.personal
          : HouseholdKind.shared;
    }

    return ids
        .map(
          (hid) => HouseholdSummaryRow(
            householdId: hid,
            name: nameById[hid] ?? 'Household',
            myRole: roleByHousehold[hid] ?? 'member',
            kind: kindById[hid] ?? HouseholdKind.shared,
          ),
        )
        .toList();
  }

  /// Rows for the household (same visibility as RLS — members see co-members).
  Future<List<HouseholdMemberRow>> fetchMembers(String householdId) async {
    final raw = await Supabase.instance.client
        .from('household_members')
        .select('user_id, role')
        .eq('household_id', householdId)
        .order('user_id');
    final list = raw as List<dynamic>;
    return list
        .map((e) => HouseholdMemberRow(
              userId: (e as Map<String, dynamic>)['user_id'] as String,
              role: e['role'] as String,
            ))
        .toList();
  }

  Future<bool> currentUserIsOwner(String householdId) async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return false;
    final row = await Supabase.instance.client
        .from('household_members')
        .select('role')
        .eq('household_id', householdId)
        .eq('user_id', uid)
        .maybeSingle();
    if (row == null) return false;
    return (row['role'] as String?) == 'owner';
  }

  Future<bool> isPersonalHousehold(String householdId) async {
    final row = await Supabase.instance.client
        .from('households')
        .select('kind')
        .eq('id', householdId)
        .maybeSingle();
    if (row == null) return false;
    return (row['kind'] as String?) == 'personal';
  }

  Future<AddHouseholdMemberResult> addMemberAsOwner({
    required String householdId,
    required String inviteeAuthUserId,
  }) async {
    try {
      await Supabase.instance.client.rpc<void>(
        'add_household_member_as_owner',
        params: <String, dynamic>{
          'p_household_id': householdId,
          'p_invitee_user_id': inviteeAuthUserId,
        },
      );
      return AddHouseholdMemberResult.success;
    } on PostgrestException catch (e, st) {
      final msg =
          '${e.message} ${e.details ?? ''} ${e.hint ?? ''}'.toLowerCase();
      if (msg.contains('already_member')) return AddHouseholdMemberResult.alreadyMember;
      if (msg.contains('not_owner')) return AddHouseholdMemberResult.notOwner;
      if (msg.contains('not_authenticated')) return AddHouseholdMemberResult.notAuthenticated;
      if (msg.contains('cannot_invite_self')) return AddHouseholdMemberResult.cannotInviteSelf;
      if (msg.contains('personal_household_not_shareable')) {
        return AddHouseholdMemberResult.personalHouseholdNotShareable;
      }
      // household_members.user_id → auth.users: invitee id must be a real auth user.
      if (msg.contains('foreign key') ||
          msg.contains('violates foreign key') ||
          msg.contains('23503') ||
          (msg.contains('not present') && msg.contains('users'))) {
        return AddHouseholdMemberResult.inviteeNotCloudUser;
      }
      logAppError('household.add_member_rpc', e, st);
      return AddHouseholdMemberResult.error;
    } catch (e, st) {
      logAppError('household.add_member_rpc', e, st);
      return AddHouseholdMemberResult.error;
    }
  }

  /// Resolves [households].name when the current user may read that row (member).
  Future<String?> fetchHouseholdDisplayName(String householdId) async {
    final row = await Supabase.instance.client
        .from('households')
        .select('name')
        .eq('id', householdId)
        .maybeSingle();
    if (row == null) return null;
    final n = row['name'] as String?;
    if (n != null && n.trim().isNotEmpty) return n.trim();
    return 'Household';
  }

  /// Inserts the signed-in user as [member] of [householdId] (RLS allows self-insert).
  Future<JoinHouseholdResult> joinHouseholdAsMember(String householdId) async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return JoinHouseholdResult.notAuthenticated;
    if (householdId == uid) {
      return JoinHouseholdResult.selfCodeNotAllowed;
    }
    try {
      await Supabase.instance.client.from('household_members').insert(<String, dynamic>{
        'household_id': householdId,
        'user_id': uid,
        'role': 'member',
      });
      return JoinHouseholdResult.success;
    } on PostgrestException catch (e, st) {
      final msg =
          '${e.message} ${e.details ?? ''} ${e.hint ?? ''}'.toLowerCase();
      if (msg.contains('personal_household_not_shareable') ||
          msg.contains('violates row-level security') ||
          msg.contains('new row violates row-level security')) {
        return JoinHouseholdResult.personalHouseholdNotJoinable;
      }
      if (msg.contains('duplicate') ||
          msg.contains('unique') ||
          msg.contains('already exists')) {
        return JoinHouseholdResult.alreadyMember;
      }
      if (msg.contains('foreign key') ||
          msg.contains('violates foreign key') ||
          msg.contains('23503') ||
          msg.contains('is not present')) {
        return JoinHouseholdResult.invalidHousehold;
      }
      logAppError('household.join_as_member', e, st);
      return JoinHouseholdResult.error;
    } catch (e, st) {
      logAppError('household.join_as_member', e, st);
      return JoinHouseholdResult.error;
    }
  }

  /// Pending invite row for [family_invites] (household not created until [acceptFamilyInvite]).
  Future<FamilyInvitePreview?> fetchFamilyInvitePreview(String inviteHouseholdId) async {
    try {
      final raw = await Supabase.instance.client.rpc<dynamic>(
        'get_family_invite_preview',
        params: <String, dynamic>{'p_household_id': inviteHouseholdId},
      );
      if (raw == null) return null;
      final Map<String, dynamic> m;
      if (raw is Map<String, dynamic>) {
        m = raw;
      } else {
        final list = raw is List<dynamic> ? raw : <dynamic>[raw];
        if (list.isEmpty) return null;
        m = list.first as Map<String, dynamic>;
      }
      final name = m['display_name'] as String?;
      final creator = m['creator_id'] as String?;
      if (name == null || creator == null) return null;
      return FamilyInvitePreview(
        householdId: inviteHouseholdId,
        displayName: name.trim().isEmpty ? 'Household' : name.trim(),
        creatorId: creator,
      );
    } catch (e, st) {
      logAppError('household.fetch_invite_preview', e, st);
      return null;
    }
  }

  Future<void> registerFamilyInvite({
    required String inviteId,
    required String displayName,
  }) async {
    await Supabase.instance.client.rpc<void>(
      'register_family_invite',
      params: <String, dynamic>{
        'p_id': inviteId,
        'p_display_name': displayName,
      },
    );
  }

  Future<void> updateFamilyInviteName({
    required String inviteId,
    required String displayName,
  }) async {
    await Supabase.instance.client.rpc<void>(
      'update_family_invite_name',
      params: <String, dynamic>{
        'p_id': inviteId,
        'p_display_name': displayName,
      },
    );
  }

  Future<void> cancelFamilyInvite(String inviteId) async {
    await Supabase.instance.client.rpc<void>(
      'cancel_family_invite',
      params: <String, dynamic>{'p_id': inviteId},
    );
  }

  Future<AcceptFamilyInviteResult> acceptFamilyInvite(String householdId) async {
    try {
      await Supabase.instance.client.rpc<void>(
        'accept_family_invite',
        params: <String, dynamic>{'p_household_id': householdId},
      );
      return AcceptFamilyInviteResult.success;
    } on PostgrestException catch (e, st) {
      final msg =
          '${e.message} ${e.details ?? ''} ${e.hint ?? ''}'.toLowerCase();
      if (msg.contains('invite_not_found')) return AcceptFamilyInviteResult.inviteNotFound;
      if (msg.contains('cannot_accept_own_invite')) {
        return AcceptFamilyInviteResult.cannotAcceptOwnInvite;
      }
      if (msg.contains('household_exists')) return AcceptFamilyInviteResult.householdExists;
      if (msg.contains('not_authenticated')) return AcceptFamilyInviteResult.notAuthenticated;
      logAppError('household.accept_family_invite', e, st);
      return AcceptFamilyInviteResult.error;
    } catch (e, st) {
      logAppError('household.accept_family_invite', e, st);
      return AcceptFamilyInviteResult.error;
    }
  }
}

class HouseholdMemberRow {
  const HouseholdMemberRow({required this.userId, required this.role});

  final String userId;
  final String role;

  bool get isOwner => role == 'owner';
}

class HouseholdSummaryRow {
  const HouseholdSummaryRow({
    required this.householdId,
    required this.name,
    required this.myRole,
    this.kind = HouseholdKind.shared,
  });

  final String householdId;
  final String name;
  final String myRole;
  final HouseholdKind kind;

  bool get amOwner => myRole == 'owner';
  bool get isPersonal => kind == HouseholdKind.personal;
}

enum AddHouseholdMemberResult {
  success,
  alreadyMember,
  notOwner,
  notAuthenticated,
  cannotInviteSelf,
  personalHouseholdNotShareable,
  /// Insert failed: scanned id is not in auth.users (common when QR used local profile id).
  inviteeNotCloudUser,
  error,
}

enum JoinHouseholdResult {
  success,
  alreadyMember,
  invalidHousehold,
  notAuthenticated,
  /// Scanned id equals [auth.uid] (profile QR), not a household id.
  selfCodeNotAllowed,
  personalHouseholdNotJoinable,
  error,
}

class FamilyInvitePreview {
  const FamilyInvitePreview({
    required this.householdId,
    required this.displayName,
    required this.creatorId,
  });

  final String householdId;
  final String displayName;
  final String creatorId;
}

enum AcceptFamilyInviteResult {
  success,
  inviteNotFound,
  cannotAcceptOwnInvite,
  householdExists,
  notAuthenticated,
  error,
}

enum HouseholdKind { shared, personal }
