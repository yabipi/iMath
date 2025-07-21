import 'dart:convert';
import 'dart:io' as io;

// import 'package:fleather/fleather.dart';
import 'package:delta_to_html/delta_to_html.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_delta_from_html/parser/html_to_delta.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:imath/http/article.dart';
import 'package:path/path.dart' as path;

class EditArticlePage extends StatefulWidget {
  final int? articleId;
  final String? content;

  EditArticlePage({super.key, this.articleId, this.content});
  @override
  _EditArticlePageState createState() => _EditArticlePageState();
}

class _EditArticlePageState extends State<EditArticlePage> {
  late Future _future;
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

  Future<void> _fetchArticle() async {
    // 假设延迟2秒模拟网络请求
    // await Future.delayed(Duration(seconds: 2));
    final article = await ArticleHttp.loadArticle(widget.articleId);
    var delta = HtmlToDelta().convert(article['content']??'', transformTableAsEmbed: false);
    _titleController.text = article['title'];
    // Load document
    _controller.document = Document.fromDelta(delta);
    // return article;
  }

  void _submitArticle() async {
    final title = _titleController.text;
    List deltaJson = _controller.document.toDelta().toJson();
    String html = DeltaToHTML.encodeJson(deltaJson);
    // 可以在这里调用API或进行其他处理
    await ArticleHttp.updateArticle(widget.articleId, {"title": title, "content": html});
    SmartDialog.showToast('修改成功');
    context.go('/home');
  }

  @override
  void initState() {
    super.initState();
    _future = _fetchArticle();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('文章编辑'),
        actions: [
          TextButton(
              onPressed: _submitArticle,
              child: const Icon(Icons.save)
          ),
        ],
      ),
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            // final article = snapshot.data;
            return  _buildQuillEditor();
          }
        }
      )

    );
  }

  Widget _buildQuillEditor() {
    return SafeArea(
      child: Column(
        children: [
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: '标题',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 4),
          QuillSimpleToolbar(controller: _controller),
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