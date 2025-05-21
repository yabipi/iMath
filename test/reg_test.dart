import 'package:flutter_test/flutter_test.dart';

List? parseMath(String text) {
  List results = [];
  // final RegExp latexPattern = RegExp(r'\\\((.*?)\\\)|\$(.*?)\$');
  final RegExp latexPattern = RegExp(r'\\\((.*?)\\\)|\$(.*?)\$');
  int lastIndex = 0;

  try {
    for (final Match match in latexPattern.allMatches(text)) {
      if (match.start > lastIndex) {
        results.add(text.substring(lastIndex, match.start));
      }

      final formula = match.group(1);
      if (formula != null) {
        results.add(formula);
      }

      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      results.add(text.substring(lastIndex));
    }
  } catch (e) {
    // print('Error in buildMixedText: $e');
  }
  return results;
}

void main() {
  group('test1', () {
    // String text = r'Some text $content1$ and (content2) with mixed patterns';
    String text = r'这是(haha)一个公式：$ddd345$';
    text = r'这是\(haha\)一个公式：$E = mc^2$';
    // 定义正则表达式
    final regex = RegExp(r'\$(.*?)\$|\\\((.*?)\\\)');

    // 查找所有匹配
    Iterable<Match> matches = regex.allMatches(text);

    // 提取内容
    List<String> extracted = [];

    for (final match in matches) {
      // 检查是哪种匹配（group(1)是$...$的内容，group(2)是(...)的内容）
      if (match.group(1) != null) {
        extracted.add(match.group(1)!);
      } else if (match.group(2) != null) {
        extracted.add(match.group(2)!);
      }
    }

    print(extracted);
  });
  group('parseMath', () {
    String text = r'Some text $jjxh123$ and $content2$ with dollar signs';

    // 定义正则表达式
    // final regex = RegExp(r'\$(.*?)\$');
    final regex = RegExp(r'(\\\((.*?)\\\)|\$(.*?)\$|)');

    // 查找所有匹配
    Iterable<Match> matches = regex.allMatches(text);

    // 提取内容
    List<String> extracted =
        matches.map((match) => match.group(1) ?? 'none').toList();

    print(extracted); // 输出: [content1, content2]
  });

  group('MathParser', () {
    test('should parse simple inline math', () {
      // final result = parseMath(r'这是\(haha\)一个公式：$E = mc^2$');
      final result = parseMath(r'这是\(haha\)一个公式：$ddd345$');
      expect(result?.length, 3);
      // expect(result[0].content, '这是一个公式 ');
      // expect(result[0].isMath, false);
      // expect(result[1].content, 'x^2');
      // expect(result[1].isMath, true);
      // expect(result[2].content, ' 的测试');
      // expect(result[2].isMath, false);
    });
  });
}
