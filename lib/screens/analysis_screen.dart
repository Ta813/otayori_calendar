import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../providers/otayori_event_provider.dart';
import '../helpers/admob_helper.dart';
import '../widgets/banner_ad_widget.dart';
import '../l10n/app_localizations.dart';

// 予定の種類を定義（行事 or 準備物）
enum EventItemType { event, item }

// 1行分の予定データを表すクラス
class SelectableEventItem {
  final String id;
  final DateTime date;
  final EventItemType type;
  final String content; // 行事名や持ち物名

  SelectableEventItem({
    required this.id,
    required this.date,
    required this.type,
    required this.content,
  });
}

// 一覧画面から渡される画像パスを受け取る
class AnalysisScreen extends ConsumerStatefulWidget {
  final String imagePath;
  final String childId;

  const AnalysisScreen({
    Key? key,
    required this.imagePath,
    required this.childId,
  }) : super(key: key);

  @override
  ConsumerState<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends ConsumerState<AnalysisScreen> {
  File? _imageFile;
  bool _isProcessing = false; // 処理中フラグを追加
  List<SelectableEventItem>? _scheduleItems;

  final Set<String> _selectedEventIds = {};

  static final String aPIKey = dotenv.env['GOOGLE_API_KEY']!;

  RewardedAd? _rewardedAd;
  int _analysisCount = 0;
  static const String _analysisCountKey = 'analysis_count'; // 保存キー

  bool _isWaitingForAd = false;

  // initStateで渡された画像パスをセット
  @override
  void initState() {
    super.initState();
    // 画面が作られた瞬間に、渡された画像パスを_imageFileにセットする
    _imageFile = File(widget.imagePath);
    _loadCountAndAd();
  }

  Future<void> _analyzeImageWithAI() async {
    // 画像ファイルがなければ処理を中断
    if (_imageFile == null) return;

    setState(() {
      _isProcessing = true;
      _scheduleItems = null; // 解析前に前の結果をクリア
    });

    try {
      // 1. モデルを初期化（★JSONモードを有効化）
      final model = GenerativeModel(
        model: 'gemini-1.5-flash-latest',
        apiKey: aPIKey,
        // この設定で、AIの応答が必ずJSON形式になるように強制する
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
        ),
      );

      // 画像ファイルをバイトデータとして読み込む
      final Uint8List imageBytes = await _imageFile!.readAsBytes();

      // 翻訳する必要のない「ルール部分」をDartコード内で定義
      const String jsonFormatRules = """

      【出力形式のルール】
      ・全体を [] の配列にしてください。
      ・各日付の情報を {} のオブジェクトにしてください。
      ・日付のキーは "date" とし、形式は "YYYY-MM-DD" にしてください。
      ・行事のキーは "events" とし、値は文字列の配列にしてください。
      ・持っていくもののキーは "items_to_bring" とし、値は文字列の配列にしてください。
      ・もし特定の日付に行事や持っていくものがなければ、空の配列 [] を入れてください。
      ・画像内に該当する情報が一つもなければ、空の配列 [] を返してください。
      """;

      // .arbファイルから翻訳された「指示部分」を取得
      final String localizedInstruction =
          AppLocalizations.of(context)!.geminiPromptInstruction;

      // 指示とルールを結合して、最終的なプロンプトを作成
      final prompt = TextPart(localizedInstruction + jsonFormatRules);
      final imagePart = DataPart('image/jpeg', imageBytes);

      // AIにリクエストを送信
      final response = await model.generateContent([
        Content.multi([prompt, imagePart]),
      ]);

      // 結果（JSON文字列）を解析し、変数に格納
      final String jsonString = response.text ?? '[]';
      final dynamic decodedData = jsonDecode(jsonString); // まずdynamic型で受け取る

      final List<dynamic> parsedList; // ループ処理で使う最終的なリスト

      // AIの応答がListかMapかで処理を分岐
      if (decodedData is List) {
        // 応答が期待通りリスト形式だった場合
        parsedList = decodedData;
      } else if (decodedData is Map) {
        // 応答がオブジェクト形式だった場合、それをリストでラップする
        parsedList = [decodedData];
      } else {
        // それ以外（空の応答など）の場合は空のリストとして扱う
        parsedList = [];
      }

      final uuid = Uuid();
      final List<SelectableEventItem> newScheduleItems = [];

      // 日付ごとのデータ（Map）でループ
      for (var dailyData in parsedList) {
        final mapData = dailyData as Map<String, dynamic>;
        final dateString = mapData['date'] as String? ?? '';
        DateTime? date = DateTime.tryParse(dateString);
        if (date == null) continue; // 日付が不正ならスキップ

        final int currentYear = DateTime.now().year; // 現在の年（2025）を取得
        // もし解析された年が現在の年より前だったら、現在の年に補正する
        // 例: "2024-07-22" -> "2025-07-22"
        if (date.year < currentYear) {
          date = DateTime(currentYear, date.month, date.day);
        }

        final List<String> events =
            List<String>.from(mapData['events'] as List? ?? []);
        final List<String> items =
            List<String>.from(mapData['items_to_bring'] as List? ?? []);

        // 「行事」リストをループして、個別のSelectableEventItemを作成
        for (var eventContent in events) {
          newScheduleItems.add(SelectableEventItem(
            id: uuid.v4(),
            date: date,
            type: EventItemType.event,
            content: eventContent,
          ));
        }

        // 「持ち物」リストをループして、個別のSelectableEventItemを作成
        for (var itemContent in items) {
          newScheduleItems.add(SelectableEventItem(
            id: uuid.v4(),
            date: date,
            type: EventItemType.item,
            content: itemContent,
          ));
        }
      }

      // 解析回数をここでインクリメント
      await _incrementAndSaveCount();

      setState(() {
        _scheduleItems = newScheduleItems; // 新しく生成したフラットなリストをstateに設定
        _isProcessing = false;
        // _recognizedTextの更新は不要になるか、デバッグ用に残しても良い
      });
    } on GenerativeAIException catch (e) {
      print('AIサーバーでエラーが発生しました: $e');
      // ユーザーに分かりやすいメッセージを表示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('サーバーが混み合っています。しばらくしてから、もう一度お試しください。'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      print('予期せぬエラーが発生しました: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('解析中に不明なエラーが発生しました。'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // 最後に必ず処理中フラグをfalseに戻す
      setState(() {
        _isProcessing = false;
      });
    }
  }

  String? _getCategory(String category, BuildContext context) {
    switch (category) {
      case '準備物':
        return AppLocalizations.of(context)!.preparation;
      case '行事':
        return AppLocalizations.of(context)!.event;
      default:
        return null;
    }
  }

  Widget _buildResultsList() {
    // 1. 初期状態（まだ解析していない）の場合 ★★★
    if (_scheduleItems == null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          // 初期状態では何も表示しないか、操作を促すメッセージを表示
          child: Text(
            AppLocalizations.of(context)!.pressButtonToStartAnalysis,
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    // 解析したが結果が空だった場合 ★★★
    if (_scheduleItems!.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            AppLocalizations.of(context)!.extractionFailed,
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _scheduleItems!.length,
      itemBuilder: (context, index) {
        // List<SelectableEventItem> からデータを取り出す
        final item = _scheduleItems![index];
        final bool isSelected = _selectedEventIds.contains(item.id);

        // 表示用の文字列を組み立てる
        final itemTypeString = item.type == EventItemType.event ? '行事' : '準備物';
        final formattedDate =
            DateFormat(AppLocalizations.of(context)!.dateFormatHyphen)
                .format(item.date);

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          child: CheckboxListTile(
            value: isSelected,
            onChanged: (bool? value) {
              setState(() {
                if (value == true) {
                  _selectedEventIds.add(item.id);
                } else {
                  _selectedEventIds.remove(item.id);
                }
              });
            },
            title: Text(item.content), // 行事名や持ち物名
            subtitle: Text(
                '$formattedDate - ${_getCategory(itemTypeString, context)}'), // 日付と種類
          ),
        );
      },
    );
  }

  Future<void> _saveSelectedItems() async {
    // 1. 選択されたIDのセットをループ処理
    for (String selectedId in _selectedEventIds) {
      // 2. IDに一致する予定アイテムを全リストから探す
      //    見つからなければ何もしない
      try {
        final itemToSave =
            _scheduleItems!.firstWhere((item) => item.id == selectedId);

        // 3. OtayoriEventの形式に合わせてProviderのaddEventを呼び出す
        ref.read(otayoriEventProvider.notifier).addEvent(
              itemToSave.content, // 行事名や持ち物名
              itemToSave.type == EventItemType.event ? '行事' : '準備物',
              itemToSave.date,
              widget.childId,
            );
      } catch (e) {
        // firstWhereで見つからなかった場合など
        print('ID: $selectedId のアイテムが見つかりませんでした。スキップします。');
        continue;
      }
    }

    // 4. 保存完了をユーザーに通知
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.savedToCalendar),
          backgroundColor: Colors.green,
        ),
      );
    }

    // 5. 一覧画面に戻る
    if (mounted) {
      // pop()を2回呼び出して、解析画面と一覧画面の両方を閉じてホームに戻る
      // または、pop()を1回にして一覧画面に戻るなど、挙動はお好みで調整
      Navigator.of(context).pop();
    }
  }

  /// 解析回数を読み込み、リワード広告を読み込むメソッド
  Future<void> _loadCountAndAd() async {
    final prefs = await SharedPreferences.getInstance();
    // mountedプロパティを使って、ウィジェットがまだ画面に存在するか確認
    if (!mounted) return;

    setState(() {
      _analysisCount = prefs.getInt(_analysisCountKey) ?? 0;
    });
    // 画面表示後、少しだけ待ってから最初の広告を読み込む
    await Future.delayed(const Duration(milliseconds: 500)); // 0.5秒待つ

    // 待っている間に画面が閉じられた可能性も考慮して、再度mountedをチェック
    if (mounted) {
      _loadRewardedAd(); // 広告を読み込む
    }
  }

  /// 解析回数を+1して保存するメソッド
  Future<void> _incrementAndSaveCount() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _analysisCount++;
    });
    await prefs.setInt(_analysisCountKey, _analysisCount);
  }

  /// リワード広告を読み込むメソッド
  void _loadRewardedAd() {
    AdMobHelper.loadRewardedAd(
      onAdLoaded: (ad) {
        print('リワード広告が読み込まれました。');
        // 広告のライフサイクルイベントを監視
        ad.fullScreenContentCallback = FullScreenContentCallback(
          onAdDismissedFullScreenContent: (ad) {
            ad.dispose(); // 広告が閉じられたら破棄
            _loadRewardedAd(); // 次の広告を読み込んでおく
          },
          onAdFailedToShowFullScreenContent: (ad, error) {
            print('広告の表示に失敗しました: $error');
            ad.dispose();
            _loadRewardedAd();
          },
        );
        setState(() {
          _rewardedAd = ad;
        });
      },
      onAdFailedToLoad: (error) {
        print('リワード広告の読み込みに失敗しました: $error');
        setState(() {
          _rewardedAd = null;
        });
      },
    );
  }

  void _handleAnalysisButtonPressed() async {
    if ((_analysisCount + 1) % 5 == 0) {
      final bool? wantsToWatchAd = await _showWatchAdDialog();

      // ユーザーが「広告を見る」を選択した場合のみ、次の処理に進む
      if (wantsToWatchAd == true) {
        // 広告が準備OKかチェック
        if (_rewardedAd != null) {
          _showRewardedAd();
        } else {
          // 広告が準備できていなければ、待機＆リトライ処理を開始
          _waitForAdAndShow();
        }
      }
    } else {
      _analyzeImageWithAI();
    }
  }

  /// 広告が読み込まれるのを待機し、表示するメソッド
  Future<void> _waitForAdAndShow() async {
    // タイムアウトを15秒に設定
    const timeout = Duration(seconds: 15);
    final stopwatch = Stopwatch()..start();

    // タイムアウトするか、広告が読み込まれるまでループ
    while (stopwatch.elapsed < timeout) {
      // 広告が読み込まれたかチェック
      if (_rewardedAd != null) {
        setState(() {
          _isWaitingForAd = false; // 待機モードを終了
        });
        _showRewardedAd(); // 広告を表示
        return; // 処理を正常終了
      }
      // 1秒待ってからリトライ
      await Future.delayed(const Duration(seconds: 1));
    }

    // --- タイムアウトした場合の処理 ---
    stopwatch.stop();
    setState(() {
      _isWaitingForAd = false; // 待機モードを終了
    });

    // ユーザーにタイムアウトしたことを伝えるダイアログを表示
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.error),
          content: Text(AppLocalizations.of(context)!.adLoadFailedCheckNetwork),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.ok),
            ),
          ],
        ),
      );
    }
  }

  /// 広告を視聴するかどうかをユーザーに尋ねるダイアログ
  Future<bool?> _showWatchAdDialog() {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // ダイアログ外をタップしても閉じない
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.watchAdToContinue),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(AppLocalizations.of(context)!.watchAdDescription1),
                SizedBox(height: 8),
                Text(AppLocalizations.of(context)!.watchAdDescription2),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // 「キャンセル」が押されたことを示すためにfalseを返す
                Navigator.of(context).pop(false);
              },
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                // 「広告を見る」が押されたことを示すためにtrueを返す
                Navigator.of(context).pop(true);
              },
              child: Text(AppLocalizations.of(context)!.watchAd),
            ),
          ],
        );
      },
    );
  }

  /// リワード広告を表示するメソッド
  void _showRewardedAd() {
    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        print('リワードを獲得しました！ item: ${reward.type}, amount: ${reward.amount}');
        // ★★★ ユーザーが広告を最後まで見たら、解析を実行 ★★★
        _analyzeImageWithAI();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // ScaffoldをStackでラップ
    return Stack(
      children: [
        // これまでのUIをScaffoldで構築
        Scaffold(
          appBar: AppBar(
              title:
                  Text(AppLocalizations.of(context)!.analyzeAndRegisterWithAi)),
          body: Column(
            // ★ body全体をColumnで囲む
            children: [
              Expanded(
                // ★ これまでのbody部分をExpandedで囲む
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ListView(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.targetOtayori,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      // 渡された画像を表示
                      if (_imageFile != null)
                        InteractiveViewer(
                          // ピンチイン・ピンチアウトで拡大縮小できるようになる
                          maxScale: 4.0, // 最大4倍までズーム可能（お好みで調整）
                          minScale: 1.0, // 最小スケール
                          child: Image.file(_imageFile!,
                              height: 550, fit: BoxFit.contain),
                        ),

                      const SizedBox(height: 16),

                      // --- AI解析実行ボタン ---
                      ElevatedButton.icon(
                        onPressed:
                            _isProcessing ? null : _handleAnalysisButtonPressed,
                        icon: const Icon(Icons.auto_awesome),
                        label: Text(AppLocalizations.of(context)!
                            .analyzeThisOtayoriWithAi),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),

                      const SizedBox(height: 16),
                      // --- 解析結果の表示 ---
                      _buildResultsList(),

                      const SizedBox(height: 24),

                      ElevatedButton.icon(
                        // _selectedEventIdsが空の場合はボタンを無効化(null)、そうでなければ保存処理を呼ぶ
                        onPressed: _selectedEventIds.isEmpty || _isProcessing
                            ? null
                            : () {
                                _saveSelectedItems(); // ★保存メソッド
                              },
                        icon: const Icon(Icons.calendar_today),
                        label: Text(
                            '${AppLocalizations.of(context)!.selected}${_selectedEventIds.length}${AppLocalizations.of(context)!.itemsToRegister}'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green, // 色を緑に
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: const SafeArea(
            child: SizedBox(
              width: double.infinity,
              height: 70, // AdSize.bannerの高さに合わせる
              child: BannerAdWidget(),
            ),
          ),
        ),

        // _isProcessingがtrueの時だけ、ローディング画面を上に重ねる
        if (_isProcessing)
          Container(
            // 画面全体を薄い黒で覆う
            color: Colors.black.withOpacity(0.5),
            // 中央にインジケーターとテキストを配置
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                  SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.recognizingText,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),

        // 広告待機中のローディング画面
        if (_isWaitingForAd)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                  SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.preparingAd,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
