import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:http/http.dart' as http;
import 'package:imath/config/constants.dart';
import 'package:imath/core/context.dart';
import 'package:imath/mixins/category_mixin.dart';
import '../../config/api_config.dart';
import '../../http/init.dart';

class EditKnowledgeView extends ConsumerStatefulWidget {
  final int knowledgeId;
  const EditKnowledgeView({super.key, required this.knowledgeId});

  @override
  ConsumerState<EditKnowledgeView> createState() => _EditKnowledgeViewState();
}

class _EditKnowledgeViewState extends ConsumerState<EditKnowledgeView> with CategoryMixin {
  int knowledgeId = 0;
  late Map<String, String> categories;
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _levelController = TextEditingController();
  String? _selectedCategory;
  bool _isSubmitting = false;

  @override
  void initState(){
    super.initState();
    _fetchKnowledge();
  }

  Future<void> _fetchKnowledge() async {
    // knowledgeId = Get.arguments['knowledgeId'] as int;
    final response = await Request().get('${ApiConfig.SERVER_BASE_URL}/api/know/${widget.knowledgeId}');
    String title = response.data['know_item']['Title'];
    String content = response.data['know_item']['Content'];
    String category = response.data['know_item']['category'];

    setState(() {
      _titleController.text = title;
      _contentController.text = content ?? '';
      // 修改: 使用函数式编程找到对应的分类ID
      _selectedCategory = category;
      // _selectedCategory = categories?.entries.firstWhere((entry) => entry.value == category).key as int ?? 0;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _levelController.dispose();
    super.dispose();
  }

  Future<void> _updateKnowledge() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final response = await Request().put(
        '${ApiConfig.SERVER_BASE_URL}/api/know/${widget.knowledgeId}',
        options: Options(contentType: Headers.jsonContentType),
        data: {
          'title': _titleController.text,
          'content': _contentController.text,
          'category': categories?[_selectedCategory],
          // 'level': _levelController.text,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('知识点修改成功')),
          );
          context.go('/knowledge');
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
    categories = getCategories(ref);
    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑知识点'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: '数学分支',
                  border: OutlineInputBorder(),
                ),
                items: categories?.values?.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue!;
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

              Row(
                children: [
                  Spacer(),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _updateKnowledge,
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
