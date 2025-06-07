import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../config/api_config.dart';
import '../config/constants.dart';
import '../core/context.dart';
import '../models/quiz.dart';

class QuestionEditScreen extends StatefulWidget {
  final int questionId;
  final VoidCallback? onQuestionUpdated; // 新增：回调函数

  const QuestionEditScreen({super.key, required this.questionId, this.onQuestionUpdated});

  @override
  State<QuestionEditScreen> createState() => _QuestionEditScreenState();
}

class _QuestionEditScreenState extends State<QuestionEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _answerController = TextEditingController();
  int? _selectedBranch = 0;
  String _selectedType = QuestionTypes[0];
  final List<TextEditingController> _optionControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  bool _isSubmitting = false;
  List<String> _selectedImages = [];

  // 获取全局 Context 实例
  final categories = Context().get(CATEGORIES_KEY) as Map<int, String>?;

  @override
  void initState() {
    super.initState();
    _loadQuestionData();
    _initHttpClient();
  }

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

  // 初始化 HttpClient，忽略自签署证书
  void _initHttpClient() {
    final httpClient = HttpClient();
    // httpClient.badCertificateCallback = (X509Certificate cert, String host, int port) {
    //   debugPrint('Ignoring self-signed certificate for $host:$port');
    //   return true; // 忽略证书验证
    // };
  }

  // 加载题目数据
  Future<void> _loadQuestionData() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.SERVER_BASE_URL}/api/question/${widget.questionId}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final question = Question.fromJson(data);

        setState(() {
          _titleController.text = question.title ?? '';
          _contentController.text = question.content ?? '';
          _answerController.text = question.answer ?? '';
          if (question.category == '') {
            _selectedBranch = (categories?.keys.first)!;
          } else {
            _selectedBranch = categories?.keys.firstWhere((key) => categories![key] == question.category) ;
          }

          _selectedType = (question.type??'').isEmpty ? QuestionTypes[0] : question.type!;
          _selectedImages = question.images?.split(',') ?? [];
          // if (_selectedType == QuestionTypes[0] || _selectedType == QuestionTypes[1]) {
          //   for (int i = 0; i < question.options?.length; i++) {
          //     _optionControllers[i].text = question.options?[i]['content'] ?? '';
          //   }
          // }
        });
      } else {
        throw Exception('Failed to load question');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('加载题目失败: $e')),
      );
    }
  }

  // 提交题目编辑
  Future<void> _updateQuestion() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // 构建选项数据
      List<Map<String, String>> options = [];
      if (_selectedType == QuestionTypes[0] || _selectedType == QuestionTypes[1]) {
        for (int i = 0; i < _optionControllers.length; i++) {
          if (_optionControllers[i].text.isNotEmpty) {
            options.add({
              'label': String.fromCharCode(65 + i),
              'content': _optionControllers[i].text,
            });
          }
        }
      }

      final response = await http.put(
        Uri.parse('${ApiConfig.SERVER_BASE_URL}/api/question/${widget.questionId}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'title': _titleController.text,
          'content': _contentController.text,
          'answer': _answerController.text,
          'category': categories?[_selectedBranch],
          'type': _selectedType,
          'options': options,
          'images': _selectedImages.join(','),
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('题目更新成功')),
        );
        Navigator.pop(context, true);

        // 调用回调函数刷新题目列表
        widget.onQuestionUpdated?.call();
      } else {
        throw Exception('Failed to update question');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('更新失败: $e')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
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
            _selectedImages.add(secureUrl);
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑题目'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<int>(
                value: _selectedBranch,
                decoration: const InputDecoration(
                  labelText: '数学分支',
                  border: OutlineInputBorder(),
                ),
                items: categories?.keys.map((int id) {
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
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: '题目类型',
                  border: OutlineInputBorder(),
                ),
                items: QuestionTypes.map((String type) {
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
              _buildImageSection(),
              Row(children: [
                Spacer(),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _updateQuestion,
                  child: _isSubmitting
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Text('提交'),
                ),
                Spacer()
              ])
            ],
          ),
        ),
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
                    fit: BoxFit.cover,
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