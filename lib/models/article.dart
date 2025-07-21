

class Article {
  final int id;
  final String title;
  final String content;
  final String author;
  final DateTime date;

  Article({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.date,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      author: json['author'] ?? '',
      date: DateTime.parse(json['gmt_modified']),
    );
  }
}