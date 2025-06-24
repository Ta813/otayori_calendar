import 'dart:convert';

class OtayoriImage {
  final String id; // データを一意に識別するためのID
  final String imagePath; // 画像ファイルの保存パス
  final DateTime savedDate; // 保存された日時

  OtayoriImage({
    required this.id,
    required this.imagePath,
    required this.savedDate,
  });

  // OtayoriImageオブジェクト → Map に変換するメソッド
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imagePath': imagePath,
      'savedDate': savedDate.toIso8601String(), // DateTimeは文字列として保存
    };
  }

  // Map → OtayoriImageオブジェクト に変換するファクトリコンストラクタ
  factory OtayoriImage.fromMap(Map<String, dynamic> map) {
    return OtayoriImage(
      id: map['id'] ?? '',
      imagePath: map['imagePath'] ?? '',
      savedDate: DateTime.parse(map['savedDate'] ?? ''), // 文字列をDateTimeに戻す
    );
  }

  // toMapを使い、オブジェクトをJSON文字列に変換
  String toJson() => jsonEncode(toMap());

  // JSON文字列からオブジェクトを生成
  factory OtayoriImage.fromJson(String source) =>
      OtayoriImage.fromMap(jsonDecode(source));
}
