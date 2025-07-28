import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('zh')
  ];

  /// ホーム画面のタイトル
  ///
  /// In ja, this message translates to:
  /// **'おたよりカレンダー'**
  String get homeScreenTitle;

  /// No description provided for @otayoriListTitle.
  ///
  /// In ja, this message translates to:
  /// **'おたより一覧'**
  String get otayoriListTitle;

  /// No description provided for @addChild.
  ///
  /// In ja, this message translates to:
  /// **'こどもを追加'**
  String get addChild;

  /// No description provided for @addEventManually.
  ///
  /// In ja, this message translates to:
  /// **'予定を手動で追加'**
  String get addEventManually;

  /// No description provided for @pleaseRegisterChildFirst.
  ///
  /// In ja, this message translates to:
  /// **'先にお子さんを登録してください'**
  String get pleaseRegisterChildFirst;

  /// No description provided for @event.
  ///
  /// In ja, this message translates to:
  /// **'行事'**
  String get event;

  /// No description provided for @preparation.
  ///
  /// In ja, this message translates to:
  /// **'準備物'**
  String get preparation;

  /// No description provided for @dateFormat.
  ///
  /// In ja, this message translates to:
  /// **'yyyy年MM月dd日'**
  String get dateFormat;

  /// No description provided for @dailyScheduleTitle.
  ///
  /// In ja, this message translates to:
  /// **'の予定'**
  String get dailyScheduleTitle;

  /// No description provided for @seeOtayoriList.
  ///
  /// In ja, this message translates to:
  /// **'おたより一覧を見る'**
  String get seeOtayoriList;

  /// No description provided for @noEventsForThisDay.
  ///
  /// In ja, this message translates to:
  /// **'この日のおたよりはありません。'**
  String get noEventsForThisDay;

  /// No description provided for @deleteEvent.
  ///
  /// In ja, this message translates to:
  /// **'予定の削除'**
  String get deleteEvent;

  /// No description provided for @deleteConfirmation.
  ///
  /// In ja, this message translates to:
  /// **'この予定を削除しますか？'**
  String get deleteConfirmation;

  /// No description provided for @thisActionCannotBeUndone.
  ///
  /// In ja, this message translates to:
  /// **'この操作は元に戻せません。'**
  String get thisActionCannotBeUndone;

  /// No description provided for @cancel.
  ///
  /// In ja, this message translates to:
  /// **'キャンセル'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In ja, this message translates to:
  /// **'削除'**
  String get delete;

  /// No description provided for @allMembers.
  ///
  /// In ja, this message translates to:
  /// **'全員'**
  String get allMembers;

  /// No description provided for @scanCancelled.
  ///
  /// In ja, this message translates to:
  /// **'スキャンがキャンセルされたか、画像がありません。'**
  String get scanCancelled;

  /// No description provided for @scanError.
  ///
  /// In ja, this message translates to:
  /// **'スキャン中にエラーが発生しました'**
  String get scanError;

  /// No description provided for @saveCancelledNoTitle.
  ///
  /// In ja, this message translates to:
  /// **'タイトルが入力されなかったので保存をキャンセルしました。'**
  String get saveCancelledNoTitle;

  /// No description provided for @imageSaveFailed.
  ///
  /// In ja, this message translates to:
  /// **'画像の保存に失敗しました'**
  String get imageSaveFailed;

  /// No description provided for @whichChildOtayori.
  ///
  /// In ja, this message translates to:
  /// **'どのお子さんのおたよりですか？'**
  String get whichChildOtayori;

  /// No description provided for @scanWithScanner.
  ///
  /// In ja, this message translates to:
  /// **'スキャナで撮影'**
  String get scanWithScanner;

  /// No description provided for @selectFromGallery.
  ///
  /// In ja, this message translates to:
  /// **'ギャラリーから選択'**
  String get selectFromGallery;

  /// No description provided for @deleteConfirmation2.
  ///
  /// In ja, this message translates to:
  /// **'削除の確認'**
  String get deleteConfirmation2;

  /// No description provided for @deleteOtayoriConfirmation.
  ///
  /// In ja, this message translates to:
  /// **'このおたよりを削除しますか？\nこの操作は元に戻せません。'**
  String get deleteOtayoriConfirmation;

  /// No description provided for @dateFormatSlash.
  ///
  /// In ja, this message translates to:
  /// **'yyyy/MM/dd'**
  String get dateFormatSlash;

  /// No description provided for @noTitle.
  ///
  /// In ja, this message translates to:
  /// **'タイトルなし'**
  String get noTitle;

  /// No description provided for @noOtayoriInCategory.
  ///
  /// In ja, this message translates to:
  /// **'このカテゴリのおたよりはありません。'**
  String get noOtayoriInCategory;

  /// No description provided for @dateFormatYearMonth.
  ///
  /// In ja, this message translates to:
  /// **'yyyy年M月'**
  String get dateFormatYearMonth;

  /// No description provided for @enterOtayoriTitle.
  ///
  /// In ja, this message translates to:
  /// **'おたよりのタイトルを入力'**
  String get enterOtayoriTitle;

  /// No description provided for @exampleOtayoriTitle.
  ///
  /// In ja, this message translates to:
  /// **'例：7月号クラスだより'**
  String get exampleOtayoriTitle;

  /// No description provided for @confirm.
  ///
  /// In ja, this message translates to:
  /// **'決定'**
  String get confirm;

  /// No description provided for @editTitle.
  ///
  /// In ja, this message translates to:
  /// **'タイトルの編集'**
  String get editTitle;

  /// No description provided for @newTitle.
  ///
  /// In ja, this message translates to:
  /// **'新しいタイトル'**
  String get newTitle;

  /// No description provided for @save.
  ///
  /// In ja, this message translates to:
  /// **'保存'**
  String get save;

  /// No description provided for @addNewOtayori.
  ///
  /// In ja, this message translates to:
  /// **'新しいおたよりを追加'**
  String get addNewOtayori;

  /// No description provided for @selectColor.
  ///
  /// In ja, this message translates to:
  /// **'色を選択'**
  String get selectColor;

  /// No description provided for @pleaseEnterName.
  ///
  /// In ja, this message translates to:
  /// **'名前を入力してください'**
  String get pleaseEnterName;

  /// No description provided for @childRegistered.
  ///
  /// In ja, this message translates to:
  /// **'こどもが登録されました'**
  String get childRegistered;

  /// No description provided for @deleteChildConfirmation.
  ///
  /// In ja, this message translates to:
  /// **'さんの情報を削除しますか？\nこの操作は元に戻せません。'**
  String get deleteChildConfirmation;

  /// No description provided for @editChild.
  ///
  /// In ja, this message translates to:
  /// **'こどもの編集'**
  String get editChild;

  /// No description provided for @addChild2.
  ///
  /// In ja, this message translates to:
  /// **'こどもの追加'**
  String get addChild2;

  /// No description provided for @newName.
  ///
  /// In ja, this message translates to:
  /// **'あたらしい名前'**
  String get newName;

  /// No description provided for @themeColor.
  ///
  /// In ja, this message translates to:
  /// **'テーマカラー'**
  String get themeColor;

  /// No description provided for @registeredChildren.
  ///
  /// In ja, this message translates to:
  /// **'登録済みのこども'**
  String get registeredChildren;

  /// No description provided for @noOneRegisteredYet.
  ///
  /// In ja, this message translates to:
  /// **'まだ誰も登録されていません'**
  String get noOneRegisteredYet;

  /// No description provided for @saveThisContent.
  ///
  /// In ja, this message translates to:
  /// **'この内容で保存する'**
  String get saveThisContent;

  /// No description provided for @geminiPromptInstruction.
  ///
  /// In ja, this message translates to:
  /// **'この画像は学校からのおたよりです。\n画像から日付ごとの「行事」と「持っていくもの」を抽出し、以下のJSON形式の配列で出力してください。'**
  String get geminiPromptInstruction;

  /// No description provided for @errorOccurred.
  ///
  /// In ja, this message translates to:
  /// **'エラーが発生しました'**
  String get errorOccurred;

  /// No description provided for @pressButtonToStartAnalysis.
  ///
  /// In ja, this message translates to:
  /// **'上のボタンを押して解析を開始してください。'**
  String get pressButtonToStartAnalysis;

  /// No description provided for @extractionFailed.
  ///
  /// In ja, this message translates to:
  /// **'行事・準備物は抽出できませんでした。'**
  String get extractionFailed;

  /// No description provided for @dateFormatHyphen.
  ///
  /// In ja, this message translates to:
  /// **'yyyy-MM-dd'**
  String get dateFormatHyphen;

  /// No description provided for @itemNotFoundSkip.
  ///
  /// In ja, this message translates to:
  /// **'のアイテムが見つかりませんでした。スキップします。'**
  String get itemNotFoundSkip;

  /// No description provided for @savedToCalendar.
  ///
  /// In ja, this message translates to:
  /// **'選択した項目をカレンダーに保存しました！'**
  String get savedToCalendar;

  /// No description provided for @rewardedAdLoaded.
  ///
  /// In ja, this message translates to:
  /// **'リワード広告が読み込まれました。'**
  String get rewardedAdLoaded;

  /// No description provided for @adShowFailed.
  ///
  /// In ja, this message translates to:
  /// **'広告の表示に失敗しました'**
  String get adShowFailed;

  /// No description provided for @rewardedAdLoadFailed.
  ///
  /// In ja, this message translates to:
  /// **'リワード広告の読み込みに失敗しました'**
  String get rewardedAdLoadFailed;

  /// No description provided for @error.
  ///
  /// In ja, this message translates to:
  /// **'エラー'**
  String get error;

  /// No description provided for @adLoadFailedCheckNetwork.
  ///
  /// In ja, this message translates to:
  /// **'広告の読み込みに失敗しました。\nネットワーク接続などを確認して、もう一度お試しください。'**
  String get adLoadFailedCheckNetwork;

  /// No description provided for @ok.
  ///
  /// In ja, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @watchAdToContinue.
  ///
  /// In ja, this message translates to:
  /// **'広告を見て解析を続ける'**
  String get watchAdToContinue;

  /// No description provided for @watchAdDescription1.
  ///
  /// In ja, this message translates to:
  /// **'AIによる解析を続けるには、短い動画広告をご覧いただく必要があります。'**
  String get watchAdDescription1;

  /// No description provided for @watchAdDescription2.
  ///
  /// In ja, this message translates to:
  /// **'広告を視聴しますか？'**
  String get watchAdDescription2;

  /// No description provided for @watchAd.
  ///
  /// In ja, this message translates to:
  /// **'広告を見る'**
  String get watchAd;

  /// No description provided for @rewardEarned.
  ///
  /// In ja, this message translates to:
  /// **'リワードを獲得しました！'**
  String get rewardEarned;

  /// No description provided for @analyzeAndRegisterWithAi.
  ///
  /// In ja, this message translates to:
  /// **'AIで解析・登録'**
  String get analyzeAndRegisterWithAi;

  /// No description provided for @targetOtayori.
  ///
  /// In ja, this message translates to:
  /// **'対象のおたより'**
  String get targetOtayori;

  /// No description provided for @analyzeThisOtayoriWithAi.
  ///
  /// In ja, this message translates to:
  /// **'このおたよりをAIで解析する'**
  String get analyzeThisOtayoriWithAi;

  /// No description provided for @selected.
  ///
  /// In ja, this message translates to:
  /// **'選択した'**
  String get selected;

  /// No description provided for @itemsToRegister.
  ///
  /// In ja, this message translates to:
  /// **'件をカレンダーに登録'**
  String get itemsToRegister;

  /// No description provided for @recognizingText.
  ///
  /// In ja, this message translates to:
  /// **'文字を認識中...'**
  String get recognizingText;

  /// No description provided for @preparingAd.
  ///
  /// In ja, this message translates to:
  /// **'広告を準備しています...'**
  String get preparingAd;

  /// No description provided for @monday.
  ///
  /// In ja, this message translates to:
  /// **'月'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In ja, this message translates to:
  /// **'火'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In ja, this message translates to:
  /// **'水'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In ja, this message translates to:
  /// **'木'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In ja, this message translates to:
  /// **'金'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In ja, this message translates to:
  /// **'土'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In ja, this message translates to:
  /// **'日'**
  String get sunday;

  /// No description provided for @pleaseSelectTitleAndChild.
  ///
  /// In ja, this message translates to:
  /// **'タイトルとこどもを両方選択してください'**
  String get pleaseSelectTitleAndChild;

  /// No description provided for @editEvent.
  ///
  /// In ja, this message translates to:
  /// **'予定の編集'**
  String get editEvent;

  /// No description provided for @addEvent.
  ///
  /// In ja, this message translates to:
  /// **'予定の追加'**
  String get addEvent;

  /// No description provided for @emptyInputNoCandidates.
  ///
  /// In ja, this message translates to:
  /// **'入力が空のため、候補リストは空です。'**
  String get emptyInputNoCandidates;

  /// No description provided for @combinedCandidateList.
  ///
  /// In ja, this message translates to:
  /// **'結合された候補リスト (全体)'**
  String get combinedCandidateList;

  /// No description provided for @title.
  ///
  /// In ja, this message translates to:
  /// **'タイトル'**
  String get title;

  /// No description provided for @whoseEvent.
  ///
  /// In ja, this message translates to:
  /// **'だれの予定？'**
  String get whoseEvent;

  /// No description provided for @childRegistrationRequired.
  ///
  /// In ja, this message translates to:
  /// **'先にお子さまの登録が必要です。'**
  String get childRegistrationRequired;

  /// No description provided for @category.
  ///
  /// In ja, this message translates to:
  /// **'種類は？'**
  String get category;

  /// No description provided for @singleDay.
  ///
  /// In ja, this message translates to:
  /// **'単日'**
  String get singleDay;

  /// No description provided for @period.
  ///
  /// In ja, this message translates to:
  /// **'期間'**
  String get period;

  /// No description provided for @date.
  ///
  /// In ja, this message translates to:
  /// **'日付'**
  String get date;

  /// No description provided for @start.
  ///
  /// In ja, this message translates to:
  /// **'開始'**
  String get start;

  /// No description provided for @end.
  ///
  /// In ja, this message translates to:
  /// **'終了'**
  String get end;

  /// No description provided for @preparationDefaultUniform.
  ///
  /// In ja, this message translates to:
  /// **'制服(せいふく)'**
  String get preparationDefaultUniform;

  /// No description provided for @preparationDefaultGymClothes.
  ///
  /// In ja, this message translates to:
  /// **'体操服(たいそうふく)'**
  String get preparationDefaultGymClothes;

  /// No description provided for @preparationDefaultSmock.
  ///
  /// In ja, this message translates to:
  /// **'スモック(すもっく)'**
  String get preparationDefaultSmock;

  /// No description provided for @preparationDefaultHat.
  ///
  /// In ja, this message translates to:
  /// **'帽子(ぼうし)'**
  String get preparationDefaultHat;

  /// No description provided for @preparationDefaultBag.
  ///
  /// In ja, this message translates to:
  /// **'かばん'**
  String get preparationDefaultBag;

  /// No description provided for @preparationDefaultBackpack.
  ///
  /// In ja, this message translates to:
  /// **'リュック(りゅっく)'**
  String get preparationDefaultBackpack;

  /// No description provided for @preparationDefaultIndoorShoes.
  ///
  /// In ja, this message translates to:
  /// **'上靴(うわぐつ)'**
  String get preparationDefaultIndoorShoes;

  /// No description provided for @preparationDefaultOutdoorShoes.
  ///
  /// In ja, this message translates to:
  /// **'外靴(そとぐつ)'**
  String get preparationDefaultOutdoorShoes;

  /// No description provided for @preparationDefaultWaterBottle.
  ///
  /// In ja, this message translates to:
  /// **'水筒(すいとう)'**
  String get preparationDefaultWaterBottle;

  /// No description provided for @preparationDefaultLunchBox.
  ///
  /// In ja, this message translates to:
  /// **'お弁当(おべんとう)'**
  String get preparationDefaultLunchBox;

  /// No description provided for @preparationDefaultChopstickSet.
  ///
  /// In ja, this message translates to:
  /// **'箸セット(はしせっと)'**
  String get preparationDefaultChopstickSet;

  /// No description provided for @preparationDefaultCup.
  ///
  /// In ja, this message translates to:
  /// **'コップ(こっぷ)'**
  String get preparationDefaultCup;

  /// No description provided for @preparationDefaultToothbrush.
  ///
  /// In ja, this message translates to:
  /// **'歯ブラシ(はぶらし)'**
  String get preparationDefaultToothbrush;

  /// No description provided for @preparationDefaultTowel.
  ///
  /// In ja, this message translates to:
  /// **'タオル(たおる)'**
  String get preparationDefaultTowel;

  /// No description provided for @preparationDefaultHandkerchief.
  ///
  /// In ja, this message translates to:
  /// **'ハンカチ(はんかち)'**
  String get preparationDefaultHandkerchief;

  /// No description provided for @preparationDefaultTissues.
  ///
  /// In ja, this message translates to:
  /// **'ティッシュ(てぃっしゅ)'**
  String get preparationDefaultTissues;

  /// No description provided for @preparationDefaultNotebook.
  ///
  /// In ja, this message translates to:
  /// **'連絡帳(れんらくちょう)'**
  String get preparationDefaultNotebook;

  /// No description provided for @preparationDefaultStickerBook.
  ///
  /// In ja, this message translates to:
  /// **'出席シール帳(しゅっせきしーるちょう)'**
  String get preparationDefaultStickerBook;

  /// No description provided for @preparationDefaultNameTag.
  ///
  /// In ja, this message translates to:
  /// **'名札(なふだ)'**
  String get preparationDefaultNameTag;

  /// No description provided for @preparationDefaultHood.
  ///
  /// In ja, this message translates to:
  /// **'防災頭巾(ぼうさいずきん)'**
  String get preparationDefaultHood;

  /// No description provided for @preparationDefaultClothesBag.
  ///
  /// In ja, this message translates to:
  /// **'着替え袋(きがえぶくろ)'**
  String get preparationDefaultClothesBag;

  /// No description provided for @preparationDefaultDiapers.
  ///
  /// In ja, this message translates to:
  /// **'おむつ'**
  String get preparationDefaultDiapers;

  /// No description provided for @preparationDefaultWipes.
  ///
  /// In ja, this message translates to:
  /// **'おしりふき'**
  String get preparationDefaultWipes;

  /// No description provided for @eventDefaultFieldTrip.
  ///
  /// In ja, this message translates to:
  /// **'遠足(えんそく)'**
  String get eventDefaultFieldTrip;

  /// No description provided for @eventDefaultSportsDay.
  ///
  /// In ja, this message translates to:
  /// **'運動会(うんどうかい)'**
  String get eventDefaultSportsDay;

  /// No description provided for @eventDefaultRecital.
  ///
  /// In ja, this message translates to:
  /// **'発表会(はっぴょうかい)'**
  String get eventDefaultRecital;

  /// No description provided for @eventDefaultMeeting.
  ///
  /// In ja, this message translates to:
  /// **'保護者会(ほごしゃかい)'**
  String get eventDefaultMeeting;

  /// No description provided for @eventDefaultInterview.
  ///
  /// In ja, this message translates to:
  /// **'個人面談(こじんめんだん)'**
  String get eventDefaultInterview;

  /// No description provided for @eventDefaultBirthday.
  ///
  /// In ja, this message translates to:
  /// **'誕生会(たんじょうかい)'**
  String get eventDefaultBirthday;

  /// No description provided for @eventDefaultMeasurement.
  ///
  /// In ja, this message translates to:
  /// **'身体測定(しんたいそくてい)'**
  String get eventDefaultMeasurement;

  /// No description provided for @eventDefaultDrill.
  ///
  /// In ja, this message translates to:
  /// **'避難訓練(ひなんくんれん)'**
  String get eventDefaultDrill;

  /// No description provided for @otayoriTitleDefaultClass.
  ///
  /// In ja, this message translates to:
  /// **'クラスだより(くらすだより)'**
  String get otayoriTitleDefaultClass;

  /// No description provided for @otayoriTitleDefaultGrade.
  ///
  /// In ja, this message translates to:
  /// **'学年だより(がくねんだより)'**
  String get otayoriTitleDefaultGrade;

  /// No description provided for @otayoriTitleDefaultSchool.
  ///
  /// In ja, this message translates to:
  /// **'園だより(えんだより)'**
  String get otayoriTitleDefaultSchool;

  /// No description provided for @otayoriTitleDefaultLunch.
  ///
  /// In ja, this message translates to:
  /// **'給食だより(きゅうしょくだより)'**
  String get otayoriTitleDefaultLunch;

  /// No description provided for @otayoriTitleDefaultHealth.
  ///
  /// In ja, this message translates to:
  /// **'保健だより(ほけんだより)'**
  String get otayoriTitleDefaultHealth;

  /// No description provided for @otayoriTitleDefaultPta.
  ///
  /// In ja, this message translates to:
  /// **'PTAだより(ぴーてぃーえーだより)'**
  String get otayoriTitleDefaultPta;

  /// No description provided for @otayoriTitleDefaultApril.
  ///
  /// In ja, this message translates to:
  /// **'4月号クラスだより(4がつごうくらすだより)'**
  String get otayoriTitleDefaultApril;

  /// No description provided for @otayoriTitleDefaultMay.
  ///
  /// In ja, this message translates to:
  /// **'5月号クラスだより(5がつごうくらすだより)'**
  String get otayoriTitleDefaultMay;

  /// No description provided for @otayoriTitleDefaultJune.
  ///
  /// In ja, this message translates to:
  /// **'6月号クラスだより(6がつごうくらすだより)'**
  String get otayoriTitleDefaultJune;

  /// No description provided for @otayoriTitleDefaultJuly.
  ///
  /// In ja, this message translates to:
  /// **'7月号クラスだより(7がつごうくらすだより)'**
  String get otayoriTitleDefaultJuly;

  /// No description provided for @otayoriTitleDefaultAugust.
  ///
  /// In ja, this message translates to:
  /// **'8月号クラスだより(8がつごうくらすだより)'**
  String get otayoriTitleDefaultAugust;

  /// No description provided for @otayoriTitleDefaultSeptember.
  ///
  /// In ja, this message translates to:
  /// **'9月号クラスだより(9がつごうくらすだより)'**
  String get otayoriTitleDefaultSeptember;

  /// No description provided for @otayoriTitleDefaultOctober.
  ///
  /// In ja, this message translates to:
  /// **'10月号クラスだより(10がつごうくらすだより)'**
  String get otayoriTitleDefaultOctober;

  /// No description provided for @otayoriTitleDefaultNovember.
  ///
  /// In ja, this message translates to:
  /// **'11月号クラスだより(11がつごうくらすだより)'**
  String get otayoriTitleDefaultNovember;

  /// No description provided for @otayoriTitleDefaultDecember.
  ///
  /// In ja, this message translates to:
  /// **'12月号クラスだより(12がつごうくらすだより)'**
  String get otayoriTitleDefaultDecember;

  /// No description provided for @otayoriTitleDefaultJanuary.
  ///
  /// In ja, this message translates to:
  /// **'1月号クラスだより(1がつごうくらすだより)'**
  String get otayoriTitleDefaultJanuary;

  /// No description provided for @otayoriTitleDefaultFebruary.
  ///
  /// In ja, this message translates to:
  /// **'2月号クラスだより(2がつごうくらすだより)'**
  String get otayoriTitleDefaultFebruary;

  /// No description provided for @otayoriTitleDefaultMarch.
  ///
  /// In ja, this message translates to:
  /// **'3月号クラスだより(3がつごうくらすだより)'**
  String get otayoriTitleDefaultMarch;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
