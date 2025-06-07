import 'package:flutter/material.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:http/http.dart' as http;

import 'package:imath/components/math_cell.dart';

import 'dart:convert';
import '../config/api_config.dart';
import '../config/constants.dart';
import '../core/context.dart';
import '../models/quiz.dart';
import 'edit_question.dart';

class QuestionListview extends StatefulWidget {
  const QuestionListview({super.key});

  @override
  State<QuestionListview> createState() => _QuestionListviewState();
}

class _QuestionListviewState extends State<QuestionListview> {
  final List<Question> _questions = [];
  final Map<int, bool> _expandedStates = {};
  bool _isLoading = false;
  int _currentPage = 1;
  bool _hasMore = true;
  int? _selectedCategoryId = -1;
  bool _isSlidingMode = false; // 新增：滑动模式开关

  @override
  void initState() {
    super.initState();
    _loadMoreQuestions(categoryId: -1);
  }

  Future<void> _loadMoreQuestions({int? categoryId}) async {
    debugPrint('load more ......');
    // if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      debugPrint('load more ...');
      final response = await http.get(
        Uri.parse(
          '${ApiConfig.SERVER_BASE_URL}/api/question/list?pageNo=$_currentPage&pageSize=10&categoryId=${categoryId??_selectedCategoryId}',
        ),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> content = data['data'] ?? [];

        final newQuestions = content
            .map((json) {
          try {
            return Question.fromJson(json);
          } catch (e) {
            print('Error parsing question: $e');
            print('JSON data: $json');
            return null;
          }
        })
            .whereType<Question>()
            .toList();

        setState(() {
          _questions.clear(); // 清空原有数据
          _questions.addAll(newQuestions);
          _currentPage = 1; // 重置分页
          _hasMore = newQuestions.isNotEmpty;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load questions');
      }
    } catch (e) {
      print('Error loading questions: $e');
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

  void _filterQuestionsByCategory(int categoryId) {
    debugPrint('categoryId === ${categoryId}');
    setState(() {
      _selectedCategoryId = categoryId;
    });
    _loadMoreQuestions(categoryId: categoryId);
  }

  Widget _buildCategoryChips() {
    final categories = Context().get(CATEGORIES_KEY) as Map<int, String>?;

    if (categories == null || categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return ExpansionTile(
      title: const Text('选择分类'),
      children: [
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: [
            ChoiceChip(
              label: const Text('全部'),
              selected: _selectedCategoryId == -1,
              onSelected: (selected) {
                if (selected) {
                  _filterQuestionsByCategory(-1); // 清空分类筛选
                }
              },
            ),
            ...categories.entries.map((entry) {
              final categoryId = entry.key;
              final categoryName = entry.value;

              return ChoiceChip(
                label: Text(categoryName),
                selected: _selectedCategoryId == categoryId,
                onSelected: (selected) {
                  if (selected) {
                    _filterQuestionsByCategory(categoryId);
                  } else {
                    _filterQuestionsByCategory(-1); // 清空筛选
                  }
                },
              );
            }).toList(),
          ],
        ),
      ],
    );
  }

  Widget _buildQuestionCard(Question question, int index) {
    if (question.title == null) {
      return const Card(
        child: ListTile(
          title: Text('无效的题目数据'),
        ),
      );
    }

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
            GptMarkdown(
              question.title??'',
              style: const TextStyle(color: Colors.black),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _expandedStates[index] = !isExpanded;
                    });
                  },
                  child: Text(isExpanded ? '收起详情' : '查看详情'),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    // 跳转到问题编辑页面
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuestionEditScreen(
                          questionId: question.id,
                          onQuestionUpdated: _loadMoreQuestions, // 传递回调函数
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            if (isExpanded) ...[
              const Divider(),
              const Text(
                '题目分析:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              MathCell(title: question.title ?? '', content: question.content ?? ''),
              const SizedBox(height: 8),
              const Text(
                '答案:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              MathCell(title: question.answer ?? '', content: ''),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSlidingQuestionCard(Question question) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '第${_questions.indexOf(question) + 1}题',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            GptMarkdown(
              question.title ?? '',
              style: const TextStyle(color: Colors.black),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _expandedStates[_questions.indexOf(question)] =
                          !(_expandedStates[_questions.indexOf(question)] ?? false);
                    });
                  },
                  child: Text(
                    _expandedStates[_questions.indexOf(question)] ?? false
                        ? '收起详情'
                        : '查看详情',
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuestionEditScreen(
                          questionId: question.id,
                          onQuestionUpdated: _loadMoreQuestions,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            if (_expandedStates[_questions.indexOf(question)] ?? false) ...[
              const Divider(),
              const Text(
                '题目分析:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              MathCell(title: question.title ?? '', content: question.content ?? ''),
              const SizedBox(height: 8),
              const Text(
                '答案:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              MathCell(title: question.answer ?? '', content: ''),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: _buildCategoryChips(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                setState(() {
                  _isSlidingMode = false;
                });
              },
              child: Text('列表模式', style: TextStyle(color: _isSlidingMode ? Colors.grey : Colors.blue)),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _isSlidingMode = true;
                });
              },
              child: Text('滑动模式', style: TextStyle(color: _isSlidingMode ? Colors.blue : Colors.grey)),
            ),
          ],
        ),
        Expanded(
          child: _isSlidingMode
              ? PageView.builder(
                  scrollDirection: Axis.vertical, // 修改：将滑动方向改为垂直
                  itemCount: _questions.length,
                  itemBuilder: (context, index) {
                    return _buildSlidingQuestionCard(_questions[index]);
                  },
                )
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
                            onPressed: () => _loadMoreQuestions(categoryId: _selectedCategoryId),
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
        ),
      ],
    );
  }
}
