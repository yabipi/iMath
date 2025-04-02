import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import '../models/quiz.dart';
import 'add_question_screen.dart';

class PaperDetailScreen extends StatefulWidget {
  final int paperId;

  const PaperDetailScreen({super.key, required this.paperId});

  @override
  State<PaperDetailScreen> createState() => _PaperDetailScreenState();
}

class _PaperDetailScreenState extends State<PaperDetailScreen> {
  final List<Question> _questions = [];
  final Map<int, bool> _expandedStates = {};
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  final int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _loadMoreQuestions();
  }

  Future<void> _loadMoreQuestions() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
            '${ApiConfig.SERVER_BASE_URL}/api/quiz/listquestions?quizId=${widget.paperId}'),
      );

      if (response.statusCode == 200) {
        // final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> content = jsonDecode(
            const Utf8Decoder().convert(response.body.runes.toList()));
        // final List<dynamic> content = jsonDecode(response.body);
        // print(content);
        final newQuestions =
            content.map((json) => Question.fromJson(json)).toList();

        setState(() {
          _questions.addAll(newQuestions);
          _currentPage++;
          _hasMore = newQuestions.length == _pageSize;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load questions');
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

  Widget buildMixedText(String? text) {
    if (text == null || text.isEmpty) {
      return const Text('');
    }

    final List<Widget> widgets = [];
    // final RegExp latexPattern = RegExp(r'\$(.*?)\$');
    final RegExp latexPattern = RegExp(r'\\\((.*?)\\\)|\$(.*?)\$');
    int lastIndex = 0;

    for (final Match match in latexPattern.allMatches(text)) {
      if (match.start > lastIndex) {
        widgets.add(
          Text(
            text.substring(lastIndex, match.start),
            style: const TextStyle(fontSize: 16),
          ),
        );
      }

      final formula = match.group(1)!;
      widgets.add(
        Math.tex(
          formula,
          textStyle: const TextStyle(fontSize: 16),
          mathStyle: MathStyle.text,
        ),
      );

      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      widgets.add(
        Text(
          text.substring(lastIndex),
          style: const TextStyle(fontSize: 16),
        ),
      );
    }

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      children: widgets,
    );
  }

  Widget _buildQuestionCard(Question question, int index) {
    bool isExpanded = _expandedStates[index] ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '第${index + 1}题',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            buildMixedText(question.title),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                setState(() {
                  _expandedStates[index] = !isExpanded;
                });
              },
              child: Text(isExpanded ? '收起详情' : '查看详情'),
            ),
            if (isExpanded) ...[
              const Divider(),
              const Text(
                '题目分析:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              buildMixedText(question.content),
              const SizedBox(height: 8),
              const Text(
                '答案:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              buildMixedText(question.answer),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('试卷详情'),
      ),
      body: _questions.isEmpty && _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _questions.length + 1,
              itemBuilder: (context, index) {
                if (index == _questions.length) {
                  if (_isLoading) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  if (_hasMore) {
                    return Center(
                      child: TextButton(
                        onPressed: _loadMoreQuestions,
                        child: const Text('加载更多'),
                      ),
                    );
                  }
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('没有更多题目了'),
                    ),
                  );
                }
                return _buildQuestionCard(_questions[index], index);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddQuestionScreen(paperId: widget.paperId),
            ),
          ).then((value) {
            if (value == true) {
              // 如果添加成功，刷新题目列表
              setState(() {
                _questions.clear();
                _currentPage = 1;
                _hasMore = true;
              });
              _loadMoreQuestions();
            }
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
