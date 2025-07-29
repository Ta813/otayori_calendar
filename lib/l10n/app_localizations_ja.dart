// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get homeScreenTitle => 'おたよりカレンダー';

  @override
  String get otayoriListTitle => 'おたより一覧';

  @override
  String get addChild => 'こどもを追加';

  @override
  String get addEventManually => '予定を手動で追加';

  @override
  String get pleaseRegisterChildFirst => '先にお子さんを登録してください';

  @override
  String get event => '行事';

  @override
  String get preparation => '準備物';

  @override
  String get dateFormat => 'yyyy年MM月dd日';

  @override
  String get dailyScheduleTitle => 'の予定';

  @override
  String get seeOtayoriList => 'おたより一覧を見る';

  @override
  String get noEventsForThisDay => 'この日のおたよりはありません。';

  @override
  String get deleteEvent => '予定の削除';

  @override
  String get deleteConfirmation => 'この予定を削除しますか？';

  @override
  String get thisActionCannotBeUndone => 'この操作は元に戻せません。';

  @override
  String get cancel => 'キャンセル';

  @override
  String get delete => '削除';

  @override
  String get allMembers => '全員';

  @override
  String get scanCancelled => 'スキャンがキャンセルされたか、画像がありません。';

  @override
  String get scanError => 'スキャン中にエラーが発生しました';

  @override
  String get saveCancelledNoTitle => 'タイトルが入力されなかったので保存をキャンセルしました。';

  @override
  String get imageSaveFailed => '画像の保存に失敗しました';

  @override
  String get whichChildOtayori => 'どのお子さんのおたよりですか？';

  @override
  String get scanWithScanner => 'スキャナで撮影';

  @override
  String get selectFromGallery => 'ギャラリーから選択';

  @override
  String get deleteConfirmation2 => '削除の確認';

  @override
  String get deleteOtayoriConfirmation => 'このおたよりを削除しますか？\nこの操作は元に戻せません。';

  @override
  String get dateFormatSlash => 'yyyy/MM/dd';

  @override
  String get noTitle => 'タイトルなし';

  @override
  String get noOtayoriInCategory => 'このカテゴリのおたよりはありません。';

  @override
  String get dateFormatYearMonth => 'yyyy年M月';

  @override
  String get enterOtayoriTitle => 'おたよりのタイトルを入力';

  @override
  String get exampleOtayoriTitle => '例：7月号クラスだより';

  @override
  String get confirm => '決定';

  @override
  String get editTitle => 'タイトルの編集';

  @override
  String get newTitle => '新しいタイトル';

  @override
  String get save => '保存';

  @override
  String get addNewOtayori => '新しいおたよりを追加';

  @override
  String get selectColor => '色を選択';

  @override
  String get pleaseEnterName => '名前を入力してください';

  @override
  String get childRegistered => 'こどもが登録されました';

  @override
  String get deleteChildConfirmation => 'さんの情報を削除しますか？\nこの操作は元に戻せません。';

  @override
  String get editChild => 'こどもの編集';

  @override
  String get addChild2 => 'こどもの追加';

  @override
  String get newName => 'あたらしい名前';

  @override
  String get themeColor => 'テーマカラー';

  @override
  String get registeredChildren => '登録済みのこども';

  @override
  String get noOneRegisteredYet => 'まだ誰も登録されていません';

  @override
  String get saveThisContent => 'この内容で保存する';

  @override
  String get geminiPromptInstruction =>
      'この画像は学校からのおたよりです。\n画像から日付ごとの「行事」と「持っていくもの」を抽出し、以下のJSON形式の配列で出力してください。';

  @override
  String get errorOccurred => 'エラーが発生しました';

  @override
  String get pressButtonToStartAnalysis => '上のボタンを押して解析を開始してください。';

  @override
  String get extractionFailed => '行事・準備物は抽出できませんでした。';

  @override
  String get dateFormatHyphen => 'yyyy-MM-dd';

  @override
  String get itemNotFoundSkip => 'のアイテムが見つかりませんでした。スキップします。';

  @override
  String get savedToCalendar => '選択した項目をカレンダーに保存しました！';

  @override
  String get rewardedAdLoaded => 'リワード広告が読み込まれました。';

  @override
  String get adShowFailed => '広告の表示に失敗しました';

  @override
  String get rewardedAdLoadFailed => 'リワード広告の読み込みに失敗しました';

  @override
  String get error => 'エラー';

  @override
  String get adLoadFailedCheckNetwork =>
      '広告の読み込みに失敗しました。\nネットワーク接続などを確認して、もう一度お試しください。';

  @override
  String get ok => 'OK';

  @override
  String get watchAdToContinue => '広告を見て解析を続ける';

  @override
  String get watchAdDescription1 => 'AIによる解析を続けるには、短い動画広告をご覧いただく必要があります。';

  @override
  String get watchAdDescription2 => '広告を視聴しますか？';

  @override
  String get watchAd => '広告を見る';

  @override
  String get rewardEarned => 'リワードを獲得しました！';

  @override
  String get analyzeAndRegisterWithAi => 'AIで解析・登録';

  @override
  String get targetOtayori => '対象のおたより';

  @override
  String get analyzeThisOtayoriWithAi => 'このおたよりをAIで解析する';

  @override
  String get selected => '選択した';

  @override
  String get itemsToRegister => '件をカレンダーに登録';

  @override
  String get recognizingText => '文字を認識中...';

  @override
  String get preparingAd => '広告を準備しています...';

  @override
  String get monday => '月';

  @override
  String get tuesday => '火';

  @override
  String get wednesday => '水';

  @override
  String get thursday => '木';

  @override
  String get friday => '金';

  @override
  String get saturday => '土';

  @override
  String get sunday => '日';

  @override
  String get pleaseSelectTitleAndChild => 'タイトルとこどもを両方選択してください';

  @override
  String get editEvent => '予定の編集';

  @override
  String get addEvent => '予定の追加';

  @override
  String get emptyInputNoCandidates => '入力が空のため、候補リストは空です。';

  @override
  String get combinedCandidateList => '結合された候補リスト (全体)';

  @override
  String get title => 'タイトル';

  @override
  String get whoseEvent => 'だれの予定？';

  @override
  String get childRegistrationRequired => '先にお子さまの登録が必要です。';

  @override
  String get category => '種類は？';

  @override
  String get singleDay => '単日';

  @override
  String get period => '期間';

  @override
  String get date => '日付';

  @override
  String get start => '開始';

  @override
  String get end => '終了';

  @override
  String get preparationDefaultUniform => '制服(せいふく)';

  @override
  String get preparationDefaultGymClothes => '体操服(たいそうふく)';

  @override
  String get preparationDefaultSmock => 'スモック(すもっく)';

  @override
  String get preparationDefaultHat => '帽子(ぼうし)';

  @override
  String get preparationDefaultBag => 'かばん';

  @override
  String get preparationDefaultBackpack => 'リュック(りゅっく)';

  @override
  String get preparationDefaultIndoorShoes => '上靴(うわぐつ)';

  @override
  String get preparationDefaultOutdoorShoes => '外靴(そとぐつ)';

  @override
  String get preparationDefaultWaterBottle => '水筒(すいとう)';

  @override
  String get preparationDefaultLunchBox => 'お弁当(おべんとう)';

  @override
  String get preparationDefaultChopstickSet => '箸セット(はしせっと)';

  @override
  String get preparationDefaultCup => 'コップ(こっぷ)';

  @override
  String get preparationDefaultToothbrush => '歯ブラシ(はぶらし)';

  @override
  String get preparationDefaultTowel => 'タオル(たおる)';

  @override
  String get preparationDefaultHandkerchief => 'ハンカチ(はんかち)';

  @override
  String get preparationDefaultTissues => 'ティッシュ(てぃっしゅ)';

  @override
  String get preparationDefaultNotebook => '連絡帳(れんらくちょう)';

  @override
  String get preparationDefaultStickerBook => '出席シール帳(しゅっせきしーるちょう)';

  @override
  String get preparationDefaultNameTag => '名札(なふだ)';

  @override
  String get preparationDefaultHood => '防災頭巾(ぼうさいずきん)';

  @override
  String get preparationDefaultClothesBag => '着替え袋(きがえぶくろ)';

  @override
  String get preparationDefaultDiapers => 'おむつ';

  @override
  String get preparationDefaultWipes => 'おしりふき';

  @override
  String get eventDefaultFieldTrip => '遠足(えんそく)';

  @override
  String get eventDefaultSportsDay => '運動会(うんどうかい)';

  @override
  String get eventDefaultRecital => '発表会(はっぴょうかい)';

  @override
  String get eventDefaultMeeting => '保護者会(ほごしゃかい)';

  @override
  String get eventDefaultInterview => '個人面談(こじんめんだん)';

  @override
  String get eventDefaultBirthday => '誕生会(たんじょうかい)';

  @override
  String get eventDefaultMeasurement => '身体測定(しんたいそくてい)';

  @override
  String get eventDefaultDrill => '避難訓練(ひなんくんれん)';

  @override
  String get otayoriTitleDefaultClass => 'クラスだより(くらすだより)';

  @override
  String get otayoriTitleDefaultGrade => '学年だより(がくねんだより)';

  @override
  String get otayoriTitleDefaultSchool => '園だより(えんだより)';

  @override
  String get otayoriTitleDefaultLunch => '給食だより(きゅうしょくだより)';

  @override
  String get otayoriTitleDefaultHealth => '保健だより(ほけんだより)';

  @override
  String get otayoriTitleDefaultPta => 'PTAだより(ぴーてぃーえーだより)';

  @override
  String get otayoriTitleDefaultApril => '4月号クラスだより(4がつごうくらすだより)';

  @override
  String get otayoriTitleDefaultMay => '5月号クラスだより(5がつごうくらすだより)';

  @override
  String get otayoriTitleDefaultJune => '6月号クラスだより(6がつごうくらすだより)';

  @override
  String get otayoriTitleDefaultJuly => '7月号クラスだより(7がつごうくらすだより)';

  @override
  String get otayoriTitleDefaultAugust => '8月号クラスだより(8がつごうくらすだより)';

  @override
  String get otayoriTitleDefaultSeptember => '9月号クラスだより(9がつごうくらすだより)';

  @override
  String get otayoriTitleDefaultOctober => '10月号クラスだより(10がつごうくらすだより)';

  @override
  String get otayoriTitleDefaultNovember => '11月号クラスだより(11がつごうくらすだより)';

  @override
  String get otayoriTitleDefaultDecember => '12月号クラスだより(12がつごうくらすだより)';

  @override
  String get otayoriTitleDefaultJanuary => '1月号クラスだより(1がつごうくらすだより)';

  @override
  String get otayoriTitleDefaultFebruary => '2月号クラスだより(2がつごうくらすだより)';

  @override
  String get otayoriTitleDefaultMarch => '3月号クラスだより(3がつごうくらすだより)';

  @override
  String get settingsLanguage => '言語設定';

  @override
  String get settings => '設定';
}
