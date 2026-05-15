import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_manager/features/household_scan/bloc/household_scan_cubit.dart';
import 'package:money_manager/features/household_scan/widgets/household_scan_view.dart';

/// Full-screen QR scanner; pops with a UUID string or null if dismissed.
class HouseholdScanScreen extends StatelessWidget {
  const HouseholdScanScreen({
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
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HouseholdScanCubit(),
      child: HouseholdScanView(
        appBarTitle: appBarTitle,
        scannerHint: scannerHint,
        webLeadParagraph: webLeadParagraph,
        pasteSheetTitle: pasteSheetTitle,
        pasteFieldLabel: pasteFieldLabel,
      ),
    );
  }
}
