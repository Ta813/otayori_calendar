import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../providers/child_provider.dart';
import '../models/child.dart';
import '../l10n/app_localizations.dart';

class AddChildScreen extends ConsumerStatefulWidget {
  final Child? childToEdit;
  final bool isFirstLaunch;

  const AddChildScreen({
    Key? key,
    this.childToEdit,
    this.isFirstLaunch = false,
  }) : super(key: key);

  @override
  ConsumerState<AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends ConsumerState<AddChildScreen> {
  final _nameController = TextEditingController();
  Color _selectedColor = Colors.blue;

  bool get _isEditMode => widget.childToEdit != null;

  @override
  void initState() {
    super.initState();

    // 編集モードの場合、フォームに初期値を設定
    if (_isEditMode) {
      final child = widget.childToEdit!;
      _nameController.text = child.name;
      _selectedColor = child.color;
    }
  }

  // ... (dispose, _showColorPickerDialog, _saveChildメソッドは変更なし) ...
  void _showColorPickerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.selectColor),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _selectedColor,
            onColorChanged: (color) {
              setState(() {
                _selectedColor = color;
              });
            },
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: <Widget>[
          ElevatedButton(
            child: Text(AppLocalizations.of(context)!.confirm),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void _saveChild() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.pleaseEnterName)),
      );
      return;
    }
    if (_isEditMode) {
      // 更新処理を呼び出す
      ref.read(childProvider.notifier).updateChild(
            id: widget.childToEdit!.id,
            name: _nameController.text,
            color: _selectedColor,
          );
    } else {
      // 新規追加処理
      ref.read(childProvider.notifier).addChild(
            name: _nameController.text,
            color: _selectedColor,
          );
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.childRegistered)),
    );
  }

  // ★★★ 1. 削除確認ダイアログを表示するメソッドを追加 ★★★
  void _showDeleteConfirmationDialog(Child child) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.deleteConfirmation2),
          content: Text(
              '「${child.name}」${AppLocalizations.of(context)!.deleteChildConfirmation}'),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.cancel),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // ダイアログを閉じる
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red, // 削除ボタンは赤色に
              ),
              child: Text(AppLocalizations.of(context)!.delete),
              onPressed: () {
                // Providerの削除メソッドを呼び出す
                ref.read(childProvider.notifier).removeChild(child.id);
                Navigator.of(dialogContext).pop(); // ダイアログを閉じる
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // ref.watchでこどものリストを取得
    final children = ref.watch(childProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !widget.isFirstLaunch,
        title: Text(_isEditMode
            ? AppLocalizations.of(context)!.editChild
            : AppLocalizations.of(context)!.addChild),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- 入力フォーム ---
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.newName, // ラベルを少し変更
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Text(AppLocalizations.of(context)!.themeColor,
                    style: TextStyle(fontSize: 16)),
                const Spacer(),
                GestureDetector(
                  onTap: _showColorPickerDialog,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _selectedColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // 登録済みリストのセクションを追加
            Text(
              AppLocalizations.of(context)!.registeredChildren,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 20),

            // リストが空の場合と、そうでない場合で表示を分ける
            children.isEmpty
                ? Center(
                    child: Text(
                      AppLocalizations.of(context)!.noOneRegisteredYet,
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : Wrap(
                    spacing: 8.0, // Chip間の横スペース
                    runSpacing: 4.0, // Chip間の縦スペース
                    children: children.map((child) {
                      // 背景色に合わせて文字色を白か黒に自動調整
                      final textColor = child.color.computeLuminance() > 0.5
                          ? Colors.black
                          : Colors.white;

                      return InputChip(
                        label: Text(child.name),
                        backgroundColor: child.color,
                        labelStyle: TextStyle(color: textColor),
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        onPressed: _isEditMode
                            ? null
                            : () {
                                // 新規追加モードの時だけ編集画面に遷移
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => AddChildScreen(
                                      childToEdit: child,
                                    ),
                                  ),
                                );
                              },
                        // 削除アイコンの色を設定
                        deleteIconColor: textColor.withOpacity(0.7),
                        // onDeletedコールバックで確認ダイアログを呼び出す
                        onDeleted: () {
                          _showDeleteConfirmationDialog(child);
                        },
                      );
                    }).toList(),
                  ),

            const Spacer(),
            ElevatedButton(
              onPressed: _saveChild,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(AppLocalizations.of(context)!.saveThisContent),
            ),
          ],
        ),
      ),
    );
  }
}
