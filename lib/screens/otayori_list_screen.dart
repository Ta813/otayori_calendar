import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:cunning_document_scanner/cunning_document_scanner.dart';

import '../providers/otayori_image_provider.dart';
import 'package:intl/intl.dart';
import '../models/otayori_image.dart';

class OtayoriListScreen extends ConsumerWidget {
  const OtayoriListScreen({Key? key}) : super(key: key);

  // 【変更なし】ギャラリーから画像を選択＆保存するメソッド
  Future<void> _pickImageFromGallery(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    Navigator.of(context).pop(); // ボトムシートを閉じる
    await _saveImage(File(pickedFile.path), context, ref);
  }

  // スキャナで撮影＆保存するメソッド（Null安全対応版）
  Future<void> _scanAndSaveDocument(BuildContext context, WidgetRef ref) async {
    try {
      // ボトムシートが開いている場合は、スキャナを起動する前に閉じる
      if (context.mounted) Navigator.of(context).pop();

      // ★★★ 1. 返り値をnullableなリストとして受け取る ★★★
      final List<String>? imagePaths =
          await CunningDocumentScanner.getPictures();

      // ★★★ 2. nullまたは空のリストでないかチェックする ★★★
      // ユーザーがスキャンをキャンセルした場合などは、ここで処理を中断
      if (imagePaths == null || imagePaths.isEmpty) {
        print('スキャンがキャンセルされたか、画像がありません。');
        return;
      }

      // 最初の1枚のパスからFileオブジェクトを作成
      final scannedImage = File(imagePaths.first);

      // 保存処理を呼び出す
      await _saveImage(scannedImage, context, ref);
    } catch (e) {
      // エラー処理
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('スキャン中にエラーが発生しました: $e')),
      );
    }
  }

  // ★★★ 3. 画像を保存するロジックを共通メソッドに分離 ★★★
  Future<void> _saveImage(
    File imageFile,
    BuildContext context,
    WidgetRef ref,
  ) async {
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = p.basename(imageFile.path);
    final savedImagePath = p.join(appDir.path, fileName);

    try {
      await imageFile.copy(savedImagePath);
      ref.read(otayoriImageProvider.notifier).addImage(savedImagePath);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('画像の保存に失敗しました: $e')));
      }
    }
  }

  // ボトムシートを表示するメソッド
  void _showImageSourceActionSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.document_scanner), // アイコンを変更
                title: const Text('スキャナで撮影'),
                onTap: () {
                  // ★★★ 4. スキャナ起動メソッドを呼び出すように変更 ★★★
                  _scanAndSaveDocument(context, ref);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('ギャラリーから選択'),
                onTap: () {
                  _pickImageFromGallery(context, ref);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmDialog(
      BuildContext context, WidgetRef ref, String imageId) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('削除の確認'),
          content: const Text('このおたよりを削除しますか？\nこの操作は元に戻せません。'),
          actions: <Widget>[
            TextButton(
              child: const Text('キャンセル'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // ダイアログを閉じる
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('削除'),
              onPressed: () {
                // ProviderのremoveImageメソッドを呼び出して削除を実行
                ref.read(otayoriImageProvider.notifier).removeImage(imageId);
                Navigator.of(dialogContext).pop(); // ダイアログを閉じる
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<OtayoriImage> otayoriImages = ref.watch(otayoriImageProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('おたより一覧')),
      body: otayoriImages.isEmpty
          ? const Center(child: Text('まだおたよりがありません。\n右下のボタンから追加してください。'))
          : GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: otayoriImages.length,
              itemBuilder: (context, index) {
                final otayori = otayoriImages[index];
                return GestureDetector(
                  onTap: () {
                    // AI解析画面には、画像のパスを渡す
                    print('Tapped: ${otayori.imagePath}');
                    // TODO: Navigator.push(context, MaterialPageRoute(builder: (_) => AnalysisScreen(imagePath: otayori.imagePath)));
                  },
                  onLongPress: () {
                    _showDeleteConfirmDialog(context, ref, otayori.id);
                  },
                  // Stackを使って画像の上に日付を重ねる
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // 背景画像
                      Image.file(File(otayori.imagePath), fit: BoxFit.cover),
                      // 日付を表示する部分
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 2,
                            horizontal: 4,
                          ),
                          // 日付の背景を少し暗くする
                          color: Colors.black.withOpacity(0.6),
                          child: Text(
                            // intlパッケージを使って日付をフォーマット
                            DateFormat(
                              'yyyy/MM/dd',
                            ).format(otayori.savedDate),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showImageSourceActionSheet(context, ref),
        child: const Icon(Icons.add), // アイコンをシンプルに
        tooltip: '新しいおたよりを追加',
      ),
    );
  }
}
