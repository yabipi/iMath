import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:imath/pages/demo/draggable_tree_demo.dart';

import 'package:imath/pages/demo/easy_refresh_list.dart';
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 第一行按钮
            Row(
              children: [
                Expanded(
                  child: _buildTestButton(context, "题库播放", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SlideQuestion(),
                      ),
                    );
                  }),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTestButton(context, "下拉刷新", () {
                    // TODO: 下拉刷新逻辑
                  }),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // 第二行按钮
            Row(
              children: [
                Expanded(
                  child: _buildTestButton(context, "可拖放节点树", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DraggableTreeDemo(),
                      ),
                    );
                  }),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTestButton(context, "布局管理", () {
                    // TODO: 布局管理逻辑
                  }),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // 第三行按钮
            Row(
              children: [
                Expanded(
                  child: _buildTestButton(context, "无限下拉列表", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EasyRefreshListScreen(),
                      ),
                    );
                  }),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTestButton(context, "ListView", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SimpleListView(),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
