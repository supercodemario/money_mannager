import 'package:avatar_plus/avatar_plus.dart';
import 'package:flutter/material.dart';
import 'package:money_manager/share/tokens/app_spacing.dart';

/// Deterministic Multiavatar-style glyph from [userId] (stable across display name changes).
class MemberAvatar extends StatelessWidget {
  const MemberAvatar({
    super.key,
    required this.userId,
    this.size = AppSpacing.s24,
  });

  final String userId;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      key: ValueKey<String>('member_avatar_$userId'),
      child: SizedBox(
        width: size,
        height: size,
        child: AvatarPlus(
          userId,
          width: size,
          height: size,
          fit: BoxFit.cover,
          trBackground: true,
        ),
      ),
    );
  }
}
