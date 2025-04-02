import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import '../models/paper.dart';
import 'add_paper_screen.dart';
import 'question_list_screen.dart';
import 'add_question_screen.dart';
import 'paper_detail_screen.dart';

class PaperListScreen extends StatefulWidget {
  const PaperListScreen({super.key});

  @override
  State<PaperListScreen> createState() => _PaperListScreenState();
}

class _PaperListScreenState extends State<PaperListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('题库'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true, // 如果标签太多，允许滚动
          tabs: const [
            Tab(text: '全部题目'),
            Tab(text: '小学题库'),
            Tab(text: '初中题库'),
            Tab(text: '高中题库'),
            Tab(text: '大学题库'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          QuestionListScreen(),
          PaperListTab(level: 'PRIMARY'),
          PaperListTab(level: 'JUNIOR'),
          PaperListTab(level: 'SENIOR'),
          PaperListTab(level: 'COLLEGE'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_tabController.index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddQuestionScreen(paperId: -1),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddPaperScreen(
                  initialLevel: _getLevelFromIndex(_tabController.index - 1),
                ),
              ),
            );
          }
        },
        child: Icon(_tabController.index == 0 ? Icons.add_circle : Icons.add),
      ),
    );
  }

  String _getLevelFromIndex(int index) {
    switch (index) {
      case 0:
        return 'PRIMARY';
      case 1:
        return 'JUNIOR';
      case 2:
        return 'SENIOR';
      case 3:
        return 'COLLEGE';
      default:
        return 'PRIMARY';
    }
  }
}

class PaperListTab extends StatefulWidget {
  final String level;

  const PaperListTab({super.key, required this.level});

  @override
  State<PaperListTab> createState() => _PaperListTabState();
}

class _PaperListTabState extends State<PaperListTab> {
  final List<Paper> _papers = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  final int _pageSize = 10;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadMorePapers();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMorePapers();
    }
  }

  Future<void> _loadMorePapers() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
            '${ApiConfig.SERVER_BASE_URL}/api/quiz/list?pageNo=$_currentPage&pageSize=$_pageSize&level=${widget.level}'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(
            const Utf8Decoder().convert(response.body.runes.toList()));
        final List<dynamic> content = data['content'];
        final newPapers = content.map((json) => Paper.fromJson(json)).toList();

        setState(() {
          _papers.addAll(newPapers);
          _currentPage++;
          _hasMore = newPapers.length == _pageSize;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load papers');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载失败: $e')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshPapers() async {
    setState(() {
      _papers.clear();
      _currentPage = 1;
      _hasMore = true;
    });
    await _loadMorePapers();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshPapers,
      child: _papers.isEmpty && _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: _papers.length + (_hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _papers.length) {
                  return _isLoading
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : const SizedBox();
                }

                final paper = _papers[index];
                return Card(
                  child: ListTile(
                    title: Text(paper.title),
                    subtitle: const Text(''),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PaperDetailScreen(paperId: paper.quizId),
                        ),
                      ).then((_) => _refreshPapers());
                    },
                  ),
                );
              },
            ),
    );
  }
}
