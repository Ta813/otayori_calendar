import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/home_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'providers/otayori_image_provider.dart';

void main() async {
  // Flutterの初期化
  WidgetsFlutterBinding.ensureInitialized();
  // 日本語ロケールをデフォルトに設定（DateFormat で日本語表示をしたい場合）
  Intl.defaultLocale = 'ja_JP';

  if (!kIsWeb) {
    await dotenv.load(fileName: ".env");
  }
  runApp(const ProviderScope(child: OtayoriPocketApp()));
}

class OtayoriPocketApp extends ConsumerWidget {
  const OtayoriPocketApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncValue = ref.watch(initializationProvider);

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
      home: asyncValue.when(
        data: (_) => const HomeScreen(), // 完了したらHomeScreenへ
        loading: () => const Scaffold(
            body: Center(child: CircularProgressIndicator())), // 読み込み中はローディング表示
        error: (err, stack) =>
            Scaffold(body: Center(child: Text('エラー: $err'))), // エラー時
      ),
    );
  }
}
