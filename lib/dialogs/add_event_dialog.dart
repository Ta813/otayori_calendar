// lib/dialogs/add_event_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // 日付フォーマットのためにインポート

import '../models/child.dart';
import '../providers/otayori_event_provider.dart';
import '../constants/default_items.dart';

// ★★★ 登録モードを定義するenum ★★★
enum RegistrationMode { single, range }

class AddEventDialog extends ConsumerStatefulWidget {
  final DateTime selectedDate;
  final List<Child> children;

  const AddEventDialog({
    Key? key,
    required this.selectedDate,
    required this.children,
  }) : super(key: key);

  @override
  ConsumerState<AddEventDialog> createState() => _AddEventDialogState();
}

class _AddEventDialogState extends ConsumerState<AddEventDialog> {
  final TextEditingController _titleController = TextEditingController();
  // --- 共通の入力項目 ---
  String? _selectedChildId;
  String _category = '行事'; // デフォルトは行事

  // ★★★ 新しく追加する状態 ★★★
  RegistrationMode _mode = RegistrationMode.single; // デフォルトは単日モード
  late DateTime _startDate;
  late DateTime _endDate;
  // 月火水木金土日 のチェック状態 (true = 選択)
  final List<bool> _selectedWeekdays = List.generate(7, (_) => true);

  // 曜日のラベル
  final List<String> _weekdayLabels = ['月', '火', '水', '木', '金', '土', '日'];

  @override
  void initState() {
    super.initState();
    if (widget.children.isNotEmpty) {
      _selectedChildId = widget.children.first.id;
    }
    // 日付の初期値を設定
    _startDate = widget.selectedDate;
    _endDate = widget.selectedDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  // 日付選択ダイアログを呼び出すヘルパー関数
  Future<void> _pickDate(bool isStartDate) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          _startDate = pickedDate;
          // 開始日が終了日より後になったら、終了日も同じ日にする
          if (_startDate.isAfter(_endDate)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = pickedDate;
        }
      });
    }
  }

  // 保存処理
  void _saveEvent() {
    final rawTitle = _titleController.text; // 入力欄の生のテキスト
    if (rawTitle.isEmpty || _selectedChildId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('タイトルとこどもを両方選択してください')),
      );
      return;
    }

    // カッコ以降を取り除いて、きれいなタイトルにする
    final title = rawTitle.split('(').first;

    final childId = _selectedChildId!;

    if (_mode == RegistrationMode.single) {
      ref.read(otayoriEventProvider.notifier).addEvent(
            // 整形後のタイトルを渡す
            title,
            _category,
            widget.selectedDate,
            childId,
          );
    } else {
      for (var day = _startDate;
          day.isBefore(_endDate.add(const Duration(days: 1)));
          day = day.add(const Duration(days: 1))) {
        if (_selectedWeekdays[day.weekday - 1]) {
          ref.read(otayoriEventProvider.notifier).addEvent(
                // 整形後のタイトルを渡す
                title,
                _category,
                day,
                childId,
              );
        }
      }
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final allEvents = ref.watch(otayoriEventProvider);

    return AlertDialog(
      scrollable: true,
      title: const Text('予定の追加'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 共通入力欄 ---
            Autocomplete<String>(
              displayStringForOption: (String option) =>
                  option.split('(').first,
              optionsBuilder: (TextEditingValue textEditingValue) {
                // この部分は前回のデバッグコードのままでOKです
                final inputText = textEditingValue.text;

                if (inputText.isEmpty) {
                  print('入力が空のため、候補リストは空です。');
                  return const Iterable<String>.empty();
                }
                final historyItems = allEvents
                    .where((event) => event.category == _category)
                    .map((event) => event.title)
                    .toSet();
                final defaultItems = _category == '行事'
                    ? defaultEventItems
                    : defaultPreparationItems;
                final combinedItems =
                    {...historyItems, ...defaultItems}.toList();

                print('結合された候補リスト (全体): $combinedItems');

                final filteredOptions = combinedItems.where((String option) {
                  return option.toLowerCase().contains(inputText.toLowerCase());
                }).toList();

                return filteredOptions;
              },
              // 候補リストから項目が選択されたら、Stateのコントローラも更新
              onSelected: (String selection) {
                final title = selection.split('(').first;
                _titleController.text = title;
              },
              // fieldViewBuilderの構成を修正
              fieldViewBuilder: (BuildContext context,
                  TextEditingController
                      fieldTextEditingController, // これがAutocomplete管理下のコントローラ
                  FocusNode fieldFocusNode,
                  VoidCallback onFieldSubmitted) {
                return TextField(
                  // ★ ここでAutocomplete管理下のコントローラを渡す
                  controller: fieldTextEditingController,
                  focusNode: fieldFocusNode,
                  decoration: const InputDecoration(
                    labelText: 'タイトル',
                    border: OutlineInputBorder(),
                  ),
                  // ★ 入力が変更されるたびに、Stateのコントローラも更新
                  onChanged: (text) {
                    _titleController.text = text;
                  },
                );
              },
            ),
            const SizedBox(height: 16),

            // 子供が登録されている場合のみドロップダウンを表示
            if (widget.children.isNotEmpty)
              DropdownButtonFormField<String>(
                value: _selectedChildId,
                items: widget.children.map((child) {
                  return DropdownMenuItem(
                    value: child.id,
                    child: Text(child.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedChildId = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'だれの予定？',
                  border: OutlineInputBorder(),
                ),
                // こどもが一人しかいない場合は、変更不可にする（お好みで）
                // disabledHint: widget.children.length == 1
                //     ? Text(widget.children.first.name)
                //     : null,
              )
            // 子供が一人も登録されていない場合の表示
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '先にお子さまの登録が必要です。',
                  style: TextStyle(color: Colors.black54),
                ),
              ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _category,
              items: ['行事', '準備物']
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _category = v!),
              decoration: const InputDecoration(
                  labelText: '種類は？', border: OutlineInputBorder()),
            ),
            const Divider(height: 32),

            // ★★★ 登録モード切替 ★★★
            SegmentedButton<RegistrationMode>(
              segments: const [
                ButtonSegment(
                    value: RegistrationMode.single, label: Text('単日')),
                ButtonSegment(value: RegistrationMode.range, label: Text('期間')),
              ],
              selected: {_mode},
              onSelectionChanged: (newSelection) {
                setState(() {
                  _mode = newSelection.first;
                });
              },
            ),
            const SizedBox(height: 16),

            if (_mode == RegistrationMode.single)
              Text(
                  '日付: ${DateFormat('yyyy/MM/dd').format(widget.selectedDate)}'),

            if (_mode == RegistrationMode.range)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ★ 開始日・終了日ピッカー
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton(
                          onPressed: () => _pickDate(true),
                          child: Text(
                              '開始: ${DateFormat('MM/dd').format(_startDate)}')),
                      const Text('〜'),
                      TextButton(
                          onPressed: () => _pickDate(false),
                          child: Text(
                              '終了: ${DateFormat('MM/dd').format(_endDate)}')),
                    ],
                  ),

                  const SizedBox(height: 16),
                  // ★ 曜日チェックボックス
                  Wrap(
                    spacing: 0,
                    children: List.generate(7, (index) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_weekdayLabels[index]),
                          Checkbox(
                            value: _selectedWeekdays[index],
                            onChanged: (bool? value) {
                              setState(() {
                                _selectedWeekdays[index] = value!;
                              });
                            },
                          ),
                        ],
                      );
                    }),
                  ),
                ],
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル')),
        ElevatedButton(onPressed: _saveEvent, child: const Text('保存')),
      ],
    );
  }
}
