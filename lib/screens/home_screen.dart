import 'package:flutter/material.dart';
import '../widgets/calendar_widget.dart';
import 'package:intl/intl.dart';
import 'import_otayori_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<DateTime, List<Map<String, String>>> events = {
    DateTime(2025, 6, 3): [
      {'category': '準備物', 'title': '水筒'},
      {'category': 'イベント', 'title': '運動会'},
    ],
    DateTime(2025, 6, 4): [
      {'category': '準備物', 'title': '水筒'},
    ],
  };
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('おたよりカレンダー')),
      body: Column(
        children: [
          SizedBox(
            height: 320, // ← カレンダー表示の高さを明示
            child: CalendarWidget(
              selectedDay: _selectedDate,
              focusedDay: _focusedDay,
              onDaySelected: (selectedDate) {
                setState(() {
                  _selectedDate = selectedDate;
                  _focusedDay = selectedDate;
                });
              },
              events: events,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '${DateFormat('yyyy年MM月dd日').format(_selectedDate)} のおたより',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          // ↓ 選択日に対応したおたよりリストをここに表示
          Expanded(child: Center(child: Text('おたより表示エリア'))),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // おたより取り込み画面へ遷移
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ImportOtayoriScreen(),
            ),
          );
        },
        tooltip: 'おたよりを追加',
        child: const Icon(Icons.add),
      ),
    );
  }
}
