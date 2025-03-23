import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_math_fork/flutter_math.dart';
import 'dart:convert';
import '../models/quiz.dart';

class QuestionListScreen extends StatefulWidget {
  const QuestionListScreen({super.key});

  @override
  State<QuestionListScreen> createState() => _QuestionListScreenState();
}

class _QuestionListScreenState extends State<QuestionListScreen> {
  final List<Question> _questions = [];
  final Map<int, bool> _expandedStates = {};
  bool _isLoading = false;
  int _currentPage = 1;
  bool _hasMore = true;

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
        Uri.parse('${ApiConfig.SERVER_BASE_URL}/api/questions?pageNo=$_currentPage&pageSize=10'),
      );

      if (response.statusCode == 200) {
        // final Map<String, dynamic> data = jsonDecode(response.body);
        final Map<String, dynamic> data = jsonDecode(Utf8Decoder().convert(response.body.runes.toList()));
        //  json.decode(const Utf8Decoder().convert(你的json字符串.runes.toList()));


        final List<dynamic> content = data['content'];
        final newQuestions = content.map((json) => Question.fromJson(json)).toList();
        
        setState(() {
          _questions.addAll(newQuestions);
          _currentPage++;
          _hasMore = newQuestions.isNotEmpty;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load questions');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('加载失败: $e')),
      );
    }
  }

  Widget _buildQuestionCard(Question question, int index) {
    bool isExpanded = _expandedStates[index] ?? false;

    // 处理单行文本中的混合内容（普通文本和数学公式）
    Widget buildLineContent(String line) {
      final List<Widget> widgets = [];
      final RegExp latexPattern = RegExp(r'\\\((.*?)\\\)|\$(.*?)\$');

      int lastIndex = 0;

      // 在一行中查找所有的数学公式
      for (final Match match in latexPattern.allMatches(line)) {
        // 添加公式前的普通文本
        if (match.start > lastIndex) {
          // String txt = Utf8Decoder().convert(line.substring(lastIndex, match.start));
          widgets.add(
            Text(
              line.substring(lastIndex, match.start),
              style: const TextStyle(fontSize: 16),
            ),
          );
        }

        // 添加数学公式（去掉首尾的$符号）
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

      // 添加最后一段普通文本（如果有的话）
      if (lastIndex < line.length) {
        // String txt = Utf8Decoder().convert(line.substring(lastIndex));
        widgets.add(
          Text(
            line.substring(lastIndex),
            style: const TextStyle(fontSize: 16),
          ),
        );
      }

      return Wrap(
        children: widgets,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 4,
      );
    }

    // 处理多行文本
    Widget buildMixedText(String text) {
      final lines = text.split('\n');
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: lines.map((line) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: buildLineContent(line),
        )).toList(),
      );
    }

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
        title: const Text('题目列表'),
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
    );
  }
}