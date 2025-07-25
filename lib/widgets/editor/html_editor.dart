import 'dart:convert';
import 'dart:io' as io;
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:path/path.dart' as path;

import 'editor_controller.dart';

const toolbarConfig = QuillSimpleToolbarConfig(
  showUndo: false,
  showRedo: false,
  showSearchButton: false,
  showStrikeThrough: false,
  showSubscript: false,
  showSuperscript: false,
  showCodeBlock: false,
  showListCheck: false,
  showIndent: false,
  showClearFormat: false,

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
);

class HtmlEditor extends StatefulWidget {
  const HtmlEditor({
    Key? key,
    required this.controller,
    // this.hint = '请输入内容...',
    // this.height = 300,
    // this.minHeight = 150,
    // this.maxHeight = 500,
    // this.padding = const EdgeInsets.all(8),
    // this.textStyle = const TextStyle(fontSize: 16),
    // this.textAlign = TextAlign.start,
    // this.autoFocus = false,
    // this.focusNode,
    // this.scrollController,
  });

  final EditorController controller;

  @override
  State<StatefulWidget> createState() => _HtmlEditorState();
}

class _HtmlEditorState extends State<HtmlEditor> {
  final FocusNode _editorFocusNode = FocusNode();
  final ScrollController _editorScrollController = ScrollController();
  final EditorController _controller = EditorController();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minHeight: 150,
        maxHeight: 500,
      ),
      child: Column(
        children: [
          QuillSimpleToolbar(
            controller: _controller.controller,
            config: toolbarConfig,
          ),
          Expanded(
            child: QuillEditor(
              focusNode: _editorFocusNode,
              scrollController: _editorScrollController,
              controller: _controller.controller,
              config: QuillEditorConfig(
                placeholder: '请输入内容...',
                padding: const EdgeInsets.all(16),
              ),
            ),
          ),
        ],
      )
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