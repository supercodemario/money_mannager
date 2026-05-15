import 'package:flutter/material.dart';
import 'package:money_manager/share/share.dart';

/// Bottom sheet for pasting a UUID invite / household id (controller owned by route).
class PasteInviteSheet extends StatefulWidget {
  const PasteInviteSheet({
    super.key,
    required this.title,
    required this.fieldLabel,
  });

  final String title;
  final String fieldLabel;

  @override
  State<PasteInviteSheet> createState() => _PasteInviteSheetState();
}

class _PasteInviteSheetState extends State<PasteInviteSheet> {
  late final TextEditingController _field;

  @override
  void initState() {
    super.initState();
    _field = TextEditingController();
  }

  @override
  void dispose() {
    _field.dispose();
    super.dispose();
  }

  void _submit() {
    final uuid = extractFirstCanonicalUuid(_field.text);
    if (uuid == null) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(content: Text(AppStrings.familyScanInvalidCode)),
      );
      return;
    }
    Navigator.of(context).pop<String>(uuid);
  }

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: 24 + inset,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _field,
            decoration: InputDecoration(
              labelText: widget.fieldLabel,
              hintText: AppStrings.familyScanPasteInviteHint,
              border: const OutlineInputBorder(),
            ),
            autofocus: true,
            autocorrect: false,
            keyboardType: TextInputType.visiblePassword,
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _submit,
            child: const Text(AppStrings.familyScanSubmitInvite),
          ),
        ],
      ),
    );
  }
}
