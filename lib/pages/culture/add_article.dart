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

  void _submitArticle() async {
    // TODO: 实现文章提交逻辑
    final title = _titleController.text;
    List deltaJson = _controller.document.toDelta().toJson();
    String html = DeltaToHTML.encodeJson(deltaJson);
    // 可以在这里调用API或进行其他处理
    await ArticleHttp.addArticle({"title": title, "content": html});
    SmartDialog.showToast('创建成功');
    context.go('/culture');
  }

  @override
  void initState() {
    super.initState();
    // Load document
    // _controller.document = Document.fromJson([
    //   {'insert': '内容'},
    // ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('添加文章'),
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
          // QuillSimpleToolbar(
          //   controller: _controller,
          //   // config: QuillSimpleToolbarConfig(
          //   //   // embedButtons: FlutterQuillEmbeds.toolbarButtons(),
          //   //   // showClipboardPaste: true,
          //   //   customButtons: [
          //   //     // QuillToolbarCustomButtonOptions(
          //   //     //   icon: const Icon(Icons.add_alarm_rounded),
          //   //     //   onPressed: () {
          //   //     //     _controller.document.insert(
          //   //     //       _controller.selection.extentOffset,
          //   //     //       TimeStampEmbed(
          //   //     //         DateTime.now().toString(),
          //   //     //       ),
          //   //     //     );
          //   //     //
          //   //     //     _controller.updateSelection(
          //   //     //       TextSelection.collapsed(
          //   //     //         offset: _controller.selection.extentOffset + 1,
          //   //     //       ),
          //   //     //       ChangeSource.local,
          //   //     //     );
          //   //     //   },
          //   //     // ),
          //   //   ],
          //   //   buttonOptions: QuillSimpleToolbarButtonOptions(
          //   //     base: QuillToolbarBaseButtonOptions(
          //   //       afterButtonPressed: () {
          //   //         final isDesktop = {
          //   //           TargetPlatform.linux,
          //   //           TargetPlatform.windows,
          //   //           TargetPlatform.macOS
          //   //         }.contains(defaultTargetPlatform);
          //   //         if (isDesktop) {
          //   //           _editorFocusNode.requestFocus();
          //   //         }
          //   //       },
          //   //     ),
          //   //     linkStyle: QuillToolbarLinkStyleButtonOptions(
          //   //       validateLink: (link) {
          //   //         // Treats all links as valid. When launching the URL,
          //   //         // `https://` is prefixed if the link is incomplete (e.g., `google.com` → `https://google.com`)
          //   //         // however this happens only within the editor.
          //   //         return true;
          //   //       },
          //   //     ),
          //   //   ),
          //   // ),
          // ),
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
                // embedBuilders: [
                //   ...FlutterQuillEmbeds.editorBuilders(
                //     imageEmbedConfig: QuillEditorImageEmbedConfig(
                //       imageProviderBuilder: (context, imageUrl) {
                //         // https://pub.dev/packages/flutter_quill_extensions#-image-assets
                //         if (imageUrl.startsWith('assets/')) {
                //           return AssetImage(imageUrl);
                //         }
                //         return null;
                //       },
                //     ),
                //     videoEmbedConfig: QuillEditorVideoEmbedConfig(
                //       customVideoBuilder: (videoUrl, readOnly) {
                //         // To load YouTube videos https://github.com/singerdmx/flutter-quill/releases/tag/v10.8.0
                //         return null;
                //       },
                //     ),
                //   ),
                //   TimeStampEmbedBuilder(),
                // ],
              ),
            ),
          ),
          SizedBox(height: 6),
          ElevatedButton(
            onPressed: _submitArticle,
            child: Text('提交'),
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