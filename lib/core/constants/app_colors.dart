import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xffa23e28);
  static const Color primaryDark = Color(0xff5f0d00);
  static const Color primarySoft = Color(0xffffdad3);
  static const Color secondary = Color(0xff2e4577);
  static const Color success = Color(0xff16a34a);
  static const Color error = Color(0xffba1a1a);

  // Dynamic Theme Helpers (evitam cores fixas que quebram o modo escuro)
  static Color surface(BuildContext context) => Theme.of(context).colorScheme.surface;
  static Color surfaceContainer(BuildContext context) => Theme.of(context).colorScheme.surfaceContainer;
  static Color surfaceContainerLow(BuildContext context) => Theme.of(context).colorScheme.surfaceContainerLow;
  static Color surfaceContainerHigh(BuildContext context) => Theme.of(context).colorScheme.surfaceContainerHigh;
  static Color textPrimary(BuildContext context) => Theme.of(context).colorScheme.onSurface;
  static Color textSecondary(BuildContext context) => Theme.of(context).colorScheme.onSurfaceVariant;
  static Color border(BuildContext context) => Theme.of(context).colorScheme.outlineVariant;
}
