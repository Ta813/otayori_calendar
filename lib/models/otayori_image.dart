import 'dart:convert';

class OtayoriImage {
  final String id; // データを一意に識別するためのID
  final String imagePath; // 画像ファイルの保存パス
  final DateTime savedDate; // 保存された日時
  final String childId; // こどもID
  final String title;

  OtayoriImage({
    required this.id,
    required this.imagePath,
    required this.savedDate,
    required this.childId,
    required this.title,
  });

  // OtayoriImageオブジェクト → Map に変換するメソッド
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imagePath': imagePath,
      'savedDate': savedDate.toIso8601String(), // DateTimeは文字列として保存
      'childId': childId,
      'title': title,
    };
  }

  // Map → OtayoriImageオブジェクト に変換するファクトリコンストラクタ
  factory OtayoriImage.fromMap(Map<String, dynamic> map) {
    return OtayoriImage(
      id: map['id'] ?? '',
      imagePath: map['imagePath'] ?? '',
      savedDate: DateTime.parse(map['savedDate'] ?? ''), // 文字列をDateTimeに戻す
      childId: map['childId'] ?? '',
      title: map['title'] ?? '',
    );
  }

  OtayoriImage copyWith({
    String? id,
    String? imagePath,
    DateTime? savedDate,
    String? childId,
    String? title,
  }) {
    return OtayoriImage(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      savedDate: savedDate ?? this.savedDate,
      childId: childId ?? this.childId,
      title: title ?? this.title,
    );
  }

  // toMapを使い、オブジェクトをJSON文字列に変換
  String toJson() => jsonEncode(toMap());

  // JSON文字列からオブジェクトを生成
  factory OtayoriImage.fromJson(String source) =>
      OtayoriImage.fromMap(jsonDecode(source));
}
