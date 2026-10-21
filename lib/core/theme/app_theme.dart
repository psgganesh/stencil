import 'package:flutter/material.dart';

const _fontFallback = <String>[
  'Noto Sans Devanagari',
  'Noto Sans Bengali',
  'Noto Sans Tamil',
  'Noto Sans Telugu',
  'Noto Sans Gujarati',
  'Noto Sans Kannada',
  'Noto Sans Malayalam',
  'Noto Sans Gurmukhi',
];

@immutable
class StencilColors extends ThemeExtension<StencilColors> {
  const StencilColors({
    required this.selectedAndLink,
    required this.track,
    required this.gainContainer,
    required this.onGainContainer,
    required this.gain,
    required this.accentFill,
    required this.mutedOnPrimaryContainer,
    required this.filledButtonOnPrimaryContainer,
    required this.onFilledButtonOnPrimaryContainer,
  });

  final Color selectedAndLink;
  final Color track;
  final Color gainContainer;
  final Color onGainContainer;
  final Color gain;
  final Color accentFill;
  final Color mutedOnPrimaryContainer;
  final Color filledButtonOnPrimaryContainer;
  final Color onFilledButtonOnPrimaryContainer;

  @override
  StencilColors copyWith({
    Color? selectedAndLink,
    Color? track,
    Color? gainContainer,
    Color? onGainContainer,
    Color? gain,
    Color? accentFill,
    Color? mutedOnPrimaryContainer,
    Color? filledButtonOnPrimaryContainer,
    Color? onFilledButtonOnPrimaryContainer,
  }) {
    return StencilColors(
      selectedAndLink: selectedAndLink ?? this.selectedAndLink,
      track: track ?? this.track,
      gainContainer: gainContainer ?? this.gainContainer,
      onGainContainer: onGainContainer ?? this.onGainContainer,
      gain: gain ?? this.gain,
      accentFill: accentFill ?? this.accentFill,
      mutedOnPrimaryContainer:
          mutedOnPrimaryContainer ?? this.mutedOnPrimaryContainer,
      filledButtonOnPrimaryContainer:
          filledButtonOnPrimaryContainer ?? this.filledButtonOnPrimaryContainer,
      onFilledButtonOnPrimaryContainer:
          onFilledButtonOnPrimaryContainer ??
          this.onFilledButtonOnPrimaryContainer,
    );
  }

  @override
  StencilColors lerp(StencilColors? other, double t) {
    if (other == null) return this;
    return StencilColors(
      selectedAndLink: Color.lerp(selectedAndLink, other.selectedAndLink, t)!,
      track: Color.lerp(track, other.track, t)!,
      gainContainer: Color.lerp(gainContainer, other.gainContainer, t)!,
      onGainContainer: Color.lerp(onGainContainer, other.onGainContainer, t)!,
      gain: Color.lerp(gain, other.gain, t)!,
      accentFill: Color.lerp(accentFill, other.accentFill, t)!,
      mutedOnPrimaryContainer: Color.lerp(
        mutedOnPrimaryContainer,
        other.mutedOnPrimaryContainer,
        t,
      )!,
      filledButtonOnPrimaryContainer: Color.lerp(
        filledButtonOnPrimaryContainer,
        other.filledButtonOnPrimaryContainer,
        t,
      )!,
      onFilledButtonOnPrimaryContainer: Color.lerp(
        onFilledButtonOnPrimaryContainer,
        other.onFilledButtonOnPrimaryContainer,
        t,
      )!,
    );
  }
}

abstract final class AppTheme {
  static const lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF00639B),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFCDE5FF),
    onPrimaryContainer: Color(0xFF001D32),
    secondary: Color(0xFF4B626F),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFCDE5FF),
    onSecondaryContainer: Color(0xFF001D32),
    tertiary: Color(0xFF855300),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFFFDCBE),
    onTertiaryContainer: Color(0xFF2C1600),
    error: Color(0xFFBA1A1A),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF410002),
    surface: Color(0xFFF8F9FF),
    onSurface: Color(0xFF191C20),
    onSurfaceVariant: Color(0xFF42474E),
    outline: Color(0xFF72777F),
    outlineVariant: Color(0xFFC2C7CF),
    shadow: Color(0xFF000000),
    scrim: Color(0x7A191C20),
    inverseSurface: Color(0xFF2E3135),
    onInverseSurface: Color(0xFFF0F1F6),
    inversePrimary: Color(0xFF96CCFF),
    surfaceTint: Color(0xFF00639B),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFF2F3F9),
    surfaceContainer: Color(0xFFECEEF4),
    surfaceContainerHigh: Color(0xFFE6E8EE),
    surfaceContainerHighest: Color(0xFFE1E2E8),
  );

  static const darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF00639B),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFF004B76),
    onPrimaryContainer: Color(0xFFCDE5FF),
    secondary: Color(0xFF96CCFF),
    onSecondary: Color(0xFF00344F),
    secondaryContainer: Color(0xFF004B76),
    onSecondaryContainer: Color(0xFFCDE5FF),
    tertiary: Color(0xFFF5BE78),
    onTertiary: Color(0xFF462A00),
    tertiaryContainer: Color(0xFF693C00),
    onTertiaryContainer: Color(0xFFFFDCBE),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: Color(0xFF111418),
    onSurface: Color(0xFFE1E2E8),
    onSurfaceVariant: Color(0xFFC2C7CF),
    outline: Color(0xFF8C9199),
    outlineVariant: Color(0xFF42474E),
    shadow: Color(0xFF000000),
    scrim: Color(0x99000000),
    inverseSurface: Color(0xFFE1E2E8),
    onInverseSurface: Color(0xFF2E3135),
    inversePrimary: Color(0xFF00639B),
    surfaceTint: Color(0xFF00639B),
    surfaceContainerLowest: Color(0xFF0C0F13),
    surfaceContainerLow: Color(0xFF171A1E),
    surfaceContainer: Color(0xFF1D2024),
    surfaceContainerHigh: Color(0xFF272A2E),
    surfaceContainerHighest: Color(0xFF33363B),
  );

  static const _lightColors = StencilColors(
    selectedAndLink: Color(0xFF00639B),
    track: Color(0xFFD9DEE6),
    gainContainer: Color(0xFFD8F3DC),
    onGainContainer: Color(0xFF00210C),
    gain: Color(0xFF1B6D3A),
    accentFill: Color(0xFFF28A1E),
    mutedOnPrimaryContainer: Color(0xFF124A73),
    filledButtonOnPrimaryContainer: Color(0xFF00639B),
    onFilledButtonOnPrimaryContainer: Color(0xFFFFFFFF),
  );

  static const _darkColors = StencilColors(
    selectedAndLink: Color(0xFF96CCFF),
    track: Color(0xFF33363B),
    gainContainer: Color(0xFF0E5128),
    onGainContainer: Color(0xFFB7F1C4),
    gain: Color(0xFF7DDA9A),
    accentFill: Color(0xFFF28A1E),
    mutedOnPrimaryContainer: Color(0xFFB9D9F7),
    filledButtonOnPrimaryContainer: Color(0xFF96CCFF),
    onFilledButtonOnPrimaryContainer: Color(0xFF001D32),
  );

  static final light = _build(lightScheme, _lightColors);
  static final dark = _build(darkScheme, _darkColors);

  static ThemeData _build(ColorScheme scheme, StencilColors stencilColors) {
    final base = ThemeData(
      brightness: scheme.brightness,
      colorScheme: scheme,
      useMaterial3: true,
    );
    final textTheme = base.textTheme.apply(
      fontFamily: 'Roboto',
      fontFamilyFallback: _fontFallback,
    );
    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
    );

    return base.copyWith(
      scaffoldBackgroundColor: scheme.surface,
      textTheme: textTheme,
      extensions: <ThemeExtension<dynamic>>[stencilColors],
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: buttonShape,
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: stencilColors.selectedAndLink,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          side: BorderSide(color: scheme.outline),
          shape: buttonShape,
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: stencilColors.selectedAndLink,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: buttonShape,
          textStyle: textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationThemeData(
        constraints: const BoxConstraints(minHeight: 56),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        labelStyle: textTheme.labelMedium?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: stencilColors.selectedAndLink,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.error, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.error, width: 2),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: Colors.transparent,
        selectedColor: scheme.primaryContainer,
        disabledColor: scheme.surfaceContainer,
        side: BorderSide(color: scheme.outline),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        labelStyle: textTheme.labelMedium?.copyWith(fontSize: 13),
        checkmarkColor: scheme.onPrimaryContainer,
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(0, 40)),
          shape: WidgetStatePropertyAll(buttonShape),
          side: WidgetStatePropertyAll(BorderSide(color: scheme.outline)),
          textStyle: WidgetStatePropertyAll(textTheme.labelLarge),
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? scheme.primaryContainer
                : Colors.transparent,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? scheme.onPrimaryContainer
                : scheme.onSurfaceVariant,
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.primary
              : scheme.surfaceContainer,
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? Colors.transparent
              : scheme.outline,
        ),
        trackOutlineWidth: const WidgetStatePropertyAll(2),
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? Colors.white
              : scheme.outline,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 80,
        backgroundColor: scheme.surfaceContainer,
        indicatorColor: scheme.secondaryContainer,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        labelTextStyle: WidgetStatePropertyAll(textTheme.labelMedium),
      ),
      navigationRailTheme: NavigationRailThemeData(
        minWidth: 80,
        backgroundColor: scheme.surfaceContainer,
        indicatorColor: scheme.secondaryContainer,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        labelType: NavigationRailLabelType.all,
        selectedLabelTextStyle: textTheme.labelMedium,
        unselectedLabelTextStyle: textTheme.labelMedium,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onInverseSurface,
        ),
        actionTextColor: scheme.inversePrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
