import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

// ─── Provider ────────────────────────────────────────────
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.dark) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(AppConstants.prefThemeMode);
    if (saved == 'light') {
      state = ThemeMode.light;
    } else if (saved == 'dark') {
      state = ThemeMode.dark;
    } else {
      state = ThemeMode.system;
    }
  }

  Future<void> toggle() async {
    final prefs = await SharedPreferences.getInstance();
    if (state == ThemeMode.dark) {
      state = ThemeMode.light;
      await prefs.setString(AppConstants.prefThemeMode, 'light');
    } else {
      state = ThemeMode.dark;
      await prefs.setString(AppConstants.prefThemeMode, 'dark');
    }
  }

  Future<void> setMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    state = mode;
    await prefs.setString(
      AppConstants.prefThemeMode,
      mode == ThemeMode.light
          ? 'light'
          : mode == ThemeMode.dark
          ? 'dark'
          : 'system',
    );
  }
}
