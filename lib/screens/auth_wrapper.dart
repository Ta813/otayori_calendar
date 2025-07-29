import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/child_provider.dart';
import 'add_child_screen.dart';
import 'home_screen.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // childProviderの状態を監視
    final children = ref.watch(childProvider);

    // main関数で既にデータの読み込みは完了している前提

    // こどものリストが空かどうかで表示する画面を分岐
    if (children.isEmpty) {
      // 1人も登録されていなければ、こども追加画面を表示
      // isFirstLaunchフラグを渡して、戻るボタンを非表示にする（ステップ3で実装）
      return const AddChildScreen(isFirstLaunch: true);
    } else {
      // 1人以上登録されていれば、ホーム画面を表示
      return const HomeScreen();
    }
  }
}
