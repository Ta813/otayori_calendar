import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/child.dart';

// こどものリストを提供するシンプルなProvider
final childProvider = Provider<List<Child>>((ref) {
  // TODO: 将来的には、こどもを追加・編集できる設定画面などからデータを取得する
  return [
    Child(id: 'child_1', name: 'たろう', color: Colors.blue),
    Child(id: 'child_2', name: 'はなこ', color: Colors.pink),
  ];
});
