import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/otayori_event.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _prefsKey = 'otayori_events';

// このNotifierがイベントリストの状態を管理する
class OtayoriEventNotifier extends StateNotifier<List<OtayoriEvent>> {
  OtayoriEventNotifier() : super([]);

  // データを読み込むメソッド
  Future<void> loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonStringList = prefs.getStringList(_prefsKey) ?? [];
    state = jsonStringList
        .map((jsonString) => OtayoriEvent.fromJson(jsonString))
        .toList();
  }

  // データを保存するメソッド
  Future<void> _saveEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonStringList =
        state.map((event) => event.toJson()).toList();
    await prefs.setStringList(_prefsKey, jsonStringList);
  }

  // 新しいイベントを追加するメソッド
  void addEvent(
    String title,
    String category,
    DateTime date,
    String childId,
  ) async {
    final newEvent = OtayoriEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // ユニークIDを生成
      title: title,
      category: category,
      date: date,
      childId: childId,
    );
    // state（状態）を新しいリストで更新する
    state = [...state, newEvent];
    await _saveEvents();
  }

  // 複数のイベントを一括で追加するメソッド
  Future<void> addMultipleEvents(List<OtayoriEvent> events) async {
    // 既存のリストと新しいイベントのリストを結合
    state = [...state, ...events];
    // 最後に一度だけ保存処理を呼ぶ
    await _saveEvents();
  }

  /// IDを指定してイベントを削除するメソッド
  Future<void> removeEvent(String eventId) async {
    // 指定されたID以外のイベントで新しいリストを再構築する
    state = state.where((event) => event.id != eventId).toList();
    // 変更を永続化する
    await _saveEvents();
  }
}

// このProviderを介してUIがNotifierにアクセスする
final otayoriEventProvider =
    StateNotifierProvider<OtayoriEventNotifier, List<OtayoriEvent>>((ref) {
  return OtayoriEventNotifier();
});
