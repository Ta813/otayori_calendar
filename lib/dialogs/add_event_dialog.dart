// lib/dialogs/add_event_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // 日付フォーマットのためにインポート

import '../models/child.dart';
import '../models/otayori_event.dart';
import '../providers/otayori_event_provider.dart';
import '../l10n/app_localizations.dart';

// ★★★ 登録モードを定義するenum ★★★
enum RegistrationMode { single, range }

class AddEventDialog extends ConsumerStatefulWidget {
  final DateTime selectedDate;
  final List<Child> children;
  final OtayoriEvent? eventToEdit;

  const AddEventDialog({
    Key? key,
    required this.selectedDate,
    required this.children,
    this.eventToEdit,
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

  bool get _isEditMode => widget.eventToEdit != null;

  @override
  void initState() {
    super.initState();

    if (_isEditMode) {
      final event = widget.eventToEdit!;
      _titleController.text = event.title;
      _selectedChildId = event.childId;
      _category = event.category;
      // 期間や曜日の情報も同様に設定するロジックをここに追加
      // _mode = ...;
      // _startDate = ...;
      // _endDate = ...;
    } else {
      // 新規追加の場合の初期値設定
      if (widget.children.isNotEmpty) {
        _selectedChildId = widget.children.first.id;
      }
      _startDate = widget.selectedDate;
      _endDate = widget.selectedDate;
    }
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
        SnackBar(
            content:
                Text(AppLocalizations.of(context)!.pleaseSelectTitleAndChild)),
      );
      return;
    }

    // カッコ以降を取り除いて、きれいなタイトルにする
    final title = rawTitle.split('(').first;

    final childId = _selectedChildId!;

    if (_isEditMode) {
      // 更新処理を呼び出す
      ref.read(otayoriEventProvider.notifier).updateEvent(
            // OtayoriEventオブジェクトを渡す想定 (後でNotifierに作成)
            id: widget.eventToEdit!.id,
            title: _titleController.text,
            category: _category,
            childId: _selectedChildId!,
            date: widget.eventToEdit!.date, // 日付は変更しない想定
          );
    } else {
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
    }

    Navigator.of(context).pop();
  }

  String? _getWeekdayLabel(String WeekdayLabel, BuildContext context) {
    switch (WeekdayLabel) {
      case '月':
        return AppLocalizations.of(context)!.monday;
      case '火':
        return AppLocalizations.of(context)!.tuesday;
      case '水':
        return AppLocalizations.of(context)!.wednesday;
      case '木':
        return AppLocalizations.of(context)!.thursday;
      case '金':
        return AppLocalizations.of(context)!.friday;
      case '土':
        return AppLocalizations.of(context)!.saturday;
      case '日':
        return AppLocalizations.of(context)!.sunday;
      default:
        return null;
    }
  }

  String? _getCategory(String category, BuildContext context) {
    switch (category) {
      case '準備物':
        return AppLocalizations.of(context)!.preparation;
      case '行事':
        return AppLocalizations.of(context)!.event;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final allEvents = ref.watch(otayoriEventProvider);

    return AlertDialog(
      scrollable: true,
      title: Text(_isEditMode
          ? AppLocalizations.of(context)!.editEvent
          : AppLocalizations.of(context)!.addEvent),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 共通入力欄 ---
            Autocomplete<String>(
              displayStringForOption: (String option) =>
                  option.split('(').first,

              // 編集モードの場合、初期値を設定する
              initialValue: TextEditingValue(
                text: _isEditMode ? widget.eventToEdit!.title : '',
              ),
              optionsBuilder: (TextEditingValue textEditingValue) {
                final inputText = textEditingValue.text;

                if (inputText.isEmpty) {
                  print('入力が空のため、候補リストは空です。');
                  return const Iterable<String>.empty();
                }
                final historyItems = allEvents
                    .where((event) => event.category == _category)
                    .map((event) => event.title)
                    .toSet();
                final localizations = AppLocalizations.of(context)!;
                final defaultItems = _category == '行事'
                    ? [
                        localizations.eventDefaultFieldTrip,
                        localizations.eventDefaultSportsDay,
                        localizations.eventDefaultRecital,
                        localizations.eventDefaultMeeting,
                        localizations.eventDefaultInterview,
                        localizations.eventDefaultBirthday,
                        localizations.eventDefaultMeasurement,
                        localizations.eventDefaultDrill,
                      ]
                    : [
                        localizations.preparationDefaultUniform,
                        localizations.preparationDefaultGymClothes,
                        localizations.preparationDefaultSmock,
                        localizations.preparationDefaultHat,
                        localizations.preparationDefaultBag,
                        localizations.preparationDefaultBackpack,
                        localizations.preparationDefaultIndoorShoes,
                        localizations.preparationDefaultOutdoorShoes,
                        localizations.preparationDefaultWaterBottle,
                        localizations.preparationDefaultLunchBox,
                        localizations.preparationDefaultChopstickSet,
                        localizations.preparationDefaultCup,
                        localizations.preparationDefaultToothbrush,
                        localizations.preparationDefaultTowel,
                        localizations.preparationDefaultHandkerchief,
                        localizations.preparationDefaultTissues,
                        localizations.preparationDefaultNotebook,
                        localizations.preparationDefaultStickerBook,
                        localizations.preparationDefaultNameTag,
                        localizations.preparationDefaultHood,
                        localizations.preparationDefaultClothesBag
                      ];
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
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.title,
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
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.whoseEvent,
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
                child: Text(
                  AppLocalizations.of(context)!.childRegistrationRequired,
                  style: TextStyle(color: Colors.black54),
                ),
              ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _category,
              items: ['行事', '準備物']
                  .map((c) => DropdownMenuItem(
                      value: c, child: Text(_getCategory(c, context) ?? c)))
                  .toList(),
              onChanged: (v) => setState(() => _category = v!),
              decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.category,
                  border: OutlineInputBorder()),
            ),
            const Divider(height: 32),

            if (!_isEditMode) ...[
              // ★★★ 登録モード切替 ★★★
              SegmentedButton<RegistrationMode>(
                segments: [
                  ButtonSegment(
                      value: RegistrationMode.single,
                      label: Text(AppLocalizations.of(context)!.singleDay)),
                  ButtonSegment(
                      value: RegistrationMode.range,
                      label: Text(AppLocalizations.of(context)!.period)),
                ],
                selected: {_mode},
                onSelectionChanged: (newSelection) {
                  setState(() {
                    _mode = newSelection.first;
                  });
                },
              ),
              const SizedBox(height: 16),
            ],

            if (_mode == RegistrationMode.single)
              Text(
                  '${AppLocalizations.of(context)!.date}: ${DateFormat('yyyy/MM/dd').format(widget.selectedDate)}'),

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
                              '${AppLocalizations.of(context)!.start}: ${DateFormat('MM/dd').format(_startDate)}')),
                      const Text('〜'),
                      TextButton(
                          onPressed: () => _pickDate(false),
                          child: Text(
                              '${AppLocalizations.of(context)!.end}: ${DateFormat('MM/dd').format(_endDate)}')),
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
                          Text(_getWeekdayLabel(
                                  _weekdayLabels[index], context) ??
                              _weekdayLabels[index]),
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
            child: Text(AppLocalizations.of(context)!.cancel)),
        ElevatedButton(
            onPressed: _saveEvent,
            child: Text(AppLocalizations.of(context)!.save)),
      ],
    );
  }
}
