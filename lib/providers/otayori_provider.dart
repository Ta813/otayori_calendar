import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/otayori_event.dart';

// このNotifierがイベントリストの状態を管理する
class OtayoriEventNotifier extends StateNotifier<List<OtayoriEvent>> {
  OtayoriEventNotifier()
    : super([
        // 初期データ（テスト用）
        OtayoriEvent(
          id: '1',
          title: '水筒',
          category: '準備物',
          date: DateTime(2025, 6, 3),
        ),
        OtayoriEvent(
          id: '2',
          title: '運動会',
          category: 'イベント',
          date: DateTime(2025, 6, 3),
        ),
      ]);

  // 新しいイベントを追加するメソッド
  void addEvent(String title, String category, DateTime date) {
    final newEvent = OtayoriEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // ユニークIDを生成
      title: title,
      category: category,
      date: date,
    );
    // state（状態）を新しいリストで更新する
    state = [...state, newEvent];
  }
}

// このProviderを介してUIがNotifierにアクセスする
final otayoriEventProvider =
    StateNotifierProvider<OtayoriEventNotifier, List<OtayoriEvent>>((ref) {
      return OtayoriEventNotifier();
    });
