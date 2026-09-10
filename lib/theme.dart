import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff390500),
      surfaceTint: Color(0xffa23e28),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff5f0d00),
      onPrimaryContainer: Color(0xffe97359),
      secondary: Color(0xff000a23),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff001f50),
      onSecondaryContainer: Color(0xff7188bf),
      tertiary: Color(0xff221700),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff3c2b00),
      onTertiaryContainer: Color(0xffac925c),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff93000a),
      surface: Color(0xfffff8f6),
      onSurface: Color(0xff241917),
      onSurfaceVariant: Color(0xff57423d),
      outline: Color(0xff8a726c),
      outlineVariant: Color(0xffddc0ba),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff3a2e2b),
      inversePrimary: Color(0xffffb4a4),
      primaryFixed: Color(0xffffdad3),
      onPrimaryFixed: Color(0xff3d0600),
      primaryFixedDim: Color(0xffffb4a4),
      onPrimaryFixedVariant: Color(0xff822713),
      secondaryFixed: Color(0xffd9e2ff),
      onSecondaryFixed: Color(0xff001944),
      secondaryFixedDim: Color(0xffafc6ff),
      onSecondaryFixedVariant: Color(0xff2e4577),
      tertiaryFixed: Color(0xfffddfa2),
      onTertiaryFixed: Color(0xff251a00),
      tertiaryFixedDim: Color(0xffe0c388),
      onTertiaryFixedVariant: Color(0xff584415),
      surfaceDim: Color(0xffead6d1),
      surfaceBright: Color(0xfffff8f6),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfffff0ed),
      surfaceContainer: Color(0xfffee9e5),
      surfaceContainerHigh: Color(0xfff8e4df),
      surfaceContainerHighest: Color(0xfff2deda),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff390500),
      surfaceTint: Color(0xffa23e28),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff5f0d00),
      onPrimaryContainer: Color(0xffffa48f),
      secondary: Color(0xff000a23),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff001f50),
      onSecondaryContainer: Color(0xff95ace5),
      tertiary: Color(0xff221700),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff3c2b00),
      onTertiaryContainer: Color(0xffd4b77e),
      error: Color(0xff740006),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffcf2c27),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffff8f6),
      onSurface: Color(0xff180f0d),
      onSurfaceVariant: Color(0xff45322d),
      outline: Color(0xff634d49),
      outlineVariant: Color(0xff7f6863),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff3a2e2b),
      inversePrimary: Color(0xffffb4a4),
      primaryFixed: Color(0xffb54c35),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff953520),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff556ca1),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff3d5487),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff816a38),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff675222),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffd6c2be),
      surfaceBright: Color(0xfffff8f6),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfffff0ed),
      surfaceContainer: Color(0xfff8e4df),
      surfaceContainerHigh: Color(0xffedd8d4),
      surfaceContainerHighest: Color(0xffe1cdc9),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff390500),
      surfaceTint: Color(0xffa23e28),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff5f0d00),
      onPrimaryContainer: Color(0xffffe2dc),
      secondary: Color(0xff000a23),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff001f50),
      onSecondaryContainer: Color(0xffc8d7ff),
      tertiary: Color(0xff221700),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff3c2b00),
      onTertiaryContainer: Color(0xffffe5b3),
      error: Color(0xff600004),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff98000a),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffff8f6),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff000000),
      outline: Color(0xff3a2824),
      outlineVariant: Color(0xff594440),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff3a2e2b),
      inversePrimary: Color(0xffffb4a4),
      primaryFixed: Color(0xff852916),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff661202),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff31487a),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff173162),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff5a4618),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff413003),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffc7b5b1),
      surfaceBright: Color(0xfffff8f6),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xffffede9),
      surfaceContainer: Color(0xfff2deda),
      surfaceContainerHigh: Color(0xffe4d0cc),
      surfaceContainerHighest: Color(0xffd6c2be),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffffb4a4),
      surfaceTint: Color(0xffffb4a4),
      onPrimary: Color(0xff621001),
      primaryContainer: Color(0xff5f0d00),
      onPrimaryContainer: Color(0xffe97359),
      secondary: Color(0xffafc6ff),
      onSecondary: Color(0xff152f60),
      secondaryContainer: Color(0xff001f50),
      onSecondaryContainer: Color(0xff7188bf),
      tertiary: Color(0xffe0c388),
      onTertiary: Color(0xff3f2e01),
      tertiaryContainer: Color(0xff3c2b00),
      onTertiaryContainer: Color(0xffac925c),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      surface: Color(0xff1b110f),
      onSurface: Color(0xfff2deda),
      onSurfaceVariant: Color(0xffddc0ba),
      outline: Color(0xffa58b85),
      outlineVariant: Color(0xff57423d),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xfff2deda),
      inversePrimary: Color(0xffa23e28),
      primaryFixed: Color(0xffffdad3),
      onPrimaryFixed: Color(0xff3d0600),
      primaryFixedDim: Color(0xffffb4a4),
      onPrimaryFixedVariant: Color(0xff822713),
      secondaryFixed: Color(0xffd9e2ff),
      onSecondaryFixed: Color(0xff001944),
      secondaryFixedDim: Color(0xffafc6ff),
      onSecondaryFixedVariant: Color(0xff2e4577),
      tertiaryFixed: Color(0xfffddfa2),
      onTertiaryFixed: Color(0xff251a00),
      tertiaryFixedDim: Color(0xffe0c388),
      onTertiaryFixedVariant: Color(0xff584415),
      surfaceDim: Color(0xff1b110f),
      surfaceBright: Color(0xff433634),
      surfaceContainerLowest: Color(0xff150c0a),
      surfaceContainerLow: Color(0xff241917),
      surfaceContainer: Color(0xff281d1b),
      surfaceContainerHigh: Color(0xff332725),
      surfaceContainerHighest: Color(0xff3e322f),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffffd2c9),
      surfaceTint: Color(0xffffb4a4),
      onPrimary: Color(0xff500900),
      primaryContainer: Color(0xffe36e54),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xffd0dcff),
      onSecondary: Color(0xff052354),
      secondaryContainer: Color(0xff7990c7),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xfff7d99c),
      onTertiary: Color(0xff322300),
      tertiaryContainer: Color(0xffa78e58),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffffd2cc),
      onError: Color(0xff540003),
      errorContainer: Color(0xffff5449),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff1b110f),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xfff4d6cf),
      outline: Color(0xffc8aca6),
      outlineVariant: Color(0xffa58a85),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xfff2deda),
      inversePrimary: Color(0xff842814),
      primaryFixed: Color(0xffffdad3),
      onPrimaryFixed: Color(0xff2b0300),
      primaryFixedDim: Color(0xffffb4a4),
      onPrimaryFixedVariant: Color(0xff6b1605),
      secondaryFixed: Color(0xffd9e2ff),
      onSecondaryFixed: Color(0xff000f2f),
      secondaryFixedDim: Color(0xffafc6ff),
      onSecondaryFixedVariant: Color(0xff1c3566),
      tertiaryFixed: Color(0xfffddfa2),
      onTertiaryFixed: Color(0xff191000),
      tertiaryFixedDim: Color(0xffe0c388),
      onTertiaryFixedVariant: Color(0xff453306),
      surfaceDim: Color(0xff1b110f),
      surfaceBright: Color(0xff4f413f),
      surfaceContainerLowest: Color(0xff0d0604),
      surfaceContainerLow: Color(0xff261b19),
      surfaceContainer: Color(0xff312523),
      surfaceContainerHigh: Color(0xff3c302d),
      surfaceContainerHighest: Color(0xff483b38),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffffece8),
      surfaceTint: Color(0xffffb4a4),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xffffaf9d),
      onPrimaryContainer: Color(0xff200200),
      secondary: Color(0xffecefff),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xffabc2fc),
      onSecondaryContainer: Color(0xff000a24),
      tertiary: Color(0xffffeed1),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xffdcbf85),
      onTertiaryContainer: Color(0xff110a00),
      error: Color(0xffffece9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffaea4),
      onErrorContainer: Color(0xff220001),
      surface: Color(0xff1b110f),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffffffff),
      outline: Color(0xffffece8),
      outlineVariant: Color(0xffd9bcb6),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xfff2deda),
      inversePrimary: Color(0xff842814),
      primaryFixed: Color(0xffffdad3),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xffffb4a4),
      onPrimaryFixedVariant: Color(0xff2b0300),
      secondaryFixed: Color(0xffd9e2ff),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xffafc6ff),
      onSecondaryFixedVariant: Color(0xff000f2f),
      tertiaryFixed: Color(0xfffddfa2),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xffe0c388),
      onTertiaryFixedVariant: Color(0xff191000),
      surfaceDim: Color(0xff1b110f),
      surfaceBright: Color(0xff5b4d4a),
      surfaceContainerLowest: Color(0xff000000),
      surfaceContainerLow: Color(0xff281d1b),
      surfaceContainer: Color(0xff3a2e2b),
      surfaceContainerHigh: Color(0xff453936),
      surfaceContainerHighest: Color(0xff514441),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }


  ThemeData theme(ColorScheme colorScheme) => ThemeData(
     useMaterial3: true,
     brightness: colorScheme.brightness,
     colorScheme: colorScheme,
     textTheme: textTheme.apply(
       bodyColor: colorScheme.onSurface,
       displayColor: colorScheme.onSurface,
     ),
     scaffoldBackgroundColor: colorScheme.surface,
     canvasColor: colorScheme.surface,
  );


  List<ExtendedColor> get extendedColors => [
  ];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
