import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/otayori_provider.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

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

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile == null) return;

    setState(() {
      _imageFile = File(pickedFile.path);
      _isProcessing = true; // 処理開始
      _recognizedText = '文字を認識中...';
    });

    // ★ここから下がML Kitの処理
    final inputImage = InputImage.fromFilePath(pickedFile.path);

    // 日本語を指定して、TextRecognizerのインスタンスを作成
    final textRecognizer = TextRecognizer(
      script: TextRecognitionScript.japanese,
    );

    // 画像から文字を認識
    final RecognizedText recognizedText = await textRecognizer.processImage(
      inputImage,
    );

    // 後処理
    await textRecognizer.close();

    setState(() {
      _recognizedText = recognizedText.text;
      _isProcessing = false; // 処理完了
    });
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
                  maxLines: 10,
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
                      _isProcessing
                          ? null
                          : () {
                            // ProviderのaddEventメソッドを呼び出す
                            ref
                                .read(otayoriEventProvider.notifier)
                                .addEvent(
                                  '解析したタイトル', // TODO: 抽出したテキストからタイトルを抜き出す
                                  '準備物', // TODO: カテゴリを選択できるようにする
                                  _selectedDate,
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
