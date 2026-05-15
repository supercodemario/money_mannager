import 'package:flutter/material.dart';

/// Opens profile / account UI from composition root so settings does not import the feature view.
abstract class ProfileDetailsNavigation {
  Future<void> pushProfileDetails(BuildContext context);
}
