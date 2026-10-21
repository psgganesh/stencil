import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:stencil/app.dart';
import 'package:stencil/core/preferences/shared_preferences_provider.dart';
import 'package:stencil/core/theme/app_theme.dart';
import 'package:stencil/core/theme/theme_mode_notifier.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<SharedPreferencesWithCache> createPreferences(
    InMemorySharedPreferencesAsync backend,
  ) async {
    SharedPreferencesAsyncPlatform.instance = backend;
    return SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(
        allowList: {themeModePreferenceKey},
      ),
    );
  }

  Future<void> pumpApp(
    WidgetTester tester,
    SharedPreferencesWithCache preferences,
  ) {
    return tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
        child: const MainApp(),
      ),
    );
  }

  Brightness renderedBrightness(WidgetTester tester) {
    return Theme.of(tester.element(find.text('Stencil'))).brightness;
  }

  testWidgets('System mode follows the platform brightness by default', (
    tester,
  ) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    final preferences = await createPreferences(
      InMemorySharedPreferencesAsync.empty(),
    );

    await pumpApp(tester, preferences);
    await tester.pumpAndSettle();

    expect(renderedBrightness(tester), Brightness.dark);
    expect(
      tester
          .widget<SegmentedButton<ThemeMode>>(
            find.byType(SegmentedButton<ThemeMode>),
          )
          .selected,
      {ThemeMode.system},
    );
  });

  testWidgets('Choosing a theme changes it immediately', (tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    final preferences = await createPreferences(
      InMemorySharedPreferencesAsync.empty(),
    );
    await pumpApp(tester, preferences);

    await tester.tap(find.text('Dark'));
    await tester.pump();

    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );
    await tester.pumpAndSettle();
    expect(renderedBrightness(tester), Brightness.dark);
  });

  testWidgets('The selected theme survives a re-pump with the same store', (
    tester,
  ) async {
    final backend = InMemorySharedPreferencesAsync.empty();
    final firstPreferences = await createPreferences(backend);
    await pumpApp(tester, firstPreferences);

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    final restoredPreferences = await createPreferences(backend);
    await pumpApp(tester, restoredPreferences);
    await tester.pumpAndSettle();

    expect(renderedBrightness(tester), Brightness.dark);
    expect(
      tester
          .widget<SegmentedButton<ThemeMode>>(
            find.byType(SegmentedButton<ThemeMode>),
          )
          .selected,
      {ThemeMode.dark},
    );
  });

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('Text contrast passes in ${mode.name} mode', (tester) async {
      final preferences = await createPreferences(
        InMemorySharedPreferencesAsync.withData({
          themeModePreferenceKey: mode.name,
        }),
      );
      await pumpApp(tester, preferences);
      await tester.pumpAndSettle();

      await expectLater(tester, meetsGuideline(textContrastGuideline));
    });
  }

  test('Theme exposes the specified custom colors', () {
    final darkColors = AppTheme.dark.extension<StencilColors>()!;

    expect(AppTheme.dark.colorScheme.primary, const Color(0xFF00639B));
    expect(darkColors.selectedAndLink, const Color(0xFF96CCFF));
    expect(darkColors.filledButtonOnPrimaryContainer, const Color(0xFF96CCFF));
    expect(
      darkColors.onFilledButtonOnPrimaryContainer,
      const Color(0xFF001D32),
    );
  });
}
