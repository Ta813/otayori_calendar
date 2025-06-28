import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../providers/otayori_event_provider.dart';

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
  List<SelectableEventItem> _scheduleItems = [];

  final Set<String> _selectedEventIds = {};

  static final String aPIKey = dotenv.env['GOOGLE_API_KEY']!;

  // initStateで渡された画像パスをセット
  @override
  void initState() {
    super.initState();
    // 画面が作られた瞬間に、渡された画像パスを_imageFileにセットする
    _imageFile = File(widget.imagePath);
  }

  Future<void> _analyzeImageWithAI() async {
    // 画像ファイルがなければ処理を中断
    if (_imageFile == null) return;

    setState(() {
      _isProcessing = true;
      _scheduleItems = []; // 解析前に前の結果をクリア
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

      // 2. 画像ファイルをバイトデータとして読み込む
      final Uint8List imageBytes = await _imageFile!.readAsBytes();

      // 3. プロンプト（AIへの指示）を修正
      final prompt = TextPart("""
      この画像は学校からのおたよりです。
      画像から日付ごとの「行事」と「持っていくもの」を抽出し、以下のJSON形式の配列で出力してください。

      【出力形式のルール】
      ・全体を [] の配列にしてください。
      ・各日付の情報を {} のオブジェクトにしてください。
      ・日付のキーは "date" とし、形式は "YYYY-MM-DD" にしてください。
      ・行事のキーは "events" とし、値は文字列の配列にしてください。
      ・持っていくもののキーは "items_to_bring" とし、値は文字列の配列にしてください。
      ・もし特定の日付に行事や持っていくものがなければ、空の配列 [] を入れてください。
      ・画像内に該当する情報が一つもなければ、空の配列 [] を返してください。
      """);
      final imagePart = DataPart('image/jpeg', imageBytes);

      // 4. AIにリクエストを送信
      final response = await model.generateContent([
        Content.multi([prompt, imagePart]),
      ]);

      // 5. 結果（JSON文字列）を解析し、変数に格納
      final String jsonString = response.text ?? '[]'; // 結果がnullなら空の配列にする
      final List<dynamic> parsedJson = jsonDecode(jsonString);
      final uuid = Uuid();

      final List<SelectableEventItem> newScheduleItems = [];

      // 日付ごとのデータ（Map）でループ
      for (var dailyData in parsedJson) {
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

      setState(() {
        _scheduleItems = newScheduleItems; // 新しく生成したフラットなリストをstateに設定
        _isProcessing = false;
        // _recognizedTextの更新は不要になるか、デバッグ用に残しても良い
      });
    } catch (e) {
      setState(() {
        print('エラーが発生しました: $e');
        _isProcessing = false;
      });
    }
  }

  Widget _buildResultsList() {
    if (_scheduleItems.isEmpty) {
      // 解析結果がなければ、メッセージを表示
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text("行事、準備物は抽出されていません。"), // 初期メッセージやエラーメッセージはここで表示
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _scheduleItems.length,
      itemBuilder: (context, index) {
        // List<SelectableEventItem> からデータを取り出す
        final item = _scheduleItems[index];
        final bool isSelected = _selectedEventIds.contains(item.id);

        // 表示用の文字列を組み立てる
        final itemTypeString = item.type == EventItemType.event ? '行事' : '準備物';
        final formattedDate = DateFormat('yyyy-MM-dd').format(item.date);

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
            subtitle: Text('$formattedDate - $itemTypeString'), // 日付と種類
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
            _scheduleItems.firstWhere((item) => item.id == selectedId);

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
        const SnackBar(
          content: Text('選択した項目をカレンダーに保存しました！'),
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

  @override
  Widget build(BuildContext context) {
    // ScaffoldをStackでラップ
    return Stack(
      children: [
        // これまでのUIをScaffoldで構築
        Scaffold(
          appBar: AppBar(title: const Text('AIで解析・登録')),
          body: Padding(
            padding: const EdgeInsets.all(12.0),
            child: ListView(
              children: [
                Text(
                  '対象のおたより',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                // 渡された画像を表示
                if (_imageFile != null)
                  Image.file(_imageFile!, height: 300, fit: BoxFit.contain),

                const SizedBox(height: 16),

                // --- AI解析実行ボタン ---
                ElevatedButton.icon(
                  onPressed: _isProcessing ? null : _analyzeImageWithAI,
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('このおたよりをAIで解析する'),
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
                  label: Text('選択した${_selectedEventIds.length}件をカレンダーに登録'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // 色を緑に
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),

        // _isProcessingがtrueの時だけ、ローディング画面を上に重ねる
        if (_isProcessing)
          Container(
            // 画面全体を薄い黒で覆う
            color: Colors.black.withOpacity(0.5),
            // 中央にインジケーターとテキストを配置
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                  SizedBox(height: 16),
                  Text(
                    '文字を認識中...',
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
