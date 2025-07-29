import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'providers/otayori_image_provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'firebase_options.dart';
import 'providers/locale_provider.dart';
import 'screens/auth_wrapper.dart';

void main() async {
  // Flutterの初期化
  WidgetsFlutterBinding.ensureInitialized();
  // Firebaseを初期化
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // FlutterフレームワークのエラーをCrashlyticsに送信
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  // Mobile Ads SDKを初期化
  await MobileAds.instance.initialize();
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
    // localeProviderを監視する
    final locale = ref.watch(localeProvider);
    final asyncValue = ref.watch(initializationProvider);

    return MaterialApp(
      title: 'おたよりカレンダー',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
        scaffoldBackgroundColor: Colors.grey[50],
      ),
      // 日本語ローカライズを有効化
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      home: asyncValue.when(
        data: (_) => const AuthWrapper(), // 完了したらAuthWrapperへ
        loading: () => const Scaffold(
            body: Center(child: CircularProgressIndicator())), // 読み込み中はローディング表示
        error: (err, stack) =>
            Scaffold(body: Center(child: Text('エラー: $err'))), // エラー時
      ),
    );
  }
}
