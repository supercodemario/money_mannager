import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money_manager/share/share.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Shows a QR encoding [householdId] for an existing household (share / list row).
Future<void> showHouseholdQrShareDialog(
  BuildContext context, {
  required String householdId,
  required String householdName,
}) async {
  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text(AppStrings.familyShareHouseholdQrTitle),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                householdName,
                style: Theme.of(ctx).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: AppSpacing.s8),
              Text(
                AppStrings.familyShareHouseholdQrBody,
                style: Theme.of(ctx).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.s16),
              Center(
                child: QrImageView(
                  data: householdId,
                  version: QrVersions.auto,
                  size: 200,
                ),
              ),
              const SizedBox(height: AppSpacing.s12),
              SelectableText(householdId),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: householdId));
            if (!ctx.mounted) return;
            Navigator.pop(ctx);
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text(AppStrings.familyShareHouseholdCopied)),
            );
          },
          child: const Text(AppStrings.familyShareHouseholdCopyId),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text(AppStrings.commonDone),
        ),
      ],
    ),
  );
}
