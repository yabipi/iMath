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
import 'package:imath/widgets/editor/editor_controller.dart';
import 'package:imath/widgets/editor/html_editor.dart';


class AddArticlePage extends StatefulWidget {
  @override
  _AddArticlePageState createState() => _AddArticlePageState();
}

class _AddArticlePageState extends State<AddArticlePage> {
  final TextEditingController _titleController = TextEditingController();
  final EditorController _controller = EditorController();
  ArticleType _selectedArticleType = ArticleType.normal; // 新增：选中的文章类型

  void _submitArticle() async {
    // TODO: 实现文章提交逻辑
    final title = _titleController.text;
    String html = _controller.html;
    // 可以在这里调用API或进行其他处理
    await ArticleHttp.addArticle({
      "title": title,
      "content": html,
      "type": _selectedArticleType.value // 新增：提交选中的文章类型
    });
    SmartDialog.showToast('创建成功');
    context.go('/home');
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
      body: _buildHtmlEditor(),
    );
  }

  Widget _buildHtmlEditor() {
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
          HtmlEditor(controller: _controller)
        ],
      ),
    );
  }
}

