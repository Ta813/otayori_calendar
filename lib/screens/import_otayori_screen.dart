import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/otayori_provider.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ImportOtayoriScreen extends ConsumerStatefulWidget {
  // ConsumerStatefulWidget に変更
  const ImportOtayoriScreen({Key? key}) : super(key: key);
  @override
  ConsumerState<ImportOtayoriScreen> createState() =>
      _ImportOtayoriScreenState();
}

class _ImportOtayoriScreenState extends ConsumerState<ImportOtayoriScreen> {
  File? _imageFile;
  String _recognizedText = '画像を選択してください';
  DateTime _selectedDate = DateTime.now();
  bool _isProcessing = false; // 処理中フラグを追加
  final picker = ImagePicker();

  List<Map<String, dynamic>> _scheduleData = [];

  static final String aPIKey = dotenv.env['GOOGLE_API_KEY']!;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile == null) return;

    setState(() {
      _imageFile = File(pickedFile.path);
      _isProcessing = true;
      _recognizedText = 'AIが画像を解析し、予定を抽出中...';
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
      final Uint8List imageBytes = await pickedFile.readAsBytes();

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

      setState(() {
        // 画面のテキストフィールドで確認しやすいように、整形して表示する
        const jsonEncoder = JsonEncoder.withIndent('  ');
        _recognizedText = jsonEncoder.convert(parsedJson);

        // 構造化されたデータをState変数に格納
        _scheduleData = parsedJson.cast<Map<String, dynamic>>();

        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _recognizedText = 'エラーが発生しました: $e';
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // ScaffoldをStackでラップ
    return Stack(
      children: [
        // これまでのUIをScaffoldで構築
        Scaffold(
          appBar: AppBar(title: const Text('おたより取り込み')),
          body: Padding(
            padding: const EdgeInsets.all(12.0),
            child: ListView(
              children: [
                Row(
                  children: [
                    ElevatedButton.icon(
                      // 処理中はボタンを無効化
                      onPressed:
                          _isProcessing
                              ? null
                              : () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.photo_camera),
                      label: const Text('カメラで撮影'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      // 処理中はボタンを無効化
                      onPressed:
                          _isProcessing
                              ? null
                              : () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: const Text('写真を選択'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_imageFile != null)
                  Image.file(_imageFile!, height: 200, fit: BoxFit.contain),
                const SizedBox(height: 16),
                TextFormField(
                  // OCR結果(_recognizedText)が変わるたびにUIを更新するため、Keyを指定
                  key: Key(_recognizedText),
                  initialValue: _recognizedText,
                  maxLines: null, // 複数行入力可能
                  decoration: const InputDecoration(
                    labelText: '抽出されたおたよりの内容',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    _recognizedText = value;
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('日付'),
                  subtitle: Text(
                    DateFormat('yyyy年MM月dd日').format(_selectedDate),
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  // 処理中は日付選択を無効化
                  onTap:
                      _isProcessing
                          ? null
                          : () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                              locale: const Locale('ja'),
                            );
                            if (picked != null) {
                              setState(() => _selectedDate = picked);
                            }
                          },
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  // 処理中は保存ボタンを無効化
                  onPressed:
                      _isProcessing || _scheduleData.isEmpty
                          ? null
                          : () {
                            // ループでAIの解析結果を1件ずつ処理
                            for (var eventData in _scheduleData) {
                              final String dateString =
                                  eventData['date'] as String? ?? '';
                              final List<String> events = List<String>.from(
                                eventData['events'] as List? ?? [],
                              );
                              final List<String> items = List<String>.from(
                                eventData['items_to_bring'] as List? ?? [],
                              );

                              final DateTime? eventDate = DateTime.tryParse(
                                dateString,
                              );

                              if (eventDate == null) continue; // 日付が不正ならスキップ

                              // ★★★ 1. 「行事」をカレンダーに登録 ★★★
                              if (events.isNotEmpty) {
                                ref
                                    .read(otayoriEventProvider.notifier)
                                    .addEvent(
                                      '行事', // カテゴリを「行事」に設定
                                      events.join('\n'), // 複数の行事を改行で連結
                                      eventDate,
                                    );
                              }

                              // ★★★ 2. 「持ち物」をカレンダーに登録 ★★★
                              if (items.isNotEmpty) {
                                ref
                                    .read(otayoriEventProvider.notifier)
                                    .addEvent(
                                      '持ち物の確認', // タイトルは固定
                                      items.join(', '),
                                      eventDate,
                                    );
                              }
                            }

                            // 保存完了をユーザーに通知
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('おたよりの内容をカレンダーに保存しました！'),
                                backgroundColor: Colors.green,
                              ),
                            );

                            // 前の画面に戻る
                            Navigator.of(context).pop();
                          },
                  icon: const Icon(Icons.save),
                  label: const Text('保存する'),
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
