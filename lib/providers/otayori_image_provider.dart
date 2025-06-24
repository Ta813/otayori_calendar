import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart'; // uuidパッケージをインポート
import 'package:shared_preferences/shared_preferences.dart';

import '../models/otayori_image.dart'; // 作成したモデルをインポート

const _uuid = Uuid();
const _prefsKey = 'otayori_images';

// StateNotifierが管理する型を <List<String>> から <List<OtayoriImage>> に変更
class OtayoriImageNotifier extends StateNotifier<List<OtayoriImage>> {
  OtayoriImageNotifier() : super([]);

  Future<void> loadImages() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonStringList = prefs.getStringList(_prefsKey) ?? [];
    // JSON文字列のリストを、OtayoriImageオブジェクトのリストに変換
    state = jsonStringList
        .map((jsonString) => OtayoriImage.fromJson(jsonString))
        .toList();
  }

  Future<void> _saveImages() async {
    final prefs = await SharedPreferences.getInstance();
    // OtayoriImageオブジェクトのリストを、JSON文字列のリストに変換
    final List<String> jsonStringList =
        state.map((image) => image.toJson()).toList();
    await prefs.setStringList(_prefsKey, jsonStringList);
  }

  // addImageメソッドを修正
  void addImage(String path) async {
    // 新しいOtayoriImageオブジェクトを作成
    final newImage = OtayoriImage(
      id: _uuid.v4(), // v4メソッドでユニークなIDを生成
      imagePath: path,
      savedDate: DateTime.now(), // 現在日時を保存日として設定
    );

    // 同じパスの画像が既になければリストに追加
    if (!state.any((image) => image.imagePath == path)) {
      state = [...state, newImage];
      await _saveImages();
    }
  }

  Future<void> removeImage(String id) async {
    // 1. 削除対象のOtayoriImageオブジェクトを探す
    final imageToRemove = state.firstWhere((image) => image.id == id,
        orElse: () =>
            OtayoriImage(id: '', imagePath: '', savedDate: DateTime.now()));

    // 見つからなければ何もしない
    if (imageToRemove.id.isEmpty) return;

    try {
      // 2. 端末から画像ファイルを物理的に削除
      final file = File(imageToRemove.imagePath);
      if (await file.exists()) {
        await file.delete();
      }

      // 3. stateのリストから該当のオブジェクトを削除
      state = state.where((image) => image.id != id).toList();
      await _saveImages();
    } catch (e) {
      print('ファイルの削除に失敗しました: $e');
      // ここでエラーをユーザーに通知することも可能
    }
  }
}

// Providerが提供する型も同様に変更
final otayoriImageProvider =
    StateNotifierProvider<OtayoriImageNotifier, List<OtayoriImage>>((ref) {
  return OtayoriImageNotifier();
});

final initializationProvider = FutureProvider<void>((ref) async {
  // otayoriImageProviderのNotifierにアクセスし、loadImagesメソッドを呼び出す
  await ref.read(otayoriImageProvider.notifier).loadImages();
});
