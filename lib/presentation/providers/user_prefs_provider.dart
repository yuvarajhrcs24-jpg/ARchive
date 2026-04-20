import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:archive/domain/entities/user_prefs.dart';

class UserPrefsNotifier extends StateNotifier<UserPrefs> {
  UserPrefsNotifier() : super(const UserPrefs()) {
    _load();
  }

  static const _keyLanguage = 'pref_language';
  static const _keyDarkMode = 'pref_dark_mode';
  static const _keyCategories = 'pref_categories';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = UserPrefs(
      preferredLanguage: prefs.getString(_keyLanguage) ?? 'en',
      isDarkMode: prefs.getBool(_keyDarkMode) ?? true,
      selectedCategoryIds:
          prefs.getStringList(_keyCategories) ?? [],
    );
  }

  Future<void> setLanguage(String language) async {
    state = state.copyWith(preferredLanguage: language);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLanguage, language);
  }

  Future<void> setDarkMode(bool isDarkMode) async {
    state = state.copyWith(isDarkMode: isDarkMode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDarkMode, isDarkMode);
  }

  Future<void> toggleCategory(String categoryId) async {
    final current = List<String>.from(state.selectedCategoryIds);
    if (current.contains(categoryId)) {
      current.remove(categoryId);
    } else {
      current.add(categoryId);
    }
    state = state.copyWith(selectedCategoryIds: current);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyCategories, current);
  }
}

final userPrefsProvider =
    StateNotifierProvider<UserPrefsNotifier, UserPrefs>(
  (ref) => UserPrefsNotifier(),
);
