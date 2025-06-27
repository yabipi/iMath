import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:imath/config/constants.dart';
import 'package:imath/core/context.dart';
import '../../config/api_config.dart';
import '../../http/init.dart';

class EditKnowledgeView extends StatefulWidget {
  // final int knowledgeId;
  const EditKnowledgeView({super.key});

  @override
  State<EditKnowledgeView> createState() => _EditKnowledgeViewState();
}

class _EditKnowledgeViewState extends State<EditKnowledgeView> {
  late Map<String, dynamic> categories;
  int knowledgeId = 0;

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _levelController = TextEditingController();
  int _selectedBranch = 0;
  bool _isSubmitting = false;



  @override
  void initState(){
    super.initState();
    _fetchKnowledge();
    // _contentController.text =
  }

  Future<void> _fetchKnowledge() async {
    // knowledgeId = Get.arguments['knowledgeId'] as int;
    final response = await Request().get('${ApiConfig.SERVER_BASE_URL}/api/know/${knowledgeId}');
    String title = response.data['know_item']['Title'];
    String content = response.data['know_item']['Content'];
    String category = response.data['know_item']['category'];

    setState(() {
      _titleController.text = title;
      _contentController.text = content ?? '';
      // 修改: 使用函数式编程找到对应的分类ID
      _selectedBranch = categories?.entries.firstWhere((entry) => entry.value == category).key as int ?? 0;
    });

    // print(_selectedBranch);
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
      final response = await Request().put(
        '${ApiConfig.SERVER_BASE_URL}/api/know/${knowledgeId}',
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
          // Get.toNamed('/knowledge');
        }
      } else {
        throw Exception('Failed to edit knowledge');
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
    categories = context.get(CATEGORIES_KEY);
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
                value: _selectedBranch == 0? categories?.keys.first as int? : _selectedBranch,
                decoration: const InputDecoration(
                  labelText: '数学分支',
                  border: OutlineInputBorder(),
                ),
                items: categories?.keys?.map((String id) {
                  return DropdownMenuItem<int>(
                    value: id as int,
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
              Row(
                children: [
                  Spacer(),
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
                  Spacer(),
                ]
              ),
            ],
          ),
        ),
      ),
    );
  }
}
