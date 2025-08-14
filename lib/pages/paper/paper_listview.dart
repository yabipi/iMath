import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config/api_config.dart';
import '../../models/paper.dart';
import 'paper_detail_screen.dart';

class PaperListView extends StatefulWidget {
  // final String level;

  const PaperListView({super.key});

  @override
  State<PaperListView> createState() => _PaperListViewState();
}

class _PaperListViewState extends State<PaperListView> {
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
            '${ApiConfig.SERVER_BASE_URL}/api/paper/list?pageNo=$_currentPage&pageSize=$_pageSize'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> content = data['data'] ?? [];

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
                    subtitle: Text('创建时间: ${paper.createTime}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaperDetailScreen(
                              paperId: paper.id, paperTitle: paper.title),
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
