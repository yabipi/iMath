import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:imath/pages/demo/draggable_tree_demo.dart';

import 'package:imath/pages/demo/easy_refresh_list.dart';
import 'package:imath/pages/demo/easy_refresh_list_riverpod.dart';
import 'package:imath/pages/demo/extensible_refresh_list_example.dart';
import 'package:imath/pages/demo/gptmd_demo.dart';
import 'package:imath/pages/knowledge/knowledge_listview.dart';
import 'package:imath/pages/demo/html_editor_demo.dart';
import 'package:imath/pages/demo/html_tex_screen.dart';
import 'package:imath/pages/demo/latex_test_screen.dart';
import 'package:imath/pages/demo/simple_list_view.dart';
import 'package:imath/pages/question/slide_question.dart';

class TestFunctionsPage extends StatelessWidget {
  const TestFunctionsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("测试功能"),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              context.pop();
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _buildTestButton(context, "题库播放", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SlideQuestion(),
                  ),
                );
              }),
              _buildTestButton(context, "下拉刷新", () {
                // TODO: 下拉刷新逻辑
              }),
              _buildTestButton(context, "可拖放节点树", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DraggableTreeDemo(),
                  ),
                );
              }),
              _buildTestButton(context, "布局管理", () {
                // TODO: 布局管理逻辑
              }),
              _buildTestButton(context, "无限下拉列表", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EasyRefreshListScreen(),
                  ),
                );
              }),
              _buildTestButton(context, "ListView", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SimpleListView(),
                  ),
                );
              }),
              _buildTestButton(context, "可扩展刷新列表", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ExtensibleRefreshListExample(),
                  ),
                );
              }),
              _buildTestButton(context, "Riverpod列表", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EasyRefreshListRiverpodScreen(),
                  ),
                );
              }),
              _buildTestButton(context, "知识列表", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => KnowledgeListView(),
                  ),
                );
              }),
              _buildTestButton(context, "数学公式渲染", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LatexRenderScreen(),
                  ),
                );
              }),
              _buildTestButton(context, "Html Math", () {
                // TODO: 布局管理逻辑
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HtmlTexScreen(),
                  ),
                );
              }),
              _buildTestButton(context, "Html编辑器", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HtmlEditorExample(title: 'Html编辑器'),
                  ),
                );
                //
              }),
              _buildTestButton(context, "GptMarkdown显示", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GptMarkdownScreen(),
                  ),
                );// TODO: 布局管理逻辑
              }),
              _buildTestButton(context, "待实现", () {
                // TODO: 布局管理逻辑
              }),
              _buildTestButton(context, "待实现", () {
                // TODO: 布局管理逻辑
              }),
              _buildTestButton(context, "待实现", () {
                // TODO: 布局管理逻辑
              }),
              _buildTestButton(context, "待实现", () {
                // TODO: 布局管理逻辑
              }),
              _buildTestButton(context, "待实现", () {
                // TODO: 布局管理逻辑
              }),
              _buildTestButton(context, "待实现", () {
                // TODO: 布局管理逻辑
              }),
              _buildTestButton(context, "待实现", () {
                // TODO: 布局管理逻辑
              }),
              _buildTestButton(context, "待实现", () {
                // TODO: 布局管理逻辑
              }),
              _buildTestButton(context, "待实现", () {
                // TODO: 布局管理逻辑
              }),
              //
            ],
          ),
        ));
  }

  Widget _buildTestButton(
      BuildContext context, String title, VoidCallback onPressed) {
    return Container(
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          title,
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
