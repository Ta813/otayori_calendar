import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:cunning_document_scanner/cunning_document_scanner.dart';

import '../providers/otayori_image_provider.dart';
import 'package:intl/intl.dart';
import '../models/otayori_image.dart';
import 'analysis_screen.dart';
import '../providers/child_provider.dart';
import '../models/child.dart';
import '../constants/default_otayori_titles.dart';

class OtayoriListScreen extends ConsumerStatefulWidget {
  const OtayoriListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OtayoriListScreen> createState() => _OtayoriListScreenState();
}

class _OtayoriListScreenState extends ConsumerState<OtayoriListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Tab> _tabs = []; // タブのリストをState変数として保持

  @override
  void initState() {
    super.initState();
    // initStateではref.readしか使えない
    final children = ref.read(childProvider);

    // タブのリストを一度だけ生成
    _tabs = <Tab>[
      const Tab(text: '全員'),
      ...children.map((child) => Tab(text: child.name)).toList(),
    ];

    // TabControllerの初期化も一度だけ行う
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // 【変更なし】ギャラリーから画像を選択＆保存するメソッド
  Future<void> _pickImageFromGallery(
      BuildContext context, WidgetRef ref, String childId) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    Navigator.of(context).pop(); // ボトムシートを閉じる
    await _saveImage(File(pickedFile.path), childId, context, ref);
  }

  // スキャナで撮影＆保存するメソッド（Null安全対応版）
  Future<void> _scanAndSaveDocument(
      BuildContext context, WidgetRef ref, String childId) async {
    try {
      // ボトムシートが開いている場合は、スキャナを起動する前に閉じる
      if (context.mounted) Navigator.of(context).pop();

      // ★★★ 1. 返り値をnullableなリストとして受け取る ★★★
      final List<String>? imagePaths =
          await CunningDocumentScanner.getPictures();

      // ★★★ 2. nullまたは空のリストでないかチェックする ★★★
      // ユーザーがスキャンをキャンセルした場合などは、ここで処理を中断
      if (imagePaths == null || imagePaths.isEmpty) {
        print('スキャンがキャンセルされたか、画像がありません。');
        return;
      }

      // 最初の1枚のパスからFileオブジェクトを作成
      final scannedImage = File(imagePaths.first);

      // 保存処理を呼び出す
      await _saveImage(scannedImage, childId, context, ref);
    } catch (e) {
      // エラー処理
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('スキャン中にエラーが発生しました: $e')),
      );
    }
  }

  // ★★★ 3. 画像を保存するロジックを共通メソッドに分離 ★★★
  Future<void> _saveImage(
    File imageFile,
    String childId,
    BuildContext context,
    WidgetRef ref,
  ) async {
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = p.basename(imageFile.path);
    final savedImagePath = p.join(appDir.path, fileName);

    try {
      await imageFile.copy(savedImagePath);
      // タイトル入力ダイアログを呼び出す
      if (!context.mounted) return;
      final title = await _promptForTitle(context);

      // タイトルが入力された場合のみ保存処理に進む
      if (title != null && title.isNotEmpty) {
        ref
            .read(otayoriImageProvider.notifier)
            .addImage(savedImagePath, childId, title);
      } else {
        // タイトルが入力されなかった（キャンセルされた）場合、
        // コピーしたファイルを削除しておく
        await File(savedImagePath).delete();
        print('タイトルが入力されなかったので保存をキャンセルしました。');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('画像の保存に失敗しました: $e')));
      }
    }
  }

  // ボトムシートを表示するメソッド
  void _showImageSourceActionSheet(BuildContext context, WidgetRef ref) async {
    final children = ref.read(childProvider);
    final selectedChild = await showDialog<Child>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('どのお子さんのおたよりですか？'),
        children: children
            .map((child) => SimpleDialogOption(
                  onPressed: () => Navigator.pop(context, child),
                  child: Text(child.name),
                ))
            .toList(),
      ),
    );

    if (selectedChild == null) return; // こどもが選択されなかったら何もしない

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.document_scanner), // アイコンを変更
                title: const Text('スキャナで撮影'),
                onTap: () {
                  // ★★★ 4. スキャナ起動メソッドを呼び出すように変更 ★★★
                  _scanAndSaveDocument(context, ref, selectedChild.id);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('ギャラリーから選択'),
                onTap: () {
                  _pickImageFromGallery(context, ref, selectedChild.id);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmDialog(
      BuildContext context, WidgetRef ref, String imageId) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('削除の確認'),
          content: const Text('このおたよりを削除しますか？\nこの操作は元に戻せません。'),
          actions: <Widget>[
            TextButton(
              child: const Text('キャンセル'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // ダイアログを閉じる
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('削除'),
              onPressed: () {
                // ProviderのremoveImageメソッドを呼び出して削除を実行
                ref.read(otayoriImageProvider.notifier).removeImage(imageId);
                Navigator.of(dialogContext).pop(); // ダイアログを閉じる
              },
            ),
          ],
        );
      },
    );
  }

  // GridViewを生成する部分を共通のウィジェットメソッドとして分離
  Widget _buildImageGrid(List<OtayoriImage> images) {
    if (images.isEmpty) {
      return const SizedBox.shrink();
    }
    return GridView.count(
      shrinkWrap: true, // 親ウィジェット(ListView)に合わせて高さを調整
      physics: const NeverScrollableScrollPhysics(), // このグリッド自体のスクロールを無効化
      crossAxisCount: 3, // 1行に表示するアイテム数
      padding: const EdgeInsets.all(8.0),
      crossAxisSpacing: 8.0,
      mainAxisSpacing: 8.0,
      children: images.map(
        (otayori) {
          return Column(children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  // AI解析画面には、画像のパスを渡す
                  // AnalysisScreenに画面遷移し、画像のパスを渡す
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AnalysisScreen(
                        imagePath: otayori.imagePath,
                        childId: otayori.childId,
                      ),
                    ),
                  );
                },
                onLongPress: () {
                  _showDeleteConfirmDialog(context, ref, otayori.id);
                },
                // Stackを使って画像の上に日付を重ねる
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // 背景画像
                    Image.file(File(otayori.imagePath), fit: BoxFit.cover),
                    // 日付を表示する部分
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 2,
                          horizontal: 4,
                        ),
                        // 日付の背景を少し暗くする
                        color: Colors.black.withOpacity(0.6),
                        child: Text(
                          // intlパッケージを使って日付をフォーマット
                          DateFormat(
                            'yyyy/MM/dd',
                          ).format(otayori.savedDate),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
            // タイトルを表示するTextウィジェット
            GestureDetector(
              onTap: () {
                // 上で作成した編集ダイアログを呼び出す
                _showEditTitleDialog(otayori);
              },
              child: Container(
                // タップ範囲を広げるための工夫
                width: double.infinity, // 横幅いっぱい
                color: Colors.transparent, // 透明でも当たり判定はつく
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  otayori.title.isNotEmpty
                      ? otayori.title
                      : 'タイトルなし', // タイトルが空の場合の表示
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ]);
        },
      ).toList(),
    );
  }

  Widget _buildGroupedList(List<OtayoriImage> images) {
    if (images.isEmpty) {
      return const Center(child: Text('このカテゴリのおたよりはありません。'));
    }

    // 1. 日付の新しい順にソート
    images.sort((a, b) => b.savedDate.compareTo(a.savedDate));

    // 2. 月ごとにグループ化
    final groupedImages = <String, List<OtayoriImage>>{};
    for (final image in images) {
      final monthKey = DateFormat('yyyy年M月').format(image.savedDate);
      if (groupedImages[monthKey] == null) {
        groupedImages[monthKey] = [];
      }
      groupedImages[monthKey]!.add(image);
    }

    // 3. ListViewを構築
    return ListView.builder(
      // 月ヘッダー + グリッド で1セットなので、月の数だけリストアイテムがある
      itemCount: groupedImages.length,
      itemBuilder: (context, index) {
        final month = groupedImages.keys.elementAt(index);
        final monthlyImages = groupedImages[month]!;

        // 月ヘッダーと画像グリッドをColumnでまとめる
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 月ヘッダー
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
              child: Text(
                month,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            // その月のおたよりグリッド
            _buildImageGrid(monthlyImages),
          ],
        );
      },
    );
  }

  Future<String?> _promptForTitle(BuildContext context) async {
    final titleController = TextEditingController();

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('おたよりのタイトルを入力'),
          content: Autocomplete<String>(
            // 候補が選択された後、TextFieldに表示する文字列を整形する
            displayStringForOption: (String option) => option.split('(').first,
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text.isEmpty) {
                return const Iterable<String>.empty();
              }
              // 1. 過去の履歴のタイトルを取得（読み仮名なし）
              final historyTitles = ref
                  .read(otayoriImageProvider)
                  .map((o) => o.title)
                  .where((t) => t.isNotEmpty);

              // 2. デフォルトのタイトルから、読み仮名を除いたリストを作成
              final defaultTitlesWithoutKana =
                  defaultOtayoriTitles.map((t) => t.split('(').first);

              // 3. ２つのリストを結合し、重複を除外した「表示すべきタイトルのリスト」を作成
              final uniqueTitles =
                  {...historyTitles, ...defaultTitlesWithoutKana}.toList();

              // 4. デフォルトの「読み仮名付き」リストから、表示すべきタイトルに合致するものだけを検索対象とする
              final searchTargetList = defaultOtayoriTitles
                  .where((t) => uniqueTitles.contains(t.split('(').first))
                  .toList();

              // 5. 検索対象リストから、ユーザーの入力に一致するものを返す
              return searchTargetList.where((String option) {
                // optionは 'クラスだより(くらすだより)' のような形式
                return option
                    .toLowerCase()
                    .contains(textEditingValue.text.toLowerCase());
              });
            },
            onSelected: (String selection) {
              final title = selection.split('(').first;
              titleController.text = title;
            },
            fieldViewBuilder: (context, fieldTextEditingController, focusNode,
                onEditingComplete) {
              // コントローラを同期
              fieldTextEditingController.addListener(() {
                titleController.text = fieldTextEditingController.text;
              });

              return TextField(
                controller: fieldTextEditingController,
                focusNode: focusNode,
                autofocus: true,
                decoration: const InputDecoration(hintText: '例：7月号クラスだより'),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // キャンセル
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: () {
                // 入力されたテキストを返してダイアログを閉じる
                Navigator.of(context).pop(titleController.text);
              },
              child: const Text('決定'),
            ),
          ],
        );
      },
    );
  }

  /// タイトル編集ダイアログを表示する
  Future<void> _showEditTitleDialog(OtayoriImage otayori) async {
    // テキストフィールドの初期値を現在のタイトルに設定
    final titleController = TextEditingController(text: otayori.title);

    final newTitle = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('タイトルの編集'),
        content: Autocomplete<String>(
          // 候補が選択された後、TextFieldに表示する文字列を整形する
          displayStringForOption: (String option) => option.split('(').first,
          // 候補リストを生成するロジック
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<String>.empty();
            }
            // 1. 過去の履歴のタイトルを取得（読み仮名なし）
            final historyTitles = ref
                .read(otayoriImageProvider)
                .map((o) => o.title)
                .where((t) => t.isNotEmpty);

            // 2. デフォルトのタイトルから、読み仮名を除いたリストを作成
            final defaultTitlesWithoutKana =
                defaultOtayoriTitles.map((t) => t.split('(').first);

            // 3. ２つのリストを結合し、重複を除外した「表示すべきタイトルのリスト」を作成
            final uniqueTitles =
                {...historyTitles, ...defaultTitlesWithoutKana}.toList();

            // 4. デフォルトの「読み仮名付き」リストから、表示すべきタイトルに合致するものだけを検索対象とする
            final searchTargetList = defaultOtayoriTitles
                .where((t) => uniqueTitles.contains(t.split('(').first))
                .toList();

            // 5. 検索対象リストから、ユーザーの入力に一致するものを返す
            return searchTargetList.where((String option) {
              // optionは 'クラスだより(くらすだより)' のような形式
              return option
                  .toLowerCase()
                  .contains(textEditingValue.text.toLowerCase());
            });
          },
          // 候補が選択されたら、我々のコントローラにも反映
          onSelected: (String selection) {
            final title = selection.split('(').first;
            titleController.text = title;
          },
          // テキスト入力欄の見た目を定義
          fieldViewBuilder: (context, fieldTextEditingController, focusNode,
              onEditingComplete) {
            // ★★★ 4. コントローラを同期させる ★★★
            // Autocomplete内部のコントローラと、我々が管理するコントローラを同期させる

            // 初期値を設定
            fieldTextEditingController.text = titleController.text;
            // テキストが変更されるたびに同期
            fieldTextEditingController.addListener(() {
              titleController.text = fieldTextEditingController.text;
            });

            return TextField(
              controller: fieldTextEditingController, // Autocompleteのコントローラを使用
              focusNode: focusNode,
              autofocus: true,
              decoration: const InputDecoration(labelText: '新しいタイトル'),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(titleController.text);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );

    // 新しいタイトルが入力されていれば、更新処理を呼び出す
    if (newTitle != null && newTitle.isNotEmpty) {
      ref
          .read(otayoriImageProvider.notifier)
          .updateOtayoriTitle(otayori.id, newTitle);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<OtayoriImage> otayoriImages = ref.watch(otayoriImageProvider);
    final children = ref.watch(childProvider);

    // タブのリストを動的に生成（「全員」タブを追加）
    final tabs = <Tab>[
      const Tab(text: '全員'),
      ...children.map((child) => Tab(text: child.name)),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('おたより一覧'),
        bottom: TabBar(
          controller: _tabController,
          tabs: tabs,
          isScrollable: true, // タブが多くなってもスクロールできるように
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 「全員」タブの中身
          _buildGroupedList(otayoriImages),
          // 各こどものタブの中身
          ...children.map((child) {
            // こどものIDでフィルタリング
            final filteredImages = otayoriImages
                .where((otayori) => otayori.childId == child.id)
                .toList();
            return _buildGroupedList(filteredImages);
          }),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showImageSourceActionSheet(context, ref),
        tooltip: '新しいおたよりを追加', // 修正済みのメソッドを呼ぶ
        child: const Icon(Icons.add),
      ),
    );
  }
}
