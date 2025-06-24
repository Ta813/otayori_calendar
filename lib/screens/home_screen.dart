import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // riverpodをインポート
import 'package:intl/intl.dart';

import '../models/otayori_event.dart'; // 作成したモデルをインポート
import '../providers/otayori_provider.dart'; // 作成したProviderをインポート
import '../widgets/calendar_widget.dart';
import 'package:table_calendar/table_calendar.dart';
import 'otayori_list_screen.dart';

// StatefulWidget -> ConsumerStatefulWidget に変更
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  // State -> ConsumerState に変更
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

// State -> ConsumerState<HomeScreen> に変更
class _HomeScreenState extends ConsumerState<HomeScreen> {
  // 選択日などのUIの状態は、引き続きStateクラスで管理する
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    // ref.watch() を使ってProviderからイベントのリストを取得
    // データが更新されると、このウィジェットは自動的に再描画される
    final List<OtayoriEvent> allEvents = ref.watch(otayoriEventProvider);

    // --- ここが「データを渡す」ための変換処理 ---
    // CalendarWidgetが要求する Map<DateTime, List<Map<String, String>>> 形式に変換する
    final eventsForCalendar = <DateTime, List<Map<String, String>>>{};
    for (final event in allEvents) {
      // 時刻情報を無視した日付のみのDateTimeをキーにする
      final dateKey = DateTime.utc(
        event.date.year,
        event.date.month,
        event.date.day,
      );

      // その日付のキーがまだMapになければ、空のリストで初期化
      if (eventsForCalendar[dateKey] == null) {
        eventsForCalendar[dateKey] = [];
      }

      // リストにイベント情報を追加
      eventsForCalendar[dateKey]!.add({
        'title': event.title,
        'category': event.category,
      });
    }
    // --- 変換処理ここまで ---

    return Scaffold(
      appBar: AppBar(title: const Text('おたよりカレンダー')),
      body: Column(
        children: [
          CalendarWidget(
            selectedDay: _selectedDate,
            focusedDay: _focusedDay,
            onDaySelected: (selectedDate, focusedDay) {
              // 日付が選択されたら、UIの状態を更新
              setState(() {
                _selectedDate = selectedDate;
                _focusedDay = focusedDay;
              });
            },
            // ★★★ ここで変換したデータを渡す ★★★
            events: eventsForCalendar,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '${DateFormat('yyyy年MM月dd日').format(_selectedDate)} のおたより',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          // 選択日に対応したおたよりリストを表示
          Expanded(
            child: _buildEventList(allEvents), // 下にメソッドを追加
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // OtayoriListScreenに画面遷移する
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const OtayoriListScreen()),
          );
        },
        tooltip: 'おたより一覧を見る',
        child: const Icon(Icons.add),
      ),
    );
  }

  // 選択された日のイベントリストを表示するウィジェット
  Widget _buildEventList(List<OtayoriEvent> allEvents) {
    // allEventsから、選択されている日付のイベントのみを絞り込む
    final selectedDayEvents =
        allEvents.where((event) {
          return isSameDay(event.date, _selectedDate);
        }).toList();

    if (selectedDayEvents.isEmpty) {
      return const Center(child: Text('この日のおたよりはありません。'));
    }

    return ListView.builder(
      itemCount: selectedDayEvents.length,
      itemBuilder: (context, index) {
        final event = selectedDayEvents[index];
        return ListTile(
          leading: const Icon(Icons.circle, size: 12), // カテゴリに応じて色を変えても良い
          title: Text(event.title),
          subtitle: Text(event.category),
        );
      },
    );
  }
}
