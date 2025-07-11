import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:imath/utils/math_parser.dart';

class MathCell extends StatelessWidget {
  final String? title;
  final String? content;

  const MathCell({
    super.key,
    this.title,
    this.content,
  });

  @override
  Widget build(BuildContext context) {
    return buildMixedText(content);
  }

  Widget buildMixedText(String? text) {
    if (text == null || text.isEmpty) {
      return const Text('');
    }

    final List<Widget> widgets = [];
    final parsedContents = MathParser.parse(text);

    for (final content in parsedContents) {
      if (content.isMath) {
        // 处理数学公式
        String formula = content.content;
        // 如果是环境公式（如 matrix），需要特殊处理
        if (content.environment != null) {
          // 保持完整的 LaTeX 环境
          widgets.add(
            Math.tex(
              formula,
              textStyle: const TextStyle(fontSize: 16),
              mathStyle: MathStyle.display,
            ),
          );
        } else {
          // 处理行内公式或显示模式公式
          widgets.add(
            Math.tex(
              formula,
              textStyle: const TextStyle(fontSize: 16),
              mathStyle:
                  content.isDisplayMode ? MathStyle.display : MathStyle.text,
            ),
          );
        }
      } else if (content.isSpacing) {
        // 处理间距
        widgets.add(
          SizedBox(
            width: content.spacingCount * 16, // 16 是当前字体大小
          ),
        );
      } else if (content.isLineBreak) {
        // 添加换行组件
        widgets.add(
          SizedBox(
            height: 16, // 可根据需要调整高度
            width: double.infinity, // 宽度填满父容器以实现换行效果
          ),
        );
      } else {
        // 处理普通文本
        widgets.add(
          Text(
            content.content,
            style: TextStyle(
              fontSize: 16,
              decoration:
                  content.hasUnderline ? TextDecoration.underline : null,
            ),
          ),
        );
      }
    }

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      children: widgets,
    );
  }
}
