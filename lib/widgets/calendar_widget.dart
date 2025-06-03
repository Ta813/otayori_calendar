import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarWidget extends StatelessWidget {
  final void Function(DateTime)? onDaySelected;
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

  List<Map<String, String>> _getEventsForDay(DateTime day) {
    return events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  Widget _buildDayCell(
    DateTime day,
    List<Map<String, String>> eventsForDay, {
    Color? backgroundColor,
    Color borderColor = Colors.grey,
    double? cellWidth,
  }) {
    return Container(
      width: cellWidth, // ★ 横幅固定
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${day.day}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          ...eventsForDay.take(10).map((event) {
            final category = event['category'] ?? '';
            final title = event['title'] ?? '';
            final color = categoryColors[category] ?? Colors.black;

            return Text(
              title,
              style: TextStyle(fontSize: 9, backgroundColor: color),
              overflow: TextOverflow.ellipsis,
            );
          }),
          if (eventsForDay.length > 10)
            const Text('…', style: TextStyle(fontSize: 8)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cellWidth = constraints.maxWidth / 7; // 7日分で均等割り

        return TableCalendar(
          firstDay: DateTime.utc(2024, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: focusedDay,
          selectedDayPredicate: (day) => isSameDay(selectedDay, day),
          calendarFormat: CalendarFormat.week,
          onDaySelected: (selected, focused) {
            onDaySelected?.call(selected);
          },
          rowHeight: 240,
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            weekendStyle: TextStyle(
              color: Colors.red.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
          calendarStyle: const CalendarStyle(
            cellMargin: EdgeInsets.zero, // セル間余白なし
          ),
          calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, day, focusedDay) {
              final eventsForDay = _getEventsForDay(day);
              return _buildDayCell(
                day,
                eventsForDay,
                backgroundColor: Colors.transparent,
                borderColor: Colors.grey,
                cellWidth: cellWidth,
              );
            },
            selectedBuilder: (context, day, focusedDay) {
              final eventsForDay = _getEventsForDay(day);
              return _buildDayCell(
                day,
                eventsForDay,
                backgroundColor: Colors.blue[100],
                borderColor: Colors.blue,
                cellWidth: cellWidth,
              );
            },
            todayBuilder: (context, day, focusedDay) {
              final eventsForDay = _getEventsForDay(day);
              return _buildDayCell(
                day,
                eventsForDay,
                backgroundColor: Colors.green[100],
                borderColor: Colors.green,
                cellWidth: cellWidth,
              );
            },
          ),
        );
      },
    );
  }
}
