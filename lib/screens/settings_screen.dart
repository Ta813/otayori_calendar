import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/locale_provider.dart';
import '../l10n/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 現在選択されているLocaleを取得
    final currentLocale = ref.watch(localeProvider);
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.settingsLanguage), // ここも多言語化するのが望ましい
      ),
      body: ListView(
        children: [
          // 日本語への切り替えタイル
          RadioListTile<Locale?>(
            title: const Text('日本語'),
            value: const Locale('ja'),
            groupValue: currentLocale,
            onChanged: (Locale? newLocale) {
              if (newLocale != null) {
                ref.read(localeProvider.notifier).setLocale(newLocale);
              }
            },
          ),
          // 英語への切り替えタイル
          RadioListTile<Locale?>(
            title: const Text('English'),
            value: const Locale('en'),
            groupValue: currentLocale,
            onChanged: (Locale? newLocale) {
              if (newLocale != null) {
                ref.read(localeProvider.notifier).setLocale(newLocale);
              }
            },
          ),
          // 中国語への切り替えタイル
          RadioListTile<Locale?>(
            title: const Text('中文 (简体)'),
            value: const Locale('zh'),
            groupValue: currentLocale,
            onChanged: (Locale? newLocale) {
              if (newLocale != null) {
                ref.read(localeProvider.notifier).setLocale(newLocale);
              }
            },
          ),
        ],
      ),
    );
  }
}
