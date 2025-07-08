import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // riverpodをインポート
import 'package:intl/intl.dart';

import '../models/otayori_event.dart'; // 作成したモデルをインポート
import '../providers/otayori_event_provider.dart'; // 作成したProviderをインポート
import '../widgets/calendar_widget.dart';
import 'package:table_calendar/table_calendar.dart';
import 'add_child_screen.dart';
import 'otayori_list_screen.dart';
import '../dialogs/add_event_dialog.dart';
import '../providers/child_provider.dart'; // こども情報のProviderをインポート

enum CalendarDisplayMode { event, preparation }

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

  CalendarDisplayMode _displayMode = CalendarDisplayMode.event;

  @override
  Widget build(BuildContext context) {
    // ref.watch() を使ってProviderからイベントのリストを取得
    // データが更新されると、このウィジェットは自動的に再描画される
    final List<OtayoriEvent> allEvents = ref.watch(otayoriEventProvider);

    // 選択中のカテゴリでイベントを絞り込む
    final String selectedCategory =
        _displayMode == CalendarDisplayMode.event ? '行事' : '準備物';

    final filteredEvents = allEvents.where((event) {
      return event.category == selectedCategory;
    }).toList();

    // --- ここが「データを渡す」ための変換処理 ---
    final eventsForCalendar = <DateTime, List<OtayoriEvent>>{};
    for (final event in filteredEvents) {
      final dateKey = DateTime.utc(
        event.date.year,
        event.date.month,
        event.date.day,
      );

      if (eventsForCalendar[dateKey] == null) {
        eventsForCalendar[dateKey] = [];
      }

      // イベントオブジェクトそのものを追加する
      eventsForCalendar[dateKey]!.add(event);
    }
    // --- 変換処理ここまで ---

    return Scaffold(
      appBar: AppBar(
        title: const Text('おたよりカレンダー'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AddChildScreen(),
                ),
              );
            },
            tooltip: 'こどもを追加',
          ),
          IconButton(
            icon: const Icon(Icons.edit_calendar_outlined), // アイコンを変更
            tooltip: '予定を手動で追加',
            onPressed: () {
              final children = ref.read(childProvider);
              if (children.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('先にお子さんを登録してください')),
                );
                return;
              }

              // ダイアログを表示する
              showDialog(
                context: context,
                builder: (context) {
                  return AddEventDialog(
                    // 状態として保持している _selectedDate を渡す
                    selectedDate: _selectedDate,
                    children: children,
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: SegmentedButton<CalendarDisplayMode>(
              segments: const <ButtonSegment<CalendarDisplayMode>>[
                ButtonSegment<CalendarDisplayMode>(
                  value: CalendarDisplayMode.event,
                  label: Text('行事'),
                  icon: Icon(Icons.celebration),
                ),
                ButtonSegment<CalendarDisplayMode>(
                  value: CalendarDisplayMode.preparation,
                  label: Text('準備物'),
                  icon: Icon(Icons.backpack),
                ),
              ],
              selected: {_displayMode},
              onSelectionChanged: (Set<CalendarDisplayMode> newSelection) {
                setState(() {
                  _displayMode = newSelection.first;
                });
              },
            ),
          ),
          CalendarWidget(
            key: ValueKey(_displayMode),
            selectedDay: _selectedDate,
            focusedDay: _focusedDay,
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            onDaySelected: (selectedDate, focusedDay) {
              // 日付が選択されたら、UIの状態を更新
              setState(() {
                _selectedDate = selectedDate;
                _focusedDay = focusedDay;
              });
            },
            // ★ 絞り込んだ後のデータを渡す
            events: eventsForCalendar,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '${DateFormat('yyyy年MM月dd日').format(_selectedDate)} の予定',
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
        child: const Icon(Icons.list_alt_rounded),
      ),
    );
  }

  // 選択された日のイベントリストを表示するウィジェット
  Widget _buildEventList(List<OtayoriEvent> allEvents) {
    // 1. 表示対象日のイベントを絞り込む (変更なし)
    final selectedDayEvents = allEvents.where((event) {
      return isSameDay(event.date, _selectedDate);
    }).toList();

    if (selectedDayEvents.isEmpty) {
      return const Center(child: Text('この日のおたよりはありません。'));
    }

    // 2. 子供の情報を取得
    final allChildren = ref.watch(childProvider);

    // 3. 子供IDとイベントリストのマップを作成
    final Map<String, List<OtayoriEvent>> eventsByChild = {};
    for (final event in selectedDayEvents) {
      if (eventsByChild[event.childId] == null) {
        eventsByChild[event.childId] = [];
      }
      eventsByChild[event.childId]!.add(event);
    }

    // 4. 表示する「子供カード」のリストを構築
    final List<Widget> childCards = [];
    for (final child in allChildren) {
      // その子供のイベントが存在する場合のみカードを作成
      if (eventsByChild.containsKey(child.id)) {
        final childEvents = eventsByChild[child.id]!;

        // 5. 行事/準備物でさらにグループ化 (変更なし)
        final Map<String, List<OtayoriEvent>> eventsByCategory = {};
        for (final event in childEvents) {
          if (eventsByCategory[event.category] == null) {
            eventsByCategory[event.category] = [];
          }
          eventsByCategory[event.category]!.add(event);
        }

        // 6. カテゴリごとの「ボックス」ウィジェットを作成
        final List<Widget> categoryBoxes = [];
        eventsByCategory.forEach((category, events) {
          categoryBoxes.add(
            // Expandedで横幅を均等に分ける
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: child.color),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // カテゴリ名 (行事, 準備物)
                    Text(
                      category,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                          fontSize: 18),
                    ),
                    Divider(
                      height: 10,
                      color: child.color,
                    ),
                    // 各イベント名
                    ...events.map((event) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // イベント名
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(top: 4.0, left: 4.0),
                              child: Text('・${event.title}'),
                            ),
                          ),
                          // 削除ボタン
                          IconButton(
                            icon: const Icon(Icons.close,
                                size: 18, color: Colors.grey),
                            onPressed: () {
                              // 削除確認ダイアログを表示
                              _showDeleteConfirmDialog(event.id);
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(), // アイコンの余白を最小化
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
          );
        });

        // 子供のカラー(透明度20%)と白を混ぜて、濁りのない明るい色を作成
        final Color lightBackgroundColor = Color.alphaBlend(
          child.color.withOpacity(0.5),
          Colors.white,
        );

        // 7. 最終的な「子供カード」をリストに追加
        childCards.add(
          Card(
            // ★★★ 1. 背景色を子供のカラーに設定（少し透明にする） ★★★
            color: lightBackgroundColor,

            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 1,
            clipBehavior: Clip.antiAlias, // カード内の子が角丸からはみ出ないようにする
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              // ★★★ 2. 枠線の色も子供のカラーに合わせる ★★★
              side: BorderSide(color: child.color, width: 1.5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 子供の名前
                  Text(
                    child.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      // メモ: もし背景色を濃くする場合は、文字色を白にする調整が必要です
                      // color: textColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // カテゴリボックスを横に並べる
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: categoryBoxes,
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }

    // 8. 作成したカードリストをListViewで表示
    return ListView(
      children: childCards,
    );
  }

  /// 削除確認ダイアログを表示するメソッド
  Future<void> _showDeleteConfirmDialog(String eventId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // ダイアログ外をタップしても閉じない
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('予定の削除'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('この予定を削除しますか？'),
                Text('この操作は元に戻せません。'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('キャンセル'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red, // 文字色を赤にして警告
              ),
              child: const Text('削除'),
              onPressed: () {
                // Riverpod経由で削除メソッドを呼び出す
                ref.read(otayoriEventProvider.notifier).removeEvent(eventId);
                Navigator.of(context).pop(); // ダイアログを閉じる
              },
            ),
          ],
        );
      },
    );
  }
}
