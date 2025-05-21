void main() {
  String text = r'Some text $content1$ and $content2$ with dollar signs';

  // 定义正则表达式
  final regex = RegExp(r'\$(.*?)\$');

  // 查找所有匹配
  Iterable<Match> matches = regex.allMatches(text);

  // 提取内容
  List<String> extracted = matches.map((match) => match.group(1)!).toList();

  print(extracted); // 输出: [content1, content2]
}
