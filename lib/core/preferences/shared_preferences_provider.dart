import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferencesWithCache>((ref) {
  throw UnimplementedError('SharedPreferencesWithCache must be overridden.');
});
