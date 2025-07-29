import 'package:flutter/material.dart';

class LayoutDemo extends StatelessWidget {
  const LayoutDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('布局演示'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 第一行：Text 和 TextField 等高
            Row(
              children: [
                // Text 组件
                const Text(
                  '标签：',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 16),
                // TextField 组件，使用 Expanded 确保占满剩余空间
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: '请输入内容',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // 第二行：Checkbox 和 Text 中间线对齐
            Row(
              children: [
                // Checkbox 组件
                Checkbox(
                  value: false,
                  onChanged: (bool? value) {
                    // 处理复选框状态变化
                  },
                ),
                const SizedBox(width: 8),
                // Text 组件，使用 Align 确保与 Checkbox 中间线对齐
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '我同意相关条款和条件',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // 额外的演示内容
            const Text(
              '布局说明：',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '• 第一行使用 Row 布局，Text 和 TextField 等高\n'
              '• 第二行使用 Row 布局，Checkbox 和 Text 中间线对齐\n'
              '• 使用 SizedBox 控制组件间距\n'
              '• 使用 Expanded 让 TextField 占满剩余空间',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
