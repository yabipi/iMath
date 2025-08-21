import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:imath/math/math_parser.dart';

class MathCell extends StatelessWidget {
  final String? title;
  final String? content;
  final TextStyle? textStyle;

  const MathCell({super.key, this.title, this.content, this.textStyle});

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
              textStyle: this.textStyle ?? const TextStyle(fontSize: 16),
              mathStyle: MathStyle.display,
            ),
          );
        } else {
          // 处理行内公式或显示模式公式
          widgets.add(
            Math.tex(
              formula,
              textStyle: this.textStyle ?? const TextStyle(fontSize: 16),
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
      } else if (content.isHtml == true) {
        // 处理HTML内容
        widgets.add(
          Html(
            data: content.content,
            style: {
              'body': Style(
                fontSize: FontSize(16, Unit.px),
                lineHeight: LineHeight(1.6),
              ),
              'p': Style(
                fontSize: FontSize(16, Unit.px),
                margin: Margins.only(bottom: 8),
              ),
              'h1': Style(
                fontSize: FontSize(28, Unit.px),
                fontWeight: FontWeight.bold,
                margin: Margins.only(top: 16, bottom: 8),
              ),
              'h2': Style(
                fontSize: FontSize(24, Unit.px),
                fontWeight: FontWeight.bold,
                margin: Margins.only(top: 14, bottom: 6),
              ),
              'h3': Style(
                fontSize: FontSize(20, Unit.px),
                fontWeight: FontWeight.bold,
                margin: Margins.only(top: 12, bottom: 4),
              ),
              'li': Style(
                fontSize: FontSize(16, Unit.px),
                margin: Margins.only(bottom: 4),
              ),
            },
          ),
        );
      } else {
        // 处理普通文本
        widgets.add(
          Text(
            content.content,
            style: this.textStyle ??
                TextStyle(
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
      runSpacing: 4,
      children: widgets,
    );
  }
}
