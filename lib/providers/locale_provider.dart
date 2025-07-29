import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// SharedPreferencesで使うためのキー
const _prefsKey = 'selected_language_code';

// StateNotifierが管理する状態は、選択されたLocale
class LocaleNotifier extends StateNotifier<Locale?> {
  LocaleNotifier() : super(null) {
    // Notifierが作成されたら、すぐに保存済みの言語を読み込む
    _loadLocale();
  }

  /// 端末に保存されている言語コードを読み込み、stateを更新する
  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_prefsKey);
    if (languageCode != null) {
      state = Locale(languageCode);
    }
  }

  /// 新しい言語を設定し、端末に保存する
  Future<void> setLocale(Locale newLocale) async {
    state = newLocale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, newLocale.languageCode);
  }
}

// このProviderをUI側から利用する
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale?>((ref) {
  return LocaleNotifier();
});
