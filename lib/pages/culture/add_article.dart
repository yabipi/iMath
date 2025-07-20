import 'dart:convert';
import 'dart:io' as io;

// import 'package:fleather/fleather.dart';
import 'package:delta_to_html/delta_to_html.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:imath/config/constants.dart'; // 新增导入：constants.dart
import 'package:imath/http/article.dart';
import 'package:path/path.dart' as path;

class AddArticlePage extends StatefulWidget {
  @override
  _AddArticlePageState createState() => _AddArticlePageState();
}

class _AddArticlePageState extends State<AddArticlePage> {
  final TextEditingController _titleController = TextEditingController();
  // final FleatherController _contentController = FleatherController();
  final QuillController _controller = () {
    return QuillController.basic(
        config: QuillControllerConfig(
          clipboardConfig: QuillClipboardConfig(
            enableExternalRichPaste: true,
            onImagePaste: (imageBytes) async {
              if (kIsWeb) {
                // Dart IO is unsupported on the web.
                return null;
              }
              // Save the image somewhere and return the image URL that will be
              // stored in the Quill Delta JSON (the document).
              final newFileName =
                  'image-file-${DateTime.now().toIso8601String()}.png';
              final newPath = path.join(
                io.Directory.systemTemp.path,
                newFileName,
              );
              final file = await io.File(
                newPath,
              ).writeAsBytes(imageBytes, flush: true);
              return file.path;
            },
          ),
        ));
  }();
  final FocusNode _editorFocusNode = FocusNode();
  final ScrollController _editorScrollController = ScrollController();

  ArticleType _selectedArticleType = ArticleType.normal; // 新增：选中的文章类型

  void _submitArticle() async {
    // TODO: 实现文章提交逻辑
    final title = _titleController.text;
    List deltaJson = _controller.document.toDelta().toJson();
    String html = DeltaToHTML.encodeJson(deltaJson);
    // 可以在这里调用API或进行其他处理
    await ArticleHttp.addArticle({
      "title": title,
      "content": html,
      "type": _selectedArticleType.value // 新增：提交选中的文章类型
    });
    SmartDialog.showToast('创建成功');
    context.go('/culture');
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('添加文章'),
        actions: [
          TextButton(
            onPressed: _submitArticle,
            child: const Icon(Icons.save)
          ),
        ],
      ),
      body: _buildQuillEditor(),
    );
  }

  Widget _buildQuillEditor() {
    return SafeArea(
      child: Column(
        children: [
          Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 2.0),
              child: TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: '标题',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: DropdownButtonFormField<ArticleType>(
              value: _selectedArticleType,
              decoration: InputDecoration(
                labelText: '文章类型',
                border: OutlineInputBorder(),
              ),
              items: ArticleType.values.map((ArticleType type) {
                return DropdownMenuItem<ArticleType>(
                  value: type,
                  child: Text(
                    type.label, // 显示枚举名称
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedArticleType = value!;
                });
              },
            ),
          ),
          SizedBox(height: 4),
          QuillSimpleToolbar(
              controller: _controller,
              config: QuillSimpleToolbarConfig(
                showUndo: false,
                showRedo: false,
                showSearchButton: false,
                showSubscript: false,
                showSuperscript: false,
                buttonOptions: QuillSimpleToolbarButtonOptions(
                  fontSize: QuillToolbarFontSizeButtonOptions(
                    items: {
                      '12pt': '12',
                      '14pt': '14',
                      '16pt': '16',
                      '24pt': '24',
                      '28pt': '28',
                      '32pt': '32'
                    },
                  ),
                ),
              ),
          ),
          Expanded(
            child: QuillEditor(
              focusNode: _editorFocusNode,
              scrollController: _editorScrollController,
              controller: _controller,
              config: QuillEditorConfig(
                placeholder: '请输入内容...',
                padding: const EdgeInsets.all(16),
              ),
            ),
          ),

        ],
      ),
    );
  }
}

class TimeStampEmbed extends Embeddable {
  const TimeStampEmbed(
      String value,
      ) : super(timeStampType, value);

  static const String timeStampType = 'timeStamp';

  static TimeStampEmbed fromDocument(Document document) =>
      TimeStampEmbed(jsonEncode(document.toDelta().toJson()));

  Document get document => Document.fromJson(jsonDecode(data));
}

class TimeStampEmbedBuilder extends EmbedBuilder {
  @override
  String get key => 'timeStamp';

  @override
  String toPlainText(Embed node) {
    return node.value.data;
  }

  @override
  Widget build(
      BuildContext context,
      EmbedContext embedContext,
      ) {
    return Row(
      children: [
        const Icon(Icons.access_time_rounded),
        Text(embedContext.node.value.data as String),
      ],
    );
  }
}