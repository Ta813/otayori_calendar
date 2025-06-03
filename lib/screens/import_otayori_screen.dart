import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tesseract_ocr/ocr_engine_config.dart';
import 'package:tesseract_ocr/tesseract_ocr.dart';
import 'package:intl/intl.dart';

class ImportOtayoriScreen extends StatefulWidget {
  const ImportOtayoriScreen({Key? key}) : super(key: key);

  @override
  State<ImportOtayoriScreen> createState() => _ImportOtayoriScreenState();
}

class _ImportOtayoriScreenState extends State<ImportOtayoriScreen> {
  File? _imageFile;
  String _recognizedText = '';
  DateTime _selectedDate = DateTime.now();
  final picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile == null) return;

    final imageFile = File(pickedFile.path);
    final recognizedText = await TesseractOcr.extractText(
      imageFile.path,
      config: const OCRConfig(language: 'jpn'),
    );

    setState(() {
      _imageFile = imageFile;
      _recognizedText = recognizedText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('おたより取り込み')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView(
          children: [
            Row(
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.photo_camera),
                  label: const Text('カメラで撮影'),
                  onPressed: () => _pickImage(ImageSource.camera),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.photo_library),
                  label: const Text('写真を選択'),
                  onPressed: () => _pickImage(ImageSource.gallery),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_imageFile != null)
              Image.file(_imageFile!, height: 200, fit: BoxFit.contain),
            const SizedBox(height: 16),
            TextFormField(
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
              subtitle: Text(DateFormat('yyyy年MM月dd日').format(_selectedDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
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
              icon: const Icon(Icons.save),
              label: const Text('保存する'),
              onPressed: () {
                // 保存処理（今後データベースに保存など）
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('おたよりを保存しました（仮）')));
              },
            ),
          ],
        ),
      ),
    );
  }
}
