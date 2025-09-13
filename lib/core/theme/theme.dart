import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF487d00),
      // --color-primary
      surfaceTint: Color(0xFF4A4ED9),
      onPrimary: Color(0xFFF0F2FA),
      // --color-primary-content
      primaryContainer: Color(0xFFFFFFFF),
      // --color-base-100
      onPrimaryContainer: Color(0xFF363646),
      // --color-base-content
      secondary: Color(0xFFB33B62),
      // --color-secondary
      onSecondary: Color(0xFFF0F0F7),
      // --color-secondary-content
      secondaryContainer: Color(0xFFF8F8F8),
      // --color-base-200
      onSecondaryContainer: Color(0xFF363646),
      tertiary: Color(0xFF58AEAF),
      // --color-accent
      onTertiary: Color(0xFF616B6D),
      // --color-accent-content
      tertiaryContainer: Color(0xFFF0F0F0),
      // --color-base-300
      onTertiaryContainer: Color(0xFF363646),
      error: Color(0xFFD87422),
      // --color-error
      onError: Color(0xFFA9561B),
      errorContainer: Color(0xFFFFE6D4),
      onErrorContainer: Color(0xFF6E3600),
      surface: Color(0xFFFFFFFF),
      // --color-base-100
      onSurface: Color(0xFF363646),
      // --color-base-content
      onSurfaceVariant: Color(0xFF242424),
      // --color-neutral
      outline: Color(0xFF999999),
      outlineVariant: Color(0xFFCCCCCC),
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: Color(0xFFF0F0F0),
      inversePrimary: Color(0xFF4A4ED9),
      primaryFixed: Color(0xFFFFFFFF),
      onPrimaryFixed: Color(0xFF363646),
      primaryFixedDim: Color(0xFFB3B3B3),
      onPrimaryFixedVariant: Color(0xFF6B6B6B),
      secondaryFixed: Color(0xFFF8F8F8),
      onSecondaryFixed: Color(0xFF363646),
      secondaryFixedDim: Color(0xFFC0C0C0),
      onSecondaryFixedVariant: Color(0xFF6B6B6B),
      tertiaryFixed: Color(0xFFF0F0F0),
      onTertiaryFixed: Color(0xFF616B6D),
      tertiaryFixedDim: Color(0xFF869696),
      onTertiaryFixedVariant: Color(0xFF404949),
      surfaceDim: Color(0xFFE0E0E0),
      surfaceBright: Color(0xFFFAFAFA),
      surfaceContainerLowest: Color(0xFFFFFFFF),
      surfaceContainerLow: Color(0xFFF8F8F8),
      surfaceContainer: Color(0xFFF0F0F0),
      surfaceContainerHigh: Color(0xFFEBEBEB),
      surfaceContainerHighest: Color(0xFFE5E5E5),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff133665),
      surfaceTint: Color(0xff415f91),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff506da0),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff2e3647),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff646d80),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff452e4a),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff7f6484),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff740006),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffcf2c27),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfff9f9ff),
      onSurface: Color(0xff0f1116),
      onSurfaceVariant: Color(0xff33363e),
      outline: Color(0xff4f525a),
      outlineVariant: Color(0xff6a6d75),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2e3036),
      inversePrimary: Color(0xffaac7ff),
      primaryFixed: Color(0xff506da0),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff375586),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff646d80),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff4c5567),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff7f6484),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff654c6b),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffc5c6cd),
      surfaceBright: Color(0xfff9f9ff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff3f3fa),
      surfaceContainer: Color(0xffe7e8ee),
      surfaceContainerHigh: Color(0xffdcdce3),
      surfaceContainerHighest: Color(0xffd1d1d8),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,

      // Primary colors
      primary: Color(0xFF3f6bcb),
      // oklch(52% 0.105 223.128)
      onPrimary: Color(0xFFede6fa),
      // oklch(93% 0.034 272.788)
      primaryContainer: Color(0xFFDDE6FF),
      // optional approximation
      onPrimaryContainer: Color(0xFF192755),
      // darker onPrimary

      // Secondary colors
      secondary: Color(0xFFdb5460),
      // oklch(65% 0.241 354.308)
      onSecondary: Color(0xFFf0dde3),
      // oklch(94% 0.028 342.258)

      // Tertiary (using accent)
      tertiary: Color(0xFFbdeac9),
      // oklch(77% 0.152 181.912)
      onTertiary: Color(0xFF426d66),
      // oklch(38% 0.063 188.416)

      // Surface and base tones
      surface: Color(0xFFFFFFFF),
      // base-100
      onSurface: Color(0xFF37353f),
      // base-content
      surfaceTint: Color(0xFF3f6bcb),
      // primary as tint
      shadow: Color(0xFF000000),

      // Error
      error: Color(0xFFe35d4d),
      // oklch(71% 0.194 13.428)
      onError: Color(0xFF471914),
      // oklch(27% 0.105 12.094)
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF410002),

      // Info (mapped to outline)
      outline: Color(0xFF7ca9e9),
      // oklch(74% 0.16 232.661)

      // Inverse surfaces
      inverseSurface: Color(0xFF222222),
      onInverseSurface: Color(0xFFeeeeee),
      inversePrimary: Color(0xFFaac7ff),

      // Scrim
      scrim: Color(0xFF000000),

      // Updated for Flutter 3.18+
      surfaceContainerLowest: Color(0xFFFFFFFF),
      // base-100
      surfaceContainerLow: Color(0xFFf9f9f9),
      // base-200
      surfaceContainer: Color(0xFFF2F2F2),
      // base-300
      surfaceContainerHigh: Color(0xFFE6E6E6),
      // approximation
      surfaceContainerHighest: Color(0xFFDCDCDC), // approximation
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF487d00),
      // --color-primary approx
      surfaceTint: Color(0xFF4A6BF5),
      onPrimary: Color(0xFFE3E8FA),
      // --color-primary-content
      primaryContainer: Color(0xFF333333),
      // --color-base-100
      onPrimaryContainer: Color(0xFFF7F7F7),
      // --color-base-content
      secondary: Color(0xFFB2B2B2),
      // --color-secondary
      onSecondary: Color(0xFF1E1E1E),
      // --color-secondary-content
      secondaryContainer: Color(0xFF1A1A1A),
      // --color-base-200
      onSecondaryContainer: Color(0xFFE3E8FA),
      tertiary: Color(0xFF7777FF),
      // --color-accent
      onTertiary: Color(0xFFE7E9FF),
      // --color-accent-content
      tertiaryContainer: Color(0xFF444444),
      // --color-base-300
      onTertiaryContainer: Color(0xFFF7F7F7),
      error: Color(0xFFFF6B6B),
      // --color-error
      onError: Color(0xFF1E1E1E),
      errorContainer: Color(0xFF442222),
      onErrorContainer: Color(0xFFFF6B6B),
      surface: Color(0xFF1A1A1A),
      // --color-base-200
      onSurface: Color(0xFFF7F7F7),
      // --color-base-content
      onSurfaceVariant: Color(0xFF666666),
      // --color-neutral
      outline: Color(0xFF999999),
      outlineVariant: Color(0xFF444444),
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: Color(0xFF333333),
      inversePrimary: Color(0xFF4A6BF5),
      primaryFixed: Color(0xFF333333),
      onPrimaryFixed: Color(0xFFE3E8FA),
      primaryFixedDim: Color(0xFF666666),
      onPrimaryFixedVariant: Color(0xFFF7F7F7),
      secondaryFixed: Color(0xFF1A1A1A),
      onSecondaryFixed: Color(0xFFE3E8FA),
      secondaryFixedDim: Color(0xFF444444),
      onSecondaryFixedVariant: Color(0xFFF7F7F7),
      tertiaryFixed: Color(0xFF444444),
      onTertiaryFixed: Color(0xFFE7E9FF),
      tertiaryFixedDim: Color(0xFF7777FF),
      onTertiaryFixedVariant: Color(0xFFF7F7F7),
      surfaceDim: Color(0xFF0D0D0D),
      surfaceBright: Color(0xFF444444),
      surfaceContainerLowest: Color(0xFF0A0A0A),
      surfaceContainerLow: Color(0xFF1C1C1C),
      surfaceContainer: Color(0xFF0A0A0A),
      surfaceContainerHigh: Color(0xFF333333),
      surfaceContainerHighest: Color(0xFF444444),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffcdddff),
      surfaceTint: Color(0xffaac7ff),
      onPrimary: Color(0xff002551),
      primaryContainer: Color(0xff7491c7),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xffd4dcf2),
      onSecondary: Color(0xff161616),
      secondaryContainer: Color(0xff8891a5),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xfff3d2f7),
      onTertiary: Color(0xff331d39),
      tertiaryContainer: Color(0xffa487a9),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffffd2cc),
      onError: Color(0xff540003),
      errorContainer: Color(0xffff5449),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff111318),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffdadce6),
      outline: Color(0xffafb2bb),
      outlineVariant: Color(0xff8e9099),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe2e2e9),
      inversePrimary: Color(0xff294878),
      primaryFixed: Color(0xffd6e3ff),
      onPrimaryFixed: Color(0xff00112b),
      primaryFixedDim: Color(0xffaac7ff),
      onPrimaryFixedVariant: Color(0xff133665),
      secondaryFixed: Color(0xffdae2f9),
      onSecondaryFixed: Color(0xff081121),
      secondaryFixedDim: Color(0xffbec6dc),
      onSecondaryFixedVariant: Color(0xff2e3647),
      tertiaryFixed: Color(0xfffad8fd),
      onTertiaryFixed: Color(0xff1d0823),
      tertiaryFixedDim: Color(0xffddbce0),
      onTertiaryFixedVariant: Color(0xff452e4a),
      surfaceDim: Color(0xff111318),
      surfaceBright: Color(0xff43444a),
      surfaceContainerLowest: Color(0xff06070c),
      surfaceContainerLow: Color(0xff1b1e22),
      surfaceContainer: Color(0xff26282d),
      surfaceContainerHigh: Color(0xff313238),
      surfaceContainerHighest: Color(0xff3c3e43),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffebf0ff),
      surfaceTint: Color(0xffaac7ff),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xffa6c3fc),
      onPrimaryContainer: Color(0xff000b20),
      secondary: Color(0xffebf0ff),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xffbac3d8),
      onSecondaryContainer: Color(0xff030b1a),
      tertiary: Color(0xffffe9ff),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xffd8b8dc),
      onTertiaryContainer: Color(0xff16041d),
      error: Color(0xffffece9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffaea4),
      onErrorContainer: Color(0xff220001),
      surface: Color(0xff111318),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffffffff),
      outline: Color(0xffeeeff9),
      outlineVariant: Color(0xffc0c2cc),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe2e2e9),
      inversePrimary: Color(0xff294878),
      primaryFixed: Color(0xffd6e3ff),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xffaac7ff),
      onPrimaryFixedVariant: Color(0xff00112b),
      secondaryFixed: Color(0xffdae2f9),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xffbec6dc),
      onSecondaryFixedVariant: Color(0xff081121),
      tertiaryFixed: Color(0xfffad8fd),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xffddbce0),
      onTertiaryFixedVariant: Color(0xff1d0823),
      surfaceDim: Color(0xff111318),
      surfaceBright: Color(0xff4e5056),
      surfaceContainerLowest: Color(0xff000000),
      surfaceContainerLow: Color(0xff1d2024),
      surfaceContainer: Color(0xff2e3036),
      surfaceContainerHigh: Color(0xff393b41),
      surfaceContainerHighest: Color(0xff45474c),
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
