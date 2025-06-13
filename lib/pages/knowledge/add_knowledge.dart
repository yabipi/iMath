import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:imath/config/constants.dart';
import 'package:imath/core/context.dart';
import '../../config/api_config.dart';
import '../../http/init.dart';

class AddKnowledgeView extends StatefulWidget {
  const AddKnowledgeView({super.key});

  @override
  State<AddKnowledgeView> createState() => _AddKnowledgeViewState();
}

class _AddKnowledgeViewState extends State<AddKnowledgeView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _levelController = TextEditingController();
  int _selectedBranch = 0;
  bool _isSubmitting = false;

  final categories = Context().get(CATEGORIES_KEY) as Map<int, String>?;

  @override
  void initState() {
    super.initState();
    final String? content = Get.arguments['markdownContent'] as String?;
    _contentController.text = content ?? '';
    // _contentController.text =
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _levelController.dispose();
    super.dispose();
  }

  Future<void> _submitKnowledge() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final response = await Request().post(
        '${ApiConfig.SERVER_BASE_URL}/api/know/create',
        options: Options(contentType: Headers.jsonContentType),
        data: {
          'title': _titleController.text,
          'content': _contentController.text,
          'category': categories?[_selectedBranch],
          // 'level': _levelController.text,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('知识点添加成功')),
          );
          // Navigator.pop(context, true);
          Get.toNamed('/knowledge');
        }
      } else {
        throw Exception('Failed to add knowledge');
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
        title: const Text('添加知识点'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<int>(
                value: categories!.keys.first,
                decoration: const InputDecoration(
                  labelText: '数学分支',
                  border: OutlineInputBorder(),
                ),
                items: categories?.keys?.map((int id) {
                  return DropdownMenuItem<int>(
                    value: id,
                    child: Text(categories![id]!),
                  );
                }).toList(),
                onChanged: (int? newValue) {
                  setState(() {
                    _selectedBranch = newValue!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '知识点标题',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入知识点标题';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: '知识点内容',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入知识点内容';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _levelController,
                decoration: const InputDecoration(
                  labelText: '适用年级',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  // if (value == null || value.isEmpty) {
                  //   return '请输入适用年级';
                  // }
                  // return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitKnowledge,
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
