import 'package:flutter/material.dart';
import 'package:imath/pages/slide_question.dart';

class TestFunctionsPage extends StatelessWidget {
  const TestFunctionsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("测试功能"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "功能测试区",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                _buildTestButton(context, "布局管理", () {
                  // TODO: 布局管理逻辑
                }),
                _buildTestButton(context, "我要自测", () {
                  // TODO: 我要自测逻辑
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestButton(
      BuildContext context, String title, VoidCallback onPressed) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          onPressed: onPressed,
          child: Text(title),
        ),
      ),
    );
  }
}
