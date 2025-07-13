import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:http/http.dart' as http;
import 'package:imath/config/constants.dart';
import 'package:imath/core/context.dart';
import 'package:imath/http/knowledge.dart';
import 'package:imath/mixins/category_mixin.dart';
import 'package:imath/providers/settings_provider.dart';
import '../../config/api_config.dart';
import '../../http/init.dart';

class AddKnowledgeView extends ConsumerStatefulWidget {
  const AddKnowledgeView({super.key});

  @override
  _AddKnowledgeViewState createState() => _AddKnowledgeViewState();
}

class _AddKnowledgeViewState extends ConsumerState<AddKnowledgeView> with CategoryMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _levelController = TextEditingController();
  String? _selectedCategory;
  bool _isSubmitting = false;

  late Map<String, String> categories;

  @override
  void initState() {
    super.initState();
    // categories = context.get(CATEGORIES_KEY);
    // debugPrint('');
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
      final data =  {
        'title': _titleController.text,
        'content': _contentController.text,
        'category': _selectedCategory,
        'level': ref.read(mathLevelProvider).value,
      };
      final response = await KnowledgeHttp.addKnowledge(data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('知识点添加成功')),
          );
          context.go('/knowledge');
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
    categories = getCategories(ref);
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
                      onPressed: _isSubmitting ? null : _submitKnowledge,
                      child: const Text('提交')
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
