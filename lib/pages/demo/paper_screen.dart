import 'package:flutter/material.dart';
import 'dart:convert';

class PaperItem {
  final String id;
  final String content;
  final int score;
  final String type; // 题目类型：单选、多选、判断等

  PaperItem({
    required this.id,
    required this.content,
    required this.score,
    required this.type,
  });

  factory PaperItem.fromJson(Map<String, dynamic> json) {
    return PaperItem(
      id: json['id'] as String,
      content: json['content'] as String,
      score: json['score'] as int,
      type: json['type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'score': score,
      'type': type,
    };
  }
}

class PaperSection {
  final String id;
  final String title;
  final List<PaperItem> items;
  final int totalScore;

  PaperSection({
    required this.id,
    required this.title,
    required this.items,
    required this.totalScore,
  });

  factory PaperSection.fromJson(Map<String, dynamic> json) {
    return PaperSection(
      id: json['id'] as String,
      title: json['title'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => PaperItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalScore: json['totalScore'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'items': items.map((item) => item.toJson()).toList(),
      'totalScore': totalScore,
    };
  }
}

class Paper {
  final String id;
  final String title;
  final List<PaperSection> sections;
  final int totalScore;
  final int duration; // 考试时长（分钟）

  Paper({
    required this.id,
    required this.title,
    required this.sections,
    required this.totalScore,
    required this.duration,
  });

  factory Paper.fromJson(Map<String, dynamic> json) {
    return Paper(
      id: json['id'] as String,
      title: json['title'] as String,
      sections: (json['sections'] as List<dynamic>)
          .map((e) => PaperSection.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalScore: json['totalScore'] as int,
      duration: json['duration'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'sections': sections.map((section) => section.toJson()).toList(),
      'totalScore': totalScore,
      'duration': duration,
    };
  }
}

class PaperScreen extends StatefulWidget {
  const PaperScreen({super.key});

  @override
  State<PaperScreen> createState() => _PaperScreenState();
}

class _PaperScreenState extends State<PaperScreen> {
  late Paper paper;
  bool _isExpanded = true;

  @override
  void initState() {
    super.initState();
    // 模拟从JSON加载试卷数据
    final jsonData = '''
    {
      "id": "paper001",
      "title": "2024年数学期末考试",
      "sections": [
        {
          "id": "section1",
          "title": "选择题",
          "items": [
            {
              "id": "item1",
              "content": "1 + 1 = ?",
              "score": 5,
              "type": "单选"
            },
            {
              "id": "item2",
              "content": "下列哪些是质数？",
              "score": 10,
              "type": "多选"
            }
          ],
          "totalScore": 15
        },
        {
          "id": "section2",
          "title": "填空题",
          "items": [
            {
              "id": "item3",
              "content": "解方程：x + 5 = 10",
              "score": 10,
              "type": "填空"
            }
          ],
          "totalScore": 10
        },
        {
          "id": "section3",
          "title": "解答题",
          "items": [
            {
              "id": "item4",
              "content": "证明勾股定理",
              "score": 15,
              "type": "解答"
            }
          ],
          "totalScore": 15
        }
      ],
      "totalScore": 40,
      "duration": 120
    }
    ''';
    paper = Paper.fromJson(jsonDecode(jsonData));
  }

  Widget _buildItemCard(PaperItem item, int itemIndex) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Text('${itemIndex + 1}'),
        ),
        title: Text(item.content),
        subtitle: Text('${item.type} | ${item.score}分'),
        trailing: IconButton(
          icon: const Icon(Icons.arrow_forward_ios),
          onPressed: () {
            // TODO: 跳转到题目详情页面
          },
        ),
      ),
    );
  }

  Widget _buildSection(PaperSection section, int sectionIndex) {
    return ExpansionTile(
      key: ValueKey(section.id),
      initiallyExpanded: _isExpanded,
      onExpansionChanged: (expanded) {
        setState(() {
          _isExpanded = expanded;
        });
      },
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).primaryColor,
        child: Text('${sectionIndex + 1}'),
      ),
      title: Text(
        '第${sectionIndex + 1}部分：${section.title}',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text('共${section.items.length}题，${section.totalScore}分'),
      children: section.items
          .map((item) => _buildItemCard(item, section.items.indexOf(item)))
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(paper.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('试卷信息'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('总分：${paper.totalScore}分'),
                      Text('时长：${paper.duration}分钟'),
                      Text(
                          '题数：${paper.sections.fold(0, (sum, section) => sum + section.items.length)}题'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('确定'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: paper.sections.length,
        itemBuilder: (context, index) =>
            _buildSection(paper.sections[index], index),
      ),
    );
  }
}
