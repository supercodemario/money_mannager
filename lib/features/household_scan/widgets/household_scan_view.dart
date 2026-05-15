import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:money_manager/features/household_scan/widgets/paste_invite_sheet.dart';
import 'package:money_manager/share/share.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Scanner surface (camera / web paste). Parent [HouseholdScanScreen] supplies [BlocProvider].
class HouseholdScanView extends StatefulWidget {
  const HouseholdScanView({
    super.key,
    this.appBarTitle,
    this.scannerHint,
    this.webLeadParagraph,
    this.pasteSheetTitle,
    this.pasteFieldLabel,
  });

  final String? appBarTitle;
  final String? scannerHint;
  final String? webLeadParagraph;
  final String? pasteSheetTitle;
  final String? pasteFieldLabel;

  @override
  State<HouseholdScanView> createState() => _HouseholdScanViewState();
}

class _HouseholdScanViewState extends State<HouseholdScanView> {
  MobileScannerController? _controller;
  TextEditingController? _webPasteController;
  bool _handled = false;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _webPasteController = TextEditingController();
    } else {
      _controller = MobileScannerController(
        formats: const [BarcodeFormat.qrCode],
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _webPasteController?.dispose();
    super.dispose();
  }

  void _popWithUuid(String uuid) {
    if (_handled || !mounted) return;
    _handled = true;
    _controller?.stop();
    Navigator.of(context).pop<String>(uuid);
  }

  void _trySubmitRaw(String raw) {
    final uuid = extractFirstCanonicalUuid(raw);
    if (uuid == null) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(content: Text(AppStrings.familyScanInvalidCode)),
      );
      return;
    }
    _popWithUuid(uuid);
  }

  void _submitWebPaste() {
    _trySubmitRaw(_webPasteController?.text ?? '');
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled || !mounted) return;
    for (final b in capture.barcodes) {
      final raw = b.rawValue ?? b.displayValue;
      final uuid = extractFirstCanonicalUuid(raw);
      if (uuid != null) {
        _popWithUuid(uuid);
        return;
      }
    }
  }

  Future<void> _showPasteSheet() async {
    final uuid = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => PasteInviteSheet(
        title: widget.pasteSheetTitle ?? AppStrings.familyScanEnterInviteManually,
        fieldLabel: widget.pasteFieldLabel ?? AppStrings.familyScanPasteInviteLabel,
      ),
    );
    if (!mounted || uuid == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _popWithUuid(uuid);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.appBarTitle ?? AppStrings.familyScanTitle),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop<String>(null),
        ),
        actions: [
          if (!kIsWeb)
            TextButton(
              onPressed: _handled ? null : _showPasteSheet,
              child: const Text(AppStrings.familyScanEnterInviteManually),
            ),
        ],
      ),
      body: kIsWeb ? _buildWebBody(context) : _buildScannerBody(context),
    );
  }

  Widget _buildWebBody(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.webLeadParagraph ?? AppStrings.familyScanWebUnavailable,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _webPasteController,
              decoration: InputDecoration(
                labelText: widget.pasteFieldLabel ?? AppStrings.familyScanPasteInviteLabel,
                hintText: AppStrings.familyScanPasteInviteHint,
                border: const OutlineInputBorder(),
              ),
              autocorrect: false,
              keyboardType: TextInputType.visiblePassword,
              onSubmitted: (_) => _submitWebPaste(),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _handled ? null : _submitWebPaste,
              child: const Text(AppStrings.familyScanSubmitInvite),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScannerBody(BuildContext context) {
    final c = _controller;
    if (c == null) {
      return const SizedBox.shrink();
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        MobileScanner(
          controller: c,
          onDetect: _onDetect,
          errorBuilder: (context, error) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.videocam_off_outlined,
                      size: 48,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      error.errorDetails?.message ?? AppStrings.familyScanCameraError,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _handled ? null : _showPasteSheet,
                      child: const Text(AppStrings.familyScanEnterInviteManually),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        SafeArea(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Material(
                color: Theme.of(context).colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Text(
                    widget.scannerHint ?? AppStrings.familyScanPointCameraHint,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
