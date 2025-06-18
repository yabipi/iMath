import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:http/http.dart' as http;
import 'package:imath/config/api_config.dart';

import 'package:imath/pages/markdown_edit.dart'; // 引入 markdown_edit 页面

class PdfUploader extends StatefulWidget {
  @override
  _PdfUploaderState createState() => _PdfUploaderState();
}

class _PdfUploaderState extends State<PdfUploader> {
  bool _isDragging = false;
  String? _filePath;
  DropDoneDetails? _details;
  String? _markdownText; // 用于存储返回的 Markdown 文本

  Future<void> _uploadFile(List<int> fileBytes, String fileName) async {
    var request = http.MultipartRequest('POST', Uri.parse('${ApiConfig.minerUrl}/api/upload'));
    request.files.add(http.MultipartFile.fromBytes('file', fileBytes, filename: fileName));
    var response = await request.send();
    if (response.statusCode == 200) {
      print('File uploaded successfully');
      // 假设后端返回的 Markdown 文本在响应体中
      final responseBody = await response.stream.bytesToString();
      setState(() {
        _markdownText = responseBody; // 存储返回的 Markdown 文本
      });
      // 跳转到 markdown_edit 页面
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MarkdownEdit(markdownText: _markdownText),
        ),
      );
    } else {
      print('Failed to upload file: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Uploader'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // 返回箭头逻辑
          },
        ),
      ),
      body: Column(
        children: [
          DropTarget(
            onDragDone: (details) async {
              String? path = details.files.last.path;
              debugPrint("path=$path");
              setState(() {
                _isDragging = false;
                _details = details;
                _filePath = details.files.last.path;
              });
            },
            onDragEntered: (detail) {
              setState(() {
                _isDragging = true;
              });
            },
            onDragExited: (detail) {
              setState(() {
                _isDragging = false;
              });
            },
            child: SizedBox(
              width: 600,
              height: 100,
              child: DottedBorder(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _filePath != null
                          ? Text(_filePath!)
                          : const Text("拖动文件到此处"),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 20), // 间距
          ElevatedButton(
            onPressed: () async {
              if (_filePath != null) {
                final file = _details?.files.first;
                final bytes = await file?.readAsBytes();
                _uploadFile(bytes!, (file?.name)!);
                // final file = await DropTarget.loadFile(_filePath!);
                // final bytes = await file.readAsBytes();
                // _uploadFile(bytes, file.name);
              }
            },
            child: Text('上传'),
          ),
        ],
      ),
    );
  }
}