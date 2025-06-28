import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/child.dart';
import '../models/otayori_event.dart';
import '../providers/child_provider.dart';
import '../providers/otayori_event_provider.dart';

class CalendarWidget extends ConsumerWidget {
  final void Function(DateTime, DateTime)? onDaySelected;
  final DateTime selectedDay;
  final DateTime focusedDay;
  final Map<DateTime, List<Map<String, String>>> events;

  CalendarWidget({
    Key? key,
    required this.onDaySelected,
    required this.selectedDay,
    required this.focusedDay,
    required this.events,
  }) : super(key: key);

  final Map<String, Color> categoryColors = {
    '準備物': Colors.green,
    'イベント': Colors.orange,
  };

  Widget _buildCellContent(BuildContext context, WidgetRef ref, DateTime day,
      List<OtayoriEvent> events, TextStyle dayTextStyle) {
    final gyojiEvents =
        events.where((event) => event.category == '行事').toList();

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
          // 行事テキストを表示する部分
          Expanded(
            child: ListView(
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              children: gyojiEvents.map((event) {
                final children = ref.read(childProvider);
                final child = children.firstWhere(
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
          firstDay: DateTime.utc(2024, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: focusedDay,
          rowHeight: 100.0,

          //イベントローダーで、日付ごとのイベントリストを取得
          eventLoader: (day) {
            // ref.watchで全イベントリストを取得
            final allEvents = ref.watch(otayoriEventProvider);
            // その日のイベントだけをフィルタリングして返す
            return allEvents
                .where((event) => isSameDay(event.date, day))
                .toList();
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
              final events = ref
                  .read(otayoriEventProvider)
                  .where((e) => isSameDay(e.date, day))
                  .toList();
              // 背景なし、黒文字でコンテンツを生成
              return _buildCellContent(
                  context, ref, day, events, defaultTextStyle);
            },

            // 今日の日のビルダー
            todayBuilder: (context, day, focusedDay) {
              final events = ref
                  .read(otayoriEventProvider)
                  .where((e) => isSameDay(e.date, day))
                  .toList();
              // 緑の背景を持つコンテナでラップする
              return Container(
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.3), // 少し薄い緑
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: _buildCellContent(
                    context, ref, day, events, defaultTextStyle), // 文字は黒のまま
              );
            },

            // 選択した日のビルダー
            selectedBuilder: (context, day, focusedDay) {
              final events = ref
                  .read(otayoriEventProvider)
                  .where((e) => isSameDay(e.date, day))
                  .toList();
              // 青の背景を持つコンテナでラップする
              return Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                // 背景が濃いので、文字は白にする
                child: _buildCellContent(
                    context, ref, day, events, highlightedTextStyle),
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
