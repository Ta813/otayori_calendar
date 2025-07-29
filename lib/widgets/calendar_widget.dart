import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/child.dart';
import '../models/otayori_event.dart';
import '../providers/child_provider.dart';

class CalendarWidget extends ConsumerWidget {
  final void Function(DateTime, DateTime)? onDaySelected;
  final DateTime selectedDay;
  final DateTime focusedDay;
  final Map<DateTime, List<OtayoriEvent>> events;
  final void Function(DateTime)? onPageChanged;
  final String? locale;

  CalendarWidget({
    Key? key,
    required this.onDaySelected,
    required this.selectedDay,
    this.onPageChanged,
    required this.focusedDay,
    required this.events,
    this.locale,
  }) : super(key: key);

  Widget _buildCellContent(BuildContext context, WidgetRef ref, DateTime day,
      List<OtayoriEvent> events, TextStyle dayTextStyle) {
    // 1. 全ての子供のリストを取得（これが基準の並び順になる）
    final allChildren = ref.read(childProvider);

    // 2. 受け取ったイベントリストを、子供の並び順を元にソートする
    events.sort((eventA, eventB) {
      // 3. 各イベントの子供が、全子供リストの何番目にいるかを取得
      final indexA =
          allChildren.indexWhere((child) => child.id == eventA.childId);
      final indexB =
          allChildren.indexWhere((child) => child.id == eventB.childId);

      // 4. インデックス番号を比較して並び順を決定する
      return indexA.compareTo(indexB);
    });

    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 日付の数字
          Text(
            '${day.day}',
            style: dayTextStyle,
          ),
          const SizedBox(height: 2),
          // テキストを表示する部分
          Expanded(
            child: ListView(
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              children: events.map((event) {
                final child = allChildren.firstWhere(
                  (c) => c.id == event.childId,
                  orElse: () => Child(id: '', name: '', color: Colors.grey),
                );

                return Container(
                  margin: const EdgeInsets.only(bottom: 2.0),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 2.0, vertical: 1.0),
                  decoration: BoxDecoration(
                    color: child.color,
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Text(
                    event.title,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const defaultTextStyle = TextStyle(fontSize: 14, color: Colors.black);
    const highlightedTextStyle =
        TextStyle(fontSize: 14, color: Colors.white); // 背景色がつく日のテキスト色

    return LayoutBuilder(
      builder: (context, constraints) {
        return TableCalendar(
          locale: locale,
          firstDay: DateTime.utc(2024, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: focusedDay,
          rowHeight: 100.0,
          headerStyle: const HeaderStyle(
            // 週/月 切り替えボタンを非表示にする
            formatButtonVisible: false,
            // ついでにタイトルも中央寄せに
            titleCentered: true,
          ),
          onPageChanged: onPageChanged,
          //イベントローダーで、日付ごとのイベントリストを取得
          eventLoader: (day) {
            final dateKey = DateTime.utc(day.year, day.month, day.day);
            return events[dateKey] ?? [];
          },

          selectedDayPredicate: (day) => isSameDay(selectedDay, day),
          calendarFormat: CalendarFormat.week,
          onDaySelected: (selected, focused) {
            onDaySelected?.call(selected, focused);
          },
          daysOfWeekStyle: DaysOfWeekStyle(
            weekendStyle: TextStyle(
              color: Colors.red.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
          calendarBuilders: CalendarBuilders(
            // 通常の日のビルダー
            defaultBuilder: (context, day, focusedDay) {
              final dateKey = DateTime.utc(day.year, day.month, day.day);
              final dailyEvents = events[dateKey] ?? []; // マップから取得
              // 背景なし、黒文字でコンテンツを生成
              return _buildCellContent(
                  context, ref, day, dailyEvents, defaultTextStyle);
            },

            // 今日の日のビルダー
            todayBuilder: (context, day, focusedDay) {
              final dateKey = DateTime.utc(day.year, day.month, day.day);
              final dailyEvents = events[dateKey] ?? []; // マップから取得
              // 緑の背景を持つコンテナでラップする
              return Container(
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.3), // 少し薄い緑
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: _buildCellContent(context, ref, day, dailyEvents,
                    defaultTextStyle), // 文字は黒のまま
              );
            },

            // 選択した日のビルダー
            selectedBuilder: (context, day, focusedDay) {
              final dateKey = DateTime.utc(day.year, day.month, day.day);
              final dailyEvents = events[dateKey] ?? []; // マップから取得
              // 青の背景を持つコンテナでラップする
              return Container(
                decoration: BoxDecoration(
                  color: Colors.lightBlue[200],
                  borderRadius: BorderRadius.circular(8.0),
                ),
                // 背景が濃いので、文字は白にする
                child: _buildCellContent(
                    context, ref, day, dailyEvents, highlightedTextStyle),
              );
            },
            markerBuilder: (context, date, events) {
              // 空のWidgetを返してマーカーを描画しないようにする
              return Container();
            },
          ),
        );
      },
    );
  }
}
