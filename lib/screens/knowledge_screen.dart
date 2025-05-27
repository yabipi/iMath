import 'package:flutter/material.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:http/http.dart' as http;
import 'package:imath/components/math_cell.dart';
import 'dart:convert';

import 'package:imath/config/api_config.dart';
import 'package:imath/config/constants.dart';
import 'package:imath/core/context.dart';
import 'package:markdown_widget/widget/markdown.dart';

class KnowledgeScreen extends StatefulWidget {
  const KnowledgeScreen({super.key});

  @override
  _KnowledgeScreenState createState() => _KnowledgeScreenState();
}

class _KnowledgeScreenState extends State<KnowledgeScreen> {
  // 新增：当前选中的分类ID
  int _selectedCategoryId = -1;

  @override
  Widget build(BuildContext context) {
    final categories = Context().get(CATEGORIES_KEY) as Map<int, String>?;

    return Scaffold(
      appBar: AppBar(
        title: const Text('知识点'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: Column(
        children: [
          // 分类标签区域
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8.0, // 水平间距
              runSpacing: 8.0, // 垂直间距
              children: [
                // 新增：全部分类标签
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategoryId = -1;
                    });
                  },
                  child: Chip(
                    label: const Text('全部'),
                    labelStyle: TextStyle(
                      color: _selectedCategoryId == -1 ? Colors.white : Colors.black,
                    ),
                    backgroundColor: _selectedCategoryId == -1 ? Colors.blue : Colors.grey[200],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                ...categories?.keys.map((key) {
                  final categoryId = key;
                  final categoryName = categories![categoryId];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategoryId = categoryId!;
                      });
                    },
                    child: Chip(
                      label: Text(categoryName!),
                      labelStyle: TextStyle(
                        color: _selectedCategoryId == categoryId ? Colors.white : Colors.black,
                      ),
                      backgroundColor: _selectedCategoryId == categoryId ? Colors.blue : Colors.grey[200],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  );
                }).toList() ?? [],
              ],
            ),
          ),
          // 知识点列表区域
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: fetchKnowledgePoints(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  return ListView(
                    padding: const EdgeInsets.all(8.0),
                    children: snapshot.data!.map((knowledge) {
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          title: Text(
                            knowledge['Title'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          subtitle: Text(
                            knowledge['Content'].length > 100
                                ? '${knowledge['Content'].substring(0, 100)}...'
                                : knowledge['Content'],
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    KnowledgeDetailScreen(knowledge: knowledge),
                              ),
                            );
                          },
                        ),
                      );
                    }).toList(),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // 新增：获取知识点列表的函数
  Future<List<dynamic>> fetchKnowledgePoints() async {
    final response = await http.get(Uri.parse(
        '${ApiConfig.SERVER_BASE_URL}/api/know/list?categoryId=${_selectedCategoryId}'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load knowledge points');
    }
  }
}

class KnowledgeDetailScreen extends StatelessWidget {
  final dynamic knowledge;

  const KnowledgeDetailScreen({super.key, required this.knowledge});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(knowledge['Title']),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GptMarkdown(
            knowledge['Content'],
            style: const TextStyle(color: Colors.black),
          ),
        ),
      ),
    );
  }
}
