import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class MarkdownEdit extends StatefulWidget {
  final String? markdownText;

  const MarkdownEdit({Key? key, this.markdownText}) : super(key: key);

  @override
  _MarkdownEditState createState() => _MarkdownEditState();
}

class _MarkdownEditState extends State<MarkdownEdit> {
  QuillController? _controller;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = QuillController(
      document: Document()..insert(0, widget.markdownText ?? ''),
      selection: TextSelection.collapsed(offset: 0),
    );
  }

  Future<void> _saveContent() async {
    final markdownContent = _controller!.document.toPlainText();
    final response = await http.post(
      Uri.parse('http://192.168.1.9:9898/api/md/save'),
      body: {'content': markdownContent},
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('保存成功')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('保存失败')),
      );
    }
  }

  // 新增三个保存方法
  Future<void> _saveAsKnowledge() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    Get.toNamed('/addknow', arguments: {'markdownContent': _controller!.document.toPlainText()});

  }

  Future<void> _saveAsQuestion() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    Get.toNamed('/addquestion', arguments: {'markdownContent': _controller!.document.toPlainText()});
  }

  Future<void> _saveAsExam() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final markdownContent = _controller!.document.toPlainText();
      final response = await http.post(
        Uri.parse('http://192.168.1.9:9898/api/save/exam'),
        body: {'content': markdownContent},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存为试卷成功')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('保存失败: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('上传内容编辑'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          // IconButton(
          //   icon: Icon(Icons.save),
          //   onPressed: _saveContent,
          // ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: QuillEditor.basic(
            controller: _controller!,
          ),
        ),
      ),
      // 新增底部按钮栏
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _saveAsKnowledge,
              icon: const Icon(Icons.book),
              label: const Text('保存为知识点'),
            ),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _saveAsQuestion,
              icon: const Icon(Icons.question_mark),
              label: const Text('保存为题目'),
            ),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _saveAsExam,
              icon: const Icon(Icons.assignment),
              label: const Text('保存为试卷'),
            ),
          ],
        ),
      ),
    );
  }
}