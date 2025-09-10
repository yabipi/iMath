import 'package:flutter_test/flutter_test.dart';
import 'package:imath/pages/question/image_viewer.dart';

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

List<OptionItem> parseOptions(String lineStr) {
  List<OptionItem> options = [];
  // 按换行符分割选项
  List<String> optionLines = lineStr
      .split(RegExp(r'\r\n|\n|[;,]'))
      .where((line) => line.trim().isNotEmpty)
      .toList();

  for (String line in optionLines) {
    line = line.trim();
    if (line.isEmpty) continue;

    RegExp optionRegex = RegExp(r'^([A-F]|[①②③④⑤⑥⑦⑧]|\([A-Z]\))[\.、\s]\s*(.*)$');
    RegExp urlRegex = RegExp(r'^(https?://).*');
    Match? match = optionRegex.firstMatch(line);

    if (match != null) {
      String optionLabel = match.group(1)!;
      String content = match.group(2)!;

      // 检查内容是否包含markdown图片格式
      RegExp imageRegex = RegExp(r'!\[([^\]]*)\]\(([^)]+)\)');
      Match? imageMatch = imageRegex.firstMatch(content);

      // 检查内容是否包含HTTP/HTTPS URL（可能前面有数字或其他字符）
      Match? urlMatch = urlRegex.firstMatch(content);

      if (imageMatch != null) {
        // 包含markdown图片格式的选项
        String imageUrl = imageMatch.group(2)!;
        options.add(OptionItem(
          label: optionLabel,
          content: content,
          imageUrl: imageUrl,
          isImage: true,
        ));
      } else if (urlMatch != null) {
        // 包含HTTP/HTTPS URL的选项（如：① https://example.com/image.jpg）
        String imageUrl = urlMatch.group(0)!;
        options.add(OptionItem(
          label: optionLabel,
          content: content,
          imageUrl: imageUrl,
          isImage: true,
        ));
      } else {
        // 普通文本选项
        options.add(OptionItem(
          label: optionLabel,
          content: content,
          imageUrl: null,
          isImage: false,
        ));
      }
    }
  }

  return options;
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

  group('splitOptions', () {
    test('should split options correctly', () {
      final options = "gaga;xixix,① https://cdn.icodelib.cn/bo_d302c1v7aajc738t07c0_1_314_588_92_96_0.jpg\n② https://cdn.icodelib.cn/bo_d302c1v7aajc738t07c0_1_410_591_83_92_0.jpg\n③ https://cdn.icodelib.cn/bo_d302c1v7aajc738t07c0_1_496_585_102_97_0.jpg\n④ https://cdn.icodelib.cn/bo_d302c1v7aajc738t07c0_1_600_589_111_92_0.jpg\n⑤ https://cdn.icodelib.cn/bo_d302c1v7aajc738t07c0_1_716_590_100_87_0.jpg";
      List<String> lines = options.split(RegExp(r'\r\n|\n|[;,]'));
      print(lines);
    });

    test('should split options to list', () {
      final options = "(A) https://cdn.icodelib.cn/bo_d302c1v7aajc738t07c0_1_314_588_92_96_0.jpg; ① https://cdn.icodelib.cn/bo_d302c1v7aajc738t07c0_1_314_588_92_96_0.jpg\n② https://cdn.icodelib.cn/bo_d302c1v7aajc738t07c0_1_410_591_83_92_0.jpg\n③ https://cdn.icodelib.cn/bo_d302c1v7aajc738t07c0_1_496_585_102_97_0.jpg\n④ https://cdn.icodelib.cn/bo_d302c1v7aajc738t07c0_1_600_589_111_92_0.jpg\n⑤ https://cdn.icodelib.cn/bo_d302c1v7aajc738t07c0_1_716_590_100_87_0.jpg";
      List<OptionItem> items = parseOptions(options);
      print(items);
    });

    test('should split options to list2', () {
      final options = "① https://cdn.icodelib.cn/bo_d302c1v7aajc738t07c0_1_314_588_92_96_0.jpg\n② https://cdn.icodelib.cn/bo_d302c1v7aajc738t07c0_1_410_591_83_92_0.jpg\n③ https://cdn.icodelib.cn/bo_d302c1v7aajc738t07c0_1_496_585_102_97_0.jpg\n④ https://cdn.icodelib.cn/bo_d302c1v7aajc738t07c0_1_600_589_111_92_0.jpg\n⑤ https://cdn.icodelib.cn/bo_d302c1v7aajc738t07c0_1_716_590_100_87_0.jpg";
      List<OptionItem> items = parseOptions(options);
      print(items);
    });
  });
}
