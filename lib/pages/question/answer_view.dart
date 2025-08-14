import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:imath/models/question.dart';
import 'package:imath/math/math_cell.dart';

class AnswerView extends StatelessWidget {
  final Question question;

  const AnswerView({super.key, required this.question});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('题目答案'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: question.id == 0 ?
          const Center(
            child: Text('当前题目为空'),
          )
          : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 题目内容
            const Text(
              '题目内容:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            MathCell(
              content: question.content ?? '',
            ),
            const SizedBox(height: 8),
            if (question.options != null && question.options!.isNotEmpty) ...[
              MathCell(
                content: question.options ?? '',
              ),
              const SizedBox(height: 8),
            ],
            const Divider(),
            const SizedBox(height: 8),
            // 答案和解析
            const Text(
              '答案和解析:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            MathCell(
              title: '',
              content: question.answer ?? '暂无答案',
            ),
            // 底部留出一些空间，避免内容被遮挡
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
