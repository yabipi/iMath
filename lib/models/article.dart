import 'package:imath/config/constants.dart';
import 'package:imath/utils/enum_util.dart';

class Article {
  final int id;
  final String title;
  final String subtitle;
  final String level;
  final String branch;
  final String content;
  final String html;
  final String markdown;
  final String lake;
  final String author;
  final ContentFormat format;
  final DateTime date;

  Article({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.level,
    required this.branch,
    required this.content,
    required this.html,
    required this.markdown,
    required this.lake,
    required this.author,
    required this.format,
    required this.date,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      level: json['level'] ?? '',
      branch: json['branch'] ?? '',
      content: json['content'] ?? '',
      html: json['html'] ?? '',
      markdown: json['markdown'] ?? '',
      lake: json['lake'] ?? '',
      format: EnumUtil.fromString(ContentFormat.values, json['format']) ,
      author: json['author'] ?? '',
      date: DateTime.parse(json['gmt_modified']),
    );
  }
}