import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
// import 'package:flutter_tex/flutter_tex.dart';
// import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:http/http.dart' as http;
import 'package:imath/components/math_cell.dart';
import 'dart:convert';
import '../config/api_config.dart';
import '../http/init.dart';
import '../models/quiz.dart';
import '../utils/math_parser.dart';
import 'add_question_screen.dart';

class PaperDetailScreen extends StatefulWidget {
  final int paperId;
  final String paperTitle;
  const PaperDetailScreen(
      {super.key, required this.paperId, required this.paperTitle});

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
      debugPrint('加载题目: ${widget.paperId}');
      final response = await Request().get(
          '${ApiConfig.SERVER_BASE_URL}/api/paper/questions?paperId=${widget.paperId}'
      );

      if (response.statusCode == 200) {
        // final Map<String, dynamic> data = jsonDecode(response.body);
        // final List<dynamic> content = jsonDecode(
        //     const Utf8Decoder().convert(response.body.runes.toList()));
        // final Map<String, dynamic> data = jsonDecode(response.body);
        final Map<String, dynamic> data = response.data;
        final List<dynamic> content = data['data'] ?? [];
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
            // buildMixedText(question.title),
            MathCell(title: question.title ?? '', content: question.title ?? ''),
            // GptMarkdown(
            //   question.title??'',
            //   style: const TextStyle(color: Colors.black),
            // ),
            // TeX2SVG(
            //   teXInputType: TeXInputType.teX,
            //   math: question.title??'',
            // ),
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
              MathCell(title: question.title ?? '', content: question.content ?? ''),
              // GptMarkdown(
              //   question.content??'',
              //   style: const TextStyle(color: Colors.black),
              // ),
              // TeX2SVG(
              //   teXInputType: TeXInputType.teX,
              //   math: question.content??'',
              // ),
              const SizedBox(height: 8),
              const Text(
                '答案:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              // buildMixedText(question.answer),
              MathCell(title: '', content: question.answer ?? ''),
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
        title: Text(widget.paperTitle),
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
                  // if (_hasMore) {
                  //   return Center(
                  //     child: TextButton(
                  //       onPressed: _loadMoreQuestions,
                  //       child: const Text('加载更多'),
                  //     ),
                  //   );
                  // }
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
