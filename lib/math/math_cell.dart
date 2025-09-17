import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:imath/math/math_parser.dart';
import 'package:imath/state/font_size_provider.dart';

class MathCell extends ConsumerWidget {
  final String? title;
  final String? content;
  final TextStyle? textStyle;

  const MathCell({super.key, this.title, this.content, this.textStyle});

  /// 根据可用宽度动态计算字体大小
  /// 确保数学公式能够适应屏幕宽度
  double _calculateResponsiveFontSize(
      double availableWidth, double baseFontSize, double globalFontScale) {
    // 基础宽度阈值（以iPhone 12为例，屏幕宽度约390px）
    const double baseWidth = 350.0;

    // 最小字体大小限制
    const double minFontSize = 18.0;

    // 最大字体大小限制
    const double maxFontSize = 32.0;

    // 计算缩放比例，使用适中的缩放
    double scaleFactor = (availableWidth / baseWidth) * 1.0; // 1.0倍缩放，最大化可读性

    // 应用缩放比例
    double scaledFontSize = baseFontSize * scaleFactor;

    // 应用全局字体大小倍数
    scaledFontSize *= globalFontScale;

    // 确保字体大小在合理范围内
    scaledFontSize = scaledFontSize.clamp(minFontSize, maxFontSize);

    return scaledFontSize;
  }

  /// 智能字体大小计算，根据公式复杂度调整
  double _calculateSmartFontSize(double availableWidth, double baseFontSize,
      String formula, double globalFontScale) {
    // 基础字体大小
    double fontSize = _calculateResponsiveFontSize(
        availableWidth, baseFontSize, globalFontScale);

    // 检测公式复杂度
    int complexityScore = _calculateFormulaComplexity(formula);

    // 根据复杂度进一步调整字体大小，使用更温和的缩放
    if (complexityScore > 100) {
      // 非常复杂的公式，适度缩小字体
      fontSize *= 0.9;
    } else if (complexityScore > 70) {
      // 复杂的公式，稍微缩小字体
      fontSize *= 0.95;
    } else if (complexityScore > 40) {
      // 中等复杂度的公式，轻微缩小字体
      fontSize *= 0.98;
    }
    // 简单公式保持基础字体大小

    // 确保字体大小在合理范围内，提高最小字体限制
    return fontSize.clamp(16.0, 32.0);
  }

  /// 计算公式复杂度分数
  int _calculateFormulaComplexity(String formula) {
    int score = 0;

    // 计算各种复杂度因子
    score += formula.length; // 基础长度分数

    // 特殊符号和操作符
    score += formula.split('+').length - 1; // 加法
    score += formula.split('-').length - 1; // 减法
    score += formula.split('*').length - 1; // 乘法
    score += formula.split('/').length - 1; // 除法
    score += formula.split('^').length - 1; // 幂运算
    score += formula.split('_').length - 1; // 下标
    score += formula.split('{').length - 1; // 大括号
    score += formula.split('}').length - 1; // 大括号
    score += formula.split('(').length - 1; // 小括号
    score += formula.split(')').length - 1; // 小括号
    score += formula.split('\\').length - 1; // LaTeX命令

    // 特殊函数和符号
    if (formula.contains('\\sum')) score += 10; // 求和
    if (formula.contains('\\int')) score += 10; // 积分
    if (formula.contains('\\lim')) score += 10; // 极限
    if (formula.contains('\\frac')) score += 5; // 分数
    if (formula.contains('\\sqrt')) score += 5; // 根号
    if (formula.contains('\\pi')) score += 2; // 圆周率
    if (formula.contains('\\alpha')) score += 2; // 希腊字母
    if (formula.contains('\\beta')) score += 2;
    if (formula.contains('\\gamma')) score += 2;
    if (formula.contains('\\delta')) score += 2;
    if (formula.contains('\\theta')) score += 2;
    if (formula.contains('\\lambda')) score += 2;
    if (formula.contains('\\mu')) score += 2;
    if (formula.contains('\\sigma')) score += 2;
    if (formula.contains('\\phi')) score += 2;
    if (formula.contains('\\omega')) score += 2;

    return score;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return buildMixedText(content, ref);
  }

  Widget buildMixedText(String? text, WidgetRef ref) {
    if (text == null || text.isEmpty) {
      return const Text('');
    }

    // 获取全局字体大小倍数
    final fontSizeScale = ref.watch(fontSizeProvider);

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
            LayoutBuilder(
              builder: (context, constraints) {
                // 根据可用宽度和公式复杂度动态调整字体大小
                final fontSize = _calculateSmartFontSize(
                  constraints.maxWidth,
                  this.textStyle?.fontSize ?? 18,
                  formula,
                  fontSizeScale,
                );
                return Math.tex(
                  formula,
                  textStyle: TextStyle(
                    fontSize: fontSize,
                    color: this.textStyle?.color,
                    fontWeight: this.textStyle?.fontWeight,
                  ),
                  mathStyle: MathStyle.display,
                );
              },
            ),
          );
        } else {
          // 处理行内公式或显示模式公式
          widgets.add(
            LayoutBuilder(
              builder: (context, constraints) {
                // 根据可用宽度和公式复杂度动态调整字体大小
                final fontSize = _calculateSmartFontSize(
                  constraints.maxWidth,
                  this.textStyle?.fontSize ?? 16,
                  formula,
                  fontSizeScale,
                );
                return Math.tex(
                  formula,
                  textStyle: TextStyle(
                    fontSize: fontSize,
                    color: this.textStyle?.color,
                    fontWeight: this.textStyle?.fontWeight,
                  ),
                  mathStyle: content.isDisplayMode
                      ? MathStyle.display
                      : MathStyle.text,
                );
              },
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
          LayoutBuilder(
            builder: (context, constraints) {
              final fontSize = _calculateResponsiveFontSize(
                constraints.maxWidth,
                16.0,
                fontSizeScale,
              );
              return Html(
                data: content.content,
                style: {
                  'body': Style(
                    fontSize: FontSize(fontSize, Unit.px),
                    lineHeight: LineHeight(1.6),
                  ),
                  'p': Style(
                    fontSize: FontSize(fontSize, Unit.px),
                    margin: Margins.only(bottom: 8),
                  ),
                  'h1': Style(
                    fontSize: FontSize(fontSize * 1.75, Unit.px),
                    fontWeight: FontWeight.bold,
                    margin: Margins.only(top: 16, bottom: 8),
                  ),
                  'h2': Style(
                    fontSize: FontSize(fontSize * 1.5, Unit.px),
                    fontWeight: FontWeight.bold,
                    margin: Margins.only(top: 14, bottom: 6),
                  ),
                  'h3': Style(
                    fontSize: FontSize(fontSize * 1.25, Unit.px),
                    fontWeight: FontWeight.bold,
                    margin: Margins.only(top: 12, bottom: 4),
                  ),
                  'li': Style(
                    fontSize: FontSize(fontSize, Unit.px),
                    margin: Margins.only(bottom: 4),
                  ),
                },
              );
            },
          ),
        );
      } else {
        // 处理普通文本
        widgets.add(
          LayoutBuilder(
            builder: (context, constraints) {
              final fontSize = _calculateResponsiveFontSize(
                constraints.maxWidth,
                this.textStyle?.fontSize ?? 16.0,
                fontSizeScale,
              );
              return Text(
                content.content,
                style: this.textStyle?.copyWith(fontSize: fontSize) ??
                    TextStyle(
                      fontSize: fontSize,
                      decoration: content.hasUnderline
                          ? TextDecoration.underline
                          : null,
                    ),
              );
            },
          ),
        );
      }
    }

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      runSpacing: 8, // 增加行间距
      children: widgets,
    );
  }
}
