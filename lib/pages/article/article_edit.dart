import 'dart:convert';
import 'dart:io' as io;

// import 'package:fleather/fleather.dart';

import 'package:flutter/material.dart';

import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:imath/http/article.dart';
import 'package:imath/widgets/editor/editor_controller.dart';
import 'package:imath/widgets/editor/html_editor.dart';

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
  final EditorController _controller = EditorController();
  

  Future<void> _fetchArticle() async {
    // 假设延迟2秒模拟网络请求
    // await Future.delayed(Duration(seconds: 2));
    final article = await ArticleHttp.loadArticle(widget.articleId);
    _titleController.text = article.title;
    // Load document
    _controller.content = article.content;
    // return article;
  }

  void _submitArticle() async {
    final title = _titleController.text;
    final html = _controller.html;
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
          HtmlEditor(controller: _controller),

        ],
      ),
    );
  }
}
