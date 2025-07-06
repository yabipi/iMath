import 'package:fleather/fleather.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:imath/http/article.dart';

class AddArticlePage extends StatefulWidget {
  @override
  _AddArticlePageState createState() => _AddArticlePageState();
}

class _AddArticlePageState extends State<AddArticlePage> {
  final TextEditingController _titleController = TextEditingController();
  final FleatherController _contentController = FleatherController();

  void _submitArticle() async {
    // TODO: 实现文章提交逻辑
    final title = _titleController.text;
    final content = _contentController.document.toString();
    // 可以在这里调用API或进行其他处理
    await ArticleHttp.addArticle({"title": title, "content": content});
    SmartDialog.showToast('创建成功');
    context.go('/culture');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('添加文章'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: '标题',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            FleatherToolbar.basic(controller: _contentController!),
            Expanded(
              child: FleatherEditor(controller: _contentController),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitArticle,
              child: Text('提交'),
            ),
          ],
        ),
      ),
    );
  }
}