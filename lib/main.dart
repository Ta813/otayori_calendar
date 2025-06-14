import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/home_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  // 日本語ロケールをデフォルトに設定（DateFormat で日本語表示をしたい場合）
  Intl.defaultLocale = 'ja_JP';
  runApp(const ProviderScope(child: OtayoriPocketApp()));
}

class OtayoriPocketApp extends StatelessWidget {
  const OtayoriPocketApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'おたよりカレンダー',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
        scaffoldBackgroundColor: Colors.grey[50],
      ),
      // 日本語ローカライズを有効化
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ja', 'JP'),
        // 将来的に英語や他言語を追加したい場合はここに足す
        // Locale('en', 'US'),
      ],
      home: const HomeScreen(),
    );
  }
}
