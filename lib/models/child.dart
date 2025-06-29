// lib/models/child.dart
import 'dart:convert';
import 'package:flutter/material.dart';

class Child {
  final String id;
  final String name;
  final Color color;

  Child({required this.id, required this.name, required this.color});

  // ★★★ ここから下を丸ごと追記 ★★★

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': color.value, // Colorオブジェクトはint値として保存
    };
  }

  factory Child.fromMap(Map<String, dynamic> map) {
    return Child(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      color: Color(map['color'] ?? Colors.grey.value), // int値からColorオブジェクトを復元
    );
  }

  String toJson() => json.encode(toMap());

  factory Child.fromJson(String source) => Child.fromMap(json.decode(source));
}
