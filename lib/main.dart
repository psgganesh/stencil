import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stencil/app.dart';
import 'package:stencil/core/preferences/shared_preferences_provider.dart';
import 'package:stencil/core/theme/theme_mode_notifier.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferencesWithCache.create(
    cacheOptions: const SharedPreferencesWithCacheOptions(
      allowList: {themeModePreferenceKey},
    ),
  );

  runApp(
    ProviderScope(
      retry: (_, _) => null,
      overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
      child: const MainApp(),
    ),
  );
}
