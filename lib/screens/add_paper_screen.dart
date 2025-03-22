import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';

class AddPaperScreen extends StatefulWidget {
  final String initialLevel;

  const AddPaperScreen({
    super.key, 
    this.initialLevel = 'PRIMARY', // 设置默认值为 'PRIMARY'
  });

  @override
  State<AddPaperScreen> createState() => _AddPaperScreenState();
}

class _AddPaperScreenState extends State<AddPaperScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  late String _selectedLevel;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedLevel = widget.initialLevel;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submitPaper() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      Map<String, String> params = {
          'title': _titleController.text,
          'content': _contentController.text
          // 'level': _selectedLevel,
        };
      // 对请求参数进行urlencode
      // String encodedParams = Uri(queryParameters: params).buildQueryParameters();
      final response = await http.post(
        Uri.parse('http://192.168.1.100:8080/api/quiz'),
        headers: {
           'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: params
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('试卷添加成功')),
          );
          Navigator.pop(context, true); // 返回并传递成功标志
        }
      } else {
        throw Exception('Failed to submit paper');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('提交失败: $e')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('添加试卷'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedLevel,
                decoration: const InputDecoration(
                  labelText: '试卷级别',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'PRIMARY', child: Text('小学')),
                  DropdownMenuItem(value: 'JUNIOR', child: Text('初中')),
                  DropdownMenuItem(value: 'SENIOR', child: Text('高中')),
                  DropdownMenuItem(value: 'COLLEGE', child: Text('大学')),
                ],
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedLevel = newValue;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '试卷标题',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入试卷标题';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: '试卷说明',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入试卷说明';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitPaper,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('完成'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 