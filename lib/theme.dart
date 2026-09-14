import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff00003a),
      surfaceTint: Color(0xff54589a),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff151859),
      onPrimaryContainer: Color(0xff7f83c8),
      secondary: Color(0xff330000),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff590202),
      onSecondaryContainer: Color(0xffe56a5b),
      tertiary: Color(0xff532c00),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff734002),
      onTertiaryContainer: Color(0xfff7ae6a),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff93000a),
      surface: Color(0xfffdf8f8),
      onSurface: Color(0xff1c1b1b),
      onSurfaceVariant: Color(0xff464650),
      outline: Color(0xff777681),
      outlineVariant: Color(0xffc7c5d1),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff313030),
      inversePrimary: Color(0xffbfc2ff),
      primaryFixed: Color(0xffe0e0ff),
      onPrimaryFixed: Color(0xff0e1153),
      primaryFixedDim: Color(0xffbfc2ff),
      onPrimaryFixedVariant: Color(0xff3c4081),
      secondaryFixed: Color(0xffffdad5),
      onSecondaryFixed: Color(0xff410001),
      secondaryFixedDim: Color(0xffffb4a9),
      onSecondaryFixedVariant: Color(0xff84231a),
      tertiaryFixed: Color(0xffffdcc0),
      onTertiaryFixed: Color(0xff2d1600),
      tertiaryFixedDim: Color(0xffffb876),
      onTertiaryFixedVariant: Color(0xff6b3b00),
      surfaceDim: Color(0xffddd9d9),
      surfaceBright: Color(0xfffdf8f8),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff7f3f2),
      surfaceContainer: Color(0xfff1edec),
      surfaceContainerHigh: Color(0xffebe7e7),
      surfaceContainerHighest: Color(0xffe5e2e1),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff00003a),
      surfaceTint: Color(0xff54589a),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff151859),
      onPrimaryContainer: Color(0xffa3a6ee),
      secondary: Color(0xff330000),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff590202),
      onSecondaryContainer: Color(0xffff998b),
      tertiary: Color(0xff532c00),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff734002),
      onTertiaryContainer: Color(0xffffe5d2),
      error: Color(0xff740006),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffcf2c27),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffdf8f8),
      onSurface: Color(0xff111111),
      onSurfaceVariant: Color(0xff35353f),
      outline: Color(0xff52515c),
      outlineVariant: Color(0xff6d6c77),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff313030),
      inversePrimary: Color(0xffbfc2ff),
      primaryFixed: Color(0xff6367aa),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff4b4e90),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xffb8493c),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff983127),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff9a6023),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff7d480b),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffc9c6c5),
      surfaceBright: Color(0xfffdf8f8),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff7f3f2),
      surfaceContainer: Color(0xffebe7e7),
      surfaceContainerHigh: Color(0xffe0dcdc),
      surfaceContainerHighest: Color(0xffd4d1d0),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff00003a),
      surfaceTint: Color(0xff54589a),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff151859),
      onPrimaryContainer: Color(0xffd2d3ff),
      secondary: Color(0xff330000),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff590202),
      onSecondaryContainer: Color(0xffffd7d2),
      tertiary: Color(0xff452400),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff6f3d00),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff600004),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff98000a),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffdf8f8),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff000000),
      outline: Color(0xff2b2b35),
      outlineVariant: Color(0xff494852),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff313030),
      inversePrimary: Color(0xffbfc2ff),
      primaryFixed: Color(0xff3f4383),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff282b6b),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff88261d),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff680e09),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff6f3d00),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff4e2900),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffbbb8b8),
      surfaceBright: Color(0xfffdf8f8),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff4f0ef),
      surfaceContainer: Color(0xffe5e2e1),
      surfaceContainerHigh: Color(0xffd7d3d3),
      surfaceContainerHighest: Color(0xffc9c6c5),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffbfc2ff),
      surfaceTint: Color(0xffbfc2ff),
      onPrimary: Color(0xff252969),
      primaryContainer: Color(0xff151859),
      onPrimaryContainer: Color(0xff7f83c8),
      secondary: Color(0xffffb4a9),
      onSecondary: Color(0xff650b07),
      secondaryContainer: Color(0xff590202),
      onSecondaryContainer: Color(0xffe56a5b),
      tertiary: Color(0xffffb876),
      onTertiary: Color(0xff4b2800),
      tertiaryContainer: Color(0xff734002),
      onTertiaryContainer: Color(0xfff7ae6a),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      surface: Color(0xff141313),
      onSurface: Color(0xffe5e2e1),
      onSurfaceVariant: Color(0xffc7c5d1),
      outline: Color(0xff918f9b),
      outlineVariant: Color(0xff464650),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe5e2e1),
      inversePrimary: Color(0xff54589a),
      primaryFixed: Color(0xffe0e0ff),
      onPrimaryFixed: Color(0xff0e1153),
      primaryFixedDim: Color(0xffbfc2ff),
      onPrimaryFixedVariant: Color(0xff3c4081),
      secondaryFixed: Color(0xffffdad5),
      onSecondaryFixed: Color(0xff410001),
      secondaryFixedDim: Color(0xffffb4a9),
      onSecondaryFixedVariant: Color(0xff84231a),
      tertiaryFixed: Color(0xffffdcc0),
      onTertiaryFixed: Color(0xff2d1600),
      tertiaryFixedDim: Color(0xffffb876),
      onTertiaryFixedVariant: Color(0xff6b3b00),
      surfaceDim: Color(0xff141313),
      surfaceBright: Color(0xff3a3939),
      surfaceContainerLowest: Color(0xff0e0e0e),
      surfaceContainerLow: Color(0xff1c1b1b),
      surfaceContainer: Color(0xff201f1f),
      surfaceContainerHigh: Color(0xff2b2a2a),
      surfaceContainerHighest: Color(0xff353434),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffd9d9ff),
      surfaceTint: Color(0xffbfc2ff),
      onPrimary: Color(0xff1a1d5d),
      primaryContainer: Color(0xff878bd1),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xffffd2cb),
      onSecondary: Color(0xff540001),
      secondaryContainer: Color(0xffe66b5c),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xffffd4b1),
      onTertiary: Color(0xff3c1e00),
      tertiaryContainer: Color(0xffc38243),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffffd2cc),
      onError: Color(0xff540003),
      errorContainer: Color(0xffff5449),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff141313),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffdddbe8),
      outline: Color(0xffb2b0bd),
      outlineVariant: Color(0xff908f9b),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe5e2e1),
      inversePrimary: Color(0xff3e4182),
      primaryFixed: Color(0xffe0e0ff),
      onPrimaryFixed: Color(0xff02024b),
      primaryFixedDim: Color(0xffbfc2ff),
      onPrimaryFixedVariant: Color(0xff2b2f6f),
      secondaryFixed: Color(0xffffdad5),
      onSecondaryFixed: Color(0xff2d0000),
      secondaryFixedDim: Color(0xffffb4a9),
      onSecondaryFixedVariant: Color(0xff6d120c),
      tertiaryFixed: Color(0xffffdcc0),
      onTertiaryFixed: Color(0xff1e0d00),
      tertiaryFixedDim: Color(0xffffb876),
      onTertiaryFixedVariant: Color(0xff532c00),
      surfaceDim: Color(0xff141313),
      surfaceBright: Color(0xff454444),
      surfaceContainerLowest: Color(0xff070707),
      surfaceContainerLow: Color(0xff1e1d1d),
      surfaceContainer: Color(0xff282828),
      surfaceContainerHigh: Color(0xff333232),
      surfaceContainerHighest: Color(0xff3e3d3d),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xfff0eeff),
      surfaceTint: Color(0xffbfc2ff),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xffbabdff),
      onPrimaryContainer: Color(0xff01003d),
      secondary: Color(0xffffece9),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xffffaea3),
      onSecondaryContainer: Color(0xff220000),
      tertiary: Color(0xffffede0),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xfffdb36f),
      onTertiaryContainer: Color(0xff160800),
      error: Color(0xffffece9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffaea4),
      onErrorContainer: Color(0xff220001),
      surface: Color(0xff141313),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffffffff),
      outline: Color(0xfff1eefb),
      outlineVariant: Color(0xffc3c1ce),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe5e2e1),
      inversePrimary: Color(0xff3e4182),
      primaryFixed: Color(0xffe0e0ff),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xffbfc2ff),
      onPrimaryFixedVariant: Color(0xff02024b),
      secondaryFixed: Color(0xffffdad5),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xffffb4a9),
      onSecondaryFixedVariant: Color(0xff2d0000),
      tertiaryFixed: Color(0xffffdcc0),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xffffb876),
      onTertiaryFixedVariant: Color(0xff1e0d00),
      surfaceDim: Color(0xff141313),
      surfaceBright: Color(0xff515050),
      surfaceContainerLowest: Color(0xff000000),
      surfaceContainerLow: Color(0xff201f1f),
      surfaceContainer: Color(0xff313030),
      surfaceContainerHigh: Color(0xff3c3b3b),
      surfaceContainerHighest: Color(0xff484646),
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

  List<ExtendedColor> get extendedColors => [];
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
