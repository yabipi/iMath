import 'dart:convert';
import 'dart:io' as io;

import 'package:delta_to_html/delta_to_html.dart';
import 'package:flutter_quill_delta_from_html/parser/html_to_delta.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

// final FleatherController _contentController = FleatherController();

class EditorController {
  final QuillController _controller = () {
    return QuillController.basic(
        config: QuillControllerConfig(
          clipboardConfig: QuillClipboardConfig(
            enableExternalRichPaste: true,
            onClipboardPaste: () async {
              return true;
            },
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

  EditorController();

  QuillController get controller => _controller;

  String get html {
    List deltaJson = _controller.document.toDelta().toJson();
    String _html = DeltaToHTML.encodeJson(deltaJson);
    return _html;
  }

  set content(String _content) {
    var delta = HtmlToDelta().convert(_content??'', transformTableAsEmbed: false);
    _controller.document = Document.fromDelta(delta);
  }

  String get plainText => _controller.document.toPlainText();

  String get json => jsonEncode(_controller.document.toDelta().toJson());

  void clear() {
    _controller.clear();
  }
}