import "package:flutter/material.dart";
import 'package:google_fonts/google_fonts.dart';

class CustomTheme {
  static ThemeData lightThemeData() {
    return ThemeData(
        //colorSchemeSeed: Colors.teal,
        fontFamily: GoogleFonts.lato().fontFamily,
        colorScheme: MaterialTheme.lightScheme().toColorScheme(),
        useMaterial3: true);
  }

  static ThemeData darkThemeData() {
    return ThemeData(
        colorSchemeSeed: Colors.black,
        fontFamily: GoogleFonts.montserratSubrayada().fontFamily,
        useMaterial3: true);
  }
}

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static MaterialScheme lightScheme() {
    return const MaterialScheme(
      brightness: Brightness.light,
      primary: Color(4282083642),
      surfaceTint: Color(4282083642),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4290572468),
      onPrimaryContainer: Color(4278198788),
      secondary: Color(4287646280),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4294957784),
      onSecondaryContainer: Color(4282058763),
      tertiary: Color(4282083642),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4290572469),
      onTertiaryContainer: Color(4278198788),
      error: Color(4290386458),
      onError: Color(4294967295),
      errorContainer: Color(4294957782),
      onErrorContainer: Color(4282449922),
      background: Color(4294441969),
      onBackground: Color(4279835927),
      surface: Color(4294441969),
      onSurface: Color(4279835927),
      surfaceVariant: Color(4292797912),
      onSurfaceVariant: Color(4282534208),
      outline: Color(4285692271),
      outlineVariant: Color(4290955709),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4281152044),
      inverseOnSurface: Color(4293849833),
      inversePrimary: Color(4288795546),
      primaryFixed: Color(4290572468),
      onPrimaryFixed: Color(4278198788),
      primaryFixedDim: Color(4288795546),
      onPrimaryFixedVariant: Color(4280504356),
      secondaryFixed: Color(4294957784),
      onSecondaryFixed: Color(4282058763),
      secondaryFixedDim: Color(4294947760),
      onSecondaryFixedVariant: Color(4285739826),
      tertiaryFixed: Color(4290572469),
      onTertiaryFixed: Color(4278198788),
      tertiaryFixedDim: Color(4288730010),
      onTertiaryFixedVariant: Color(4280504356),
      surfaceDim: Color(4292402130),
      surfaceBright: Color(4294441969),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4294047212),
      surfaceContainer: Color(4293717990),
      surfaceContainerHigh: Color(4293323232),
      surfaceContainerHighest: Color(4292928731),
    );
  }

  ThemeData light() {
    return theme(lightScheme().toColorScheme());
  }

  static MaterialScheme lightMediumContrastScheme() {
    return const MaterialScheme(
      brightness: Brightness.light,
      primary: Color(4280241184),
      surfaceTint: Color(4282083642),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4283531086),
      onPrimaryContainer: Color(4294967295),
      secondary: Color(4285411118),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4289355613),
      onSecondaryContainer: Color(4294967295),
      tertiary: Color(4280241185),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4283531342),
      onTertiaryContainer: Color(4294967295),
      error: Color(4287365129),
      onError: Color(4294967295),
      errorContainer: Color(4292490286),
      onErrorContainer: Color(4294967295),
      background: Color(4294441969),
      onBackground: Color(4279835927),
      surface: Color(4294441969),
      onSurface: Color(4279835927),
      surfaceVariant: Color(4292797912),
      onSurfaceVariant: Color(4282271036),
      outline: Color(4284113239),
      outlineVariant: Color(4285955442),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4281152044),
      inverseOnSurface: Color(4293849833),
      inversePrimary: Color(4288795546),
      primaryFixed: Color(4283531086),
      onPrimaryFixed: Color(4294967295),
      primaryFixedDim: Color(4281951799),
      onPrimaryFixedVariant: Color(4294967295),
      secondaryFixed: Color(4289355613),
      onSecondaryFixed: Color(4294967295),
      secondaryFixedDim: Color(4287449158),
      onSecondaryFixedVariant: Color(4294967295),
      tertiaryFixed: Color(4283531342),
      onTertiaryFixed: Color(4294967295),
      tertiaryFixedDim: Color(4281886264),
      onTertiaryFixedVariant: Color(4294967295),
      surfaceDim: Color(4292402130),
      surfaceBright: Color(4294441969),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4294047212),
      surfaceContainer: Color(4293717990),
      surfaceContainerHigh: Color(4293323232),
      surfaceContainerHighest: Color(4292928731),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme().toColorScheme());
  }

  static MaterialScheme lightHighContrastScheme() {
    return const MaterialScheme(
      brightness: Brightness.light,
      primary: Color(4278200582),
      surfaceTint: Color(4282083642),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4280241184),
      onPrimaryContainer: Color(4294967295),
      secondary: Color(4282650385),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4285411118),
      onSecondaryContainer: Color(4294967295),
      tertiary: Color(4278200582),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4280241185),
      onTertiaryContainer: Color(4294967295),
      error: Color(4283301890),
      onError: Color(4294967295),
      errorContainer: Color(4287365129),
      onErrorContainer: Color(4294967295),
      background: Color(4294441969),
      onBackground: Color(4279835927),
      surface: Color(4294441969),
      onSurface: Color(4278190080),
      surfaceVariant: Color(4292797912),
      onSurfaceVariant: Color(4280231454),
      outline: Color(4282271036),
      outlineVariant: Color(4282271036),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4281152044),
      inverseOnSurface: Color(4294967295),
      inversePrimary: Color(4291164861),
      primaryFixed: Color(4280241184),
      onPrimaryFixed: Color(4294967295),
      primaryFixedDim: Color(4278531340),
      onPrimaryFixedVariant: Color(4294967295),
      secondaryFixed: Color(4285411118),
      onSecondaryFixed: Color(4294967295),
      secondaryFixedDim: Color(4283570714),
      onSecondaryFixedVariant: Color(4294967295),
      tertiaryFixed: Color(4280241185),
      onTertiaryFixed: Color(4294967295),
      tertiaryFixedDim: Color(4278465804),
      onTertiaryFixedVariant: Color(4294967295),
      surfaceDim: Color(4292402130),
      surfaceBright: Color(4294441969),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4294047212),
      surfaceContainer: Color(4293717990),
      surfaceContainerHigh: Color(4293323232),
      surfaceContainerHighest: Color(4292928731),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme().toColorScheme());
  }

  static MaterialScheme darkScheme() {
    return const MaterialScheme(
      brightness: Brightness.dark,
      primary: Color(4288795546),
      surfaceTint: Color(4288795546),
      onPrimary: Color(4278794511),
      primaryContainer: Color(4280504356),
      onPrimaryContainer: Color(4290572468),
      secondary: Color(4294947760),
      onSecondary: Color(4283899165),
      secondaryContainer: Color(4285739826),
      onSecondaryContainer: Color(4294957784),
      tertiary: Color(4288730010),
      onTertiary: Color(4278794512),
      tertiaryContainer: Color(4280504356),
      onTertiaryContainer: Color(4290572469),
      error: Color(4294948011),
      onError: Color(4285071365),
      errorContainer: Color(4287823882),
      onErrorContainer: Color(4294957782),
      background: Color(4279243791),
      onBackground: Color(4292928731),
      surface: Color(4279243791),
      onSurface: Color(4292928731),
      surfaceVariant: Color(4282534208),
      onSurfaceVariant: Color(4290955709),
      outline: Color(4287402888),
      outlineVariant: Color(4282534208),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4292928731),
      inverseOnSurface: Color(4281152044),
      inversePrimary: Color(4282083642),
      primaryFixed: Color(4290572468),
      onPrimaryFixed: Color(4278198788),
      primaryFixedDim: Color(4288795546),
      onPrimaryFixedVariant: Color(4280504356),
      secondaryFixed: Color(4294957784),
      onSecondaryFixed: Color(4282058763),
      secondaryFixedDim: Color(4294947760),
      onSecondaryFixedVariant: Color(4285739826),
      tertiaryFixed: Color(4290572469),
      onTertiaryFixed: Color(4278198788),
      tertiaryFixedDim: Color(4288730010),
      onTertiaryFixedVariant: Color(4280504356),
      surfaceDim: Color(4279243791),
      surfaceBright: Color(4281743924),
      surfaceContainerLowest: Color(4278914826),
      surfaceContainerLow: Color(4279835927),
      surfaceContainer: Color(4280099099),
      surfaceContainerHigh: Color(4280757029),
      surfaceContainerHighest: Color(4281480752),
    );
  }

  ThemeData dark() {
    return theme(darkScheme().toColorScheme());
  }

  static MaterialScheme darkMediumContrastScheme() {
    return const MaterialScheme(
      brightness: Brightness.dark,
      primary: Color(4289058974),
      surfaceTint: Color(4288795546),
      onPrimary: Color(4278196995),
      primaryContainer: Color(4285308008),
      onPrimaryContainer: Color(4278190080),
      secondary: Color(4294949302),
      onSecondary: Color(4281533446),
      secondaryContainer: Color(4291525240),
      onSecondaryContainer: Color(4278190080),
      tertiary: Color(4288993438),
      onTertiary: Color(4278196995),
      tertiaryContainer: Color(4285308008),
      onTertiaryContainer: Color(4278190080),
      error: Color(4294949553),
      onError: Color(4281794561),
      errorContainer: Color(4294923337),
      onErrorContainer: Color(4278190080),
      background: Color(4279243791),
      onBackground: Color(4292928731),
      surface: Color(4279243791),
      onSurface: Color(4294573299),
      surfaceVariant: Color(4282534208),
      onSurfaceVariant: Color(4291218881),
      outline: Color(4288587162),
      outlineVariant: Color(4286481787),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4292928731),
      inverseOnSurface: Color(4280757029),
      inversePrimary: Color(4280570149),
      primaryFixed: Color(4290572468),
      onPrimaryFixed: Color(4278195714),
      primaryFixedDim: Color(4288795546),
      onPrimaryFixedVariant: Color(4279320341),
      secondaryFixed: Color(4294957784),
      onSecondaryFixed: Color(4281073923),
      secondaryFixedDim: Color(4294947760),
      onSecondaryFixedVariant: Color(4284359459),
      tertiaryFixed: Color(4290572469),
      onTertiaryFixed: Color(4278195714),
      tertiaryFixedDim: Color(4288730010),
      onTertiaryFixedVariant: Color(4279254805),
      surfaceDim: Color(4279243791),
      surfaceBright: Color(4281743924),
      surfaceContainerLowest: Color(4278914826),
      surfaceContainerLow: Color(4279835927),
      surfaceContainer: Color(4280099099),
      surfaceContainerHigh: Color(4280757029),
      surfaceContainerHighest: Color(4281480752),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme().toColorScheme());
  }

  static MaterialScheme darkHighContrastScheme() {
    return const MaterialScheme(
      brightness: Brightness.dark,
      primary: Color(4294049770),
      surfaceTint: Color(4288795546),
      onPrimary: Color(4278190080),
      primaryContainer: Color(4289058974),
      onPrimaryContainer: Color(4278190080),
      secondary: Color(4294965753),
      onSecondary: Color(4278190080),
      secondaryContainer: Color(4294949302),
      onSecondaryContainer: Color(4278190080),
      tertiary: Color(4294049770),
      onTertiary: Color(4278190080),
      tertiaryContainer: Color(4288993438),
      onTertiaryContainer: Color(4278190080),
      error: Color(4294965753),
      onError: Color(4278190080),
      errorContainer: Color(4294949553),
      onErrorContainer: Color(4278190080),
      background: Color(4279243791),
      onBackground: Color(4292928731),
      surface: Color(4279243791),
      onSurface: Color(4294967295),
      surfaceVariant: Color(4282534208),
      onSurfaceVariant: Color(4294376944),
      outline: Color(4291218881),
      outlineVariant: Color(4291218881),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4292928731),
      inverseOnSurface: Color(4278190080),
      inversePrimary: Color(4278333961),
      primaryFixed: Color(4290835640),
      onPrimaryFixed: Color(4278190080),
      primaryFixedDim: Color(4289058974),
      onPrimaryFixedVariant: Color(4278196995),
      secondaryFixed: Color(4294959326),
      onSecondaryFixed: Color(4278190080),
      secondaryFixedDim: Color(4294949302),
      onSecondaryFixedVariant: Color(4281533446),
      tertiaryFixed: Color(4290835641),
      onTertiaryFixed: Color(4278190080),
      tertiaryFixedDim: Color(4288993438),
      onTertiaryFixedVariant: Color(4278196995),
      surfaceDim: Color(4279243791),
      surfaceBright: Color(4281743924),
      surfaceContainerLowest: Color(4278914826),
      surfaceContainerLow: Color(4279835927),
      surfaceContainer: Color(4280099099),
      surfaceContainerHigh: Color(4280757029),
      surfaceContainerHighest: Color(4281480752),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme().toColorScheme());
  }

  ThemeData theme(ColorScheme colorScheme) => ThemeData(
        useMaterial3: true,
        brightness: colorScheme.brightness,
        colorScheme: colorScheme,
        textTheme: textTheme.apply(
          bodyColor: colorScheme.onSurface,
          displayColor: colorScheme.onSurface,
        ),
        scaffoldBackgroundColor: colorScheme.background,
        canvasColor: colorScheme.surface,
      );

  List<ExtendedColor> get extendedColors => [];
}

class MaterialScheme {
  const MaterialScheme({
    required this.brightness,
    required this.primary,
    required this.surfaceTint,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.secondary,
    required this.onSecondary,
    required this.secondaryContainer,
    required this.onSecondaryContainer,
    required this.tertiary,
    required this.onTertiary,
    required this.tertiaryContainer,
    required this.onTertiaryContainer,
    required this.error,
    required this.onError,
    required this.errorContainer,
    required this.onErrorContainer,
    required this.background,
    required this.onBackground,
    required this.surface,
    required this.onSurface,
    required this.surfaceVariant,
    required this.onSurfaceVariant,
    required this.outline,
    required this.outlineVariant,
    required this.shadow,
    required this.scrim,
    required this.inverseSurface,
    required this.inverseOnSurface,
    required this.inversePrimary,
    required this.primaryFixed,
    required this.onPrimaryFixed,
    required this.primaryFixedDim,
    required this.onPrimaryFixedVariant,
    required this.secondaryFixed,
    required this.onSecondaryFixed,
    required this.secondaryFixedDim,
    required this.onSecondaryFixedVariant,
    required this.tertiaryFixed,
    required this.onTertiaryFixed,
    required this.tertiaryFixedDim,
    required this.onTertiaryFixedVariant,
    required this.surfaceDim,
    required this.surfaceBright,
    required this.surfaceContainerLowest,
    required this.surfaceContainerLow,
    required this.surfaceContainer,
    required this.surfaceContainerHigh,
    required this.surfaceContainerHighest,
  });

  final Brightness brightness;
  final Color primary;
  final Color surfaceTint;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color secondary;
  final Color onSecondary;
  final Color secondaryContainer;
  final Color onSecondaryContainer;
  final Color tertiary;
  final Color onTertiary;
  final Color tertiaryContainer;
  final Color onTertiaryContainer;
  final Color error;
  final Color onError;
  final Color errorContainer;
  final Color onErrorContainer;
  final Color background;
  final Color onBackground;
  final Color surface;
  final Color onSurface;
  final Color surfaceVariant;
  final Color onSurfaceVariant;
  final Color outline;
  final Color outlineVariant;
  final Color shadow;
  final Color scrim;
  final Color inverseSurface;
  final Color inverseOnSurface;
  final Color inversePrimary;
  final Color primaryFixed;
  final Color onPrimaryFixed;
  final Color primaryFixedDim;
  final Color onPrimaryFixedVariant;
  final Color secondaryFixed;
  final Color onSecondaryFixed;
  final Color secondaryFixedDim;
  final Color onSecondaryFixedVariant;
  final Color tertiaryFixed;
  final Color onTertiaryFixed;
  final Color tertiaryFixedDim;
  final Color onTertiaryFixedVariant;
  final Color surfaceDim;
  final Color surfaceBright;
  final Color surfaceContainerLowest;
  final Color surfaceContainerLow;
  final Color surfaceContainer;
  final Color surfaceContainerHigh;
  final Color surfaceContainerHighest;
}

extension MaterialSchemeUtils on MaterialScheme {
  ColorScheme toColorScheme() {
    return ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimaryContainer,
      secondary: secondary,
      onSecondary: onSecondary,
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: onSecondaryContainer,
      tertiary: tertiary,
      onTertiary: onTertiary,
      tertiaryContainer: tertiaryContainer,
      onTertiaryContainer: onTertiaryContainer,
      error: error,
      onError: onError,
      errorContainer: errorContainer,
      onErrorContainer: onErrorContainer,
      background: background,
      onBackground: onBackground,
      surface: surface,
      onSurface: onSurface,
      surfaceVariant: surfaceVariant,
      onSurfaceVariant: onSurfaceVariant,
      outline: outline,
      outlineVariant: outlineVariant,
      shadow: shadow,
      scrim: scrim,
      inverseSurface: inverseSurface,
      onInverseSurface: inverseOnSurface,
      inversePrimary: inversePrimary,
    );
  }
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
