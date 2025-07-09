import 'dart:convert';

class OtayoriEvent {
  final String id;
  final String title;
  final String category;
  final DateTime date;
  final String childId;

  OtayoriEvent({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    required this.childId,
  });

  // OtayoriEventオブジェクト → Map に変換
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'date': date.toIso8601String(), // DateTimeは文字列に
      'childId': childId,
    };
  }

  // Map → OtayoriEventオブジェクト に変換
  factory OtayoriEvent.fromMap(Map<String, dynamic> map) {
    return OtayoriEvent(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      category: map['category'] ?? '',
      date: DateTime.parse(map['date'] ?? ''), // 文字列をDateTimeに
      childId: map['childId'] ?? '',
    );
  }

  OtayoriEvent copyWith({
    String? title,
    String? category,
    String? childId,
    DateTime? date,
  }) {
    return OtayoriEvent(
      id: this.id, // IDは変更しないので、元のIDをそのまま使う
      title: title ?? this.title,
      category: category ?? this.category,
      childId: childId ?? this.childId,
      date: date ?? this.date,
    );
  }

  // オブジェクトをJSON文字列に変換
  String toJson() => jsonEncode(toMap());

  // JSON文字列からオブジェクトを生成
  factory OtayoriEvent.fromJson(String source) =>
      OtayoriEvent.fromMap(jsonDecode(source));
}
