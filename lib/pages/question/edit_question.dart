import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:imath/config/constants.dart';
import 'package:imath/http/question.dart';
import 'package:imath/mixins/category_mixin.dart';
import 'package:imath/models/question.dart';
import 'package:imath/state/global_state.dart';
import 'package:imath/state/questions_provider.dart';

import '../../config/api_config.dart';
import 'package:imath/core/context.dart';


class QuestionEditView extends ConsumerStatefulWidget {
  final int questionId;
  const QuestionEditView({super.key, required this.questionId});

  @override
  ConsumerState<QuestionEditView> createState() => _QuestionEditViewState();
}

class _QuestionEditViewState extends ConsumerState<QuestionEditView> with CategoryMixin{
  final _formKey = GlobalKey<FormState>();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _contentController = TextEditingController();
  TextEditingController _optionsController = TextEditingController();
  TextEditingController _answerController = TextEditingController();

  late int _questionId;
  int selectedBranch = ALL_CATEGORY;
  String selectedType = QuestionTypes[0];
  bool loaded = false; // 标记是否已经初始化

  // 获取全局 Context 实例
  late Map<String, dynamic> categories;

  bool _isSubmitting = false;
  List<String> _selectedImages = [];

  @override
  void initState() {
    super.initState();
    _questionId = widget.questionId;
  }

  @override
  void dispose() {
    super.dispose();
  }

  // 加载题目数据
  Future<void> loadQuestion() async {
    if (loaded) {
      return;
    }
    try {
      final Question? question = await QuestionHttp.getQuestion(_questionId);
      if (question != null) {
        _titleController.text = question.title ?? '';
        _contentController.text = question.content ?? '';
        _optionsController.text = question.options ?? '';
        _answerController.text = question.answer ?? '';
        selectedBranch = question.categoryId ?? ALL_CATEGORY;

        selectedType = (question.type??'').isEmpty ? QuestionTypes[0] : question.type!;
        _selectedImages = question.images?.split(',') ?? [];
      }
      loaded = true;
    } catch (e) {
      return;
    }
  }
  // 提交题目编辑
  Future<void> updateQuestion() async {
    try {
      QuestionHttp.updateQuestion(widget.questionId, {
        'categoryId': selectedBranch,
        'title': _titleController.text,
        'content': _contentController.text,
        'options': _optionsController.text,
        'answer': _answerController.text,
        'type': selectedType,
        'images': _selectedImages.join(','),
      });
      // 刷新题目列表 - 使用 invalidate 方法
      ref.invalidate(questionsProvider);
      context.go('/questions');

    } catch (e) {
      rethrow;
    } finally {

    }
  }
  // 图片上传逻辑
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null && _selectedImages.length < 5) {
      try {
        final request = http.MultipartRequest(
          'POST',
          Uri.parse('${ApiConfig.SERVER_BASE_URL}/api/picture/upload'),
        );
        request.files.add(await http.MultipartFile.fromPath('file', pickedFile.path));
        final response = await request.send();

        if (response.statusCode == 200) {
          final responseBody = await response.stream.bytesToString();
          final data = json.decode(responseBody);
          final fileUrl = data['fileUrl'];
          final secureUrl = fileUrl.replaceFirst('http://', 'https://');
          setState(() {
            _selectedImages = [..._selectedImages, secureUrl];
          });
        } else {
          throw Exception('图片上传失败');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('图片上传失败: $e')),
        );
      }
    } else if (_selectedImages.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('最多只能上传5张图片')),
      );
    }
  }

  // 删除图片
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    categories = getCategories(ref);
    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑题目'),
        actions: [
          TextButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                setState(() {
                  _isSubmitting = true;
                });
                await updateQuestion();
                setState(() {
                  _isSubmitting = false;
                });
              }
            },
            child: const Icon(Icons.save),
          ),
        ],
      ),

      body: FutureBuilder(
        future: loadQuestion(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done){
            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedBranch.toString(),
                      decoration: const InputDecoration(
                        labelText: '数学分支',
                        border: OutlineInputBorder(),
                      ),
                      items: categories?.keys.map<DropdownMenuItem<String>>((String id) {
                        // print(controller.categories![id]);
                        return DropdownMenuItem<String>(
                          value: id,
                          child: Text(categories![id]!),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        selectedBranch = int.parse(newValue!);
                      },
                    ),

                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedType,
                      decoration: const InputDecoration(
                        labelText: '题目类型',
                        border: OutlineInputBorder(),
                      ),
                      items: QuestionTypes.map<DropdownMenuItem<String>>((String type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        selectedType = newValue!;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: '题目标题',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 1,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入题目标题';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _contentController,
                      decoration: const InputDecoration(
                        labelText: '题目内容',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        // if (value == null || value.isEmpty) {
                        //   return '请输入题目内容';
                        // }

                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _optionsController,
                      decoration: const InputDecoration(
                        labelText: '题目选项',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 4,
                      validator: (value) {

                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _answerController,
                      decoration: const InputDecoration(
                        labelText: '解析和答案',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 8,
                      validator: (value) {
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildImageSection(),
                  ],
                ),
              ),
            );
          } else {
            return _buildLoading();
          }
        }),
    );

  }

  Widget _buildLoading() {
    return const SizedBox(
      height: 100,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
  // 构建图片上传部分
  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text('上传图片：'),
        ),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: [
            for (int i = 0; i < _selectedImages.length; i++)
              Stack(
                children: [
                  Image.network(
                    _selectedImages[i],
                    width: 100,
                    height: 100,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey[200],
                        child: const Center(child: Icon(Icons.error)),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () => _removeImage(i),
                    ),
                  ),
                ],
              ),
            if (_selectedImages.length < 5)
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: const Icon(Icons.photo_library),
                            title: const Text('从相册选择'),
                            onTap: () {
                              Navigator.pop(context);
                              _pickImage(ImageSource.gallery);
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.camera_alt),
                            title: const Text('拍照'),
                            onTap: () {
                              Navigator.pop(context);
                              _pickImage(ImageSource.camera);
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: const Icon(Icons.add),
                ),
              ),
          ],
        ),
      ],
    );
  }
}