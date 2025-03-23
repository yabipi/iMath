import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddQuestionScreen extends StatefulWidget {
  final int paperId;

  const AddQuestionScreen({super.key, required this.paperId});

  @override
  State<AddQuestionScreen> createState() => _AddQuestionScreenState();
}

class _AddQuestionScreenState extends State<AddQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _answerController = TextEditingController();
  String _selectedType = 'SINGLE_CHOICE'; // 默认单选
  final List<TextEditingController> _optionControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  bool _isSubmitting = false;

  final List<String> _questionTypes = [
    'SINGLE_CHOICE',
    'MULTIPLE_CHOICE',
    'TRUE_FALSE',
    'FILL_BLANK',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _answerController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submitQuestion() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // 构建选项数据
      List<Map<String, String>> options = [];
      if (_selectedType == 'SINGLE_CHOICE' || _selectedType == 'MULTIPLE_CHOICE') {
        for (int i = 0; i < _optionControllers.length; i++) {
          if (_optionControllers[i].text.isNotEmpty) {
            options.add({
              'label': String.fromCharCode(65 + i), // A, B, C, D
              'content': _optionControllers[i].text,
            });
          }
        }
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.SERVER_BASE_URL}/api/papers/${widget.paperId}/questions'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'title': _titleController.text,
          'content': _contentController.text,
          'answer': _answerController.text,
          'type': _selectedType,
          'options': options,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('题目添加成功')),
          );
          Navigator.pop(context, true); // 返回并传递成功标志
        }
      } else {
        throw Exception('Failed to add question');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('添加失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Widget _buildOptionsSection() {
    if (_selectedType != 'SINGLE_CHOICE' && _selectedType != 'MULTIPLE_CHOICE') {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text('选项：'),
        ),
        ...List.generate(4, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: TextFormField(
              controller: _optionControllers[index],
              decoration: InputDecoration(
                labelText: '选项 ${String.fromCharCode(65 + index)}',
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (_selectedType == 'SINGLE_CHOICE' && value!.isEmpty) {
                  return '请输入选项内容';
                }
                return null;
              },
            ),
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('添加题目'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: '题目类型',
                  border: OutlineInputBorder(),
                ),
                items: _questionTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedType = newValue!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '题目内容',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入题目内容';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildOptionsSection(),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: '题目解析',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入题目解析';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _answerController,
                decoration: const InputDecoration(
                  labelText: '答案',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入答案';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitQuestion,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('提交'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 