// lib/providers/child_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/child.dart';

const _uuid = Uuid();
const _childPrefsKey = 'children_list'; // 保存キー

class ChildNotifier extends StateNotifier<List<Child>> {
  ChildNotifier() : super([]); // 初期値は空リスト

  // ★★★ お子さんを追加するメソッド ★★★
  Future<void> addChild({required String name, required Color color}) async {
    final newChild = Child(
      id: _uuid.v4(),
      name: name,
      color: color,
    );
    state = [...state, newChild];
    await _saveChildren(); // state変更後に保存処理を呼ぶ
  }

  // ★★★ お子さんリストを保存するメソッド ★★★
  Future<void> _saveChildren() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonStringList =
        state.map((child) => child.toJson()).toList();
    await prefs.setStringList(_childPrefsKey, jsonStringList);
  }

  // ★★★ お子さんリストを読み込むメソッド ★★★
  Future<void> loadChildren() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStringList = prefs.getStringList(_childPrefsKey) ?? [];
    state =
        jsonStringList.map((jsonString) => Child.fromJson(jsonString)).toList();
  }

  // お子さんを削除するメソッド
  Future<void> removeChild(String childId) async {
    // 指定されたID以外の要素で新しいリストを作成する
    state = state.where((child) => child.id != childId).toList();
    await _saveChildren(); // 変更を保存
  }
}

final childProvider = StateNotifierProvider<ChildNotifier, List<Child>>((ref) {
  return ChildNotifier();
});
