import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart'; // 引入 image_picker 包
import 'dart:io'; // 引入 File 类

import '../../config/api_config.dart';
import '../../config/constants.dart';
import '../../core/context.dart';
import '../../http/init.dart';

class AddQuestionScreen extends StatefulWidget {
  final int paperId;

  AddQuestionScreen({super.key, required this.paperId});

  @override
  State<AddQuestionScreen> createState() => _AddQuestionScreenState();
}

class _AddQuestionScreenState extends State<AddQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _optionController = TextEditingController();
  final _contentController = TextEditingController();
  final _answerController = TextEditingController();
  int _selectedBranch = 0;
  String _selectedType = QuestionTypes[0];
  final List<TextEditingController> _optionControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  bool _isSubmitting = false;
  List<String> _selectedImages = []; // 新增：存储选中的图片文件

  // 获取全局 Context 实例
  // final Context _context = Context();
  // 使用 Context 获取全局数据
  late Map<String, dynamic> categories;

  @override
  void initState() {
    super.initState();
    // final String? content = Get.arguments['markdownContent'] as String?;
    String? content = '';
    _contentController.text = content ?? '';
    // 获取全局数据
    // categories;
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

  // 修改：增强图片加载逻辑，支持自签署证书
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
            // 显示已上传的图片缩略图
            for (int i = 0; i < _selectedImages.length; i++)
              Stack(
                children: [
                  // 使用网络图片显示缩略图
                  Image.network(
                    _selectedImages[i],
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      debugPrint('图片加载失败: ${_selectedImages[i]} ${error}');
                      // 新增：显示灰色背景及错误图标
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
                    // 新增：忽略自签署证书
                    headers: {
                      'Accept': 'image/*',
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
            // 如果图片数量未达到上限，显示添加图片按钮
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

  // 新增：全局设置忽略自签署证书
  void _initHttpClient() {
    final httpClient = HttpClient();
    httpClient.badCertificateCallback = (X509Certificate cert, String host, int port) {
      debugPrint('Ignoring self-signed certificate for $host:$port');
      return true; // 忽略证书验证
    };
  }

  // @override
  // void initState() {
  //   super.initState();
  //   _initHttpClient(); // 初始化时设置忽略自签署证书
  // }

  // 修改：确保图片 URL 使用 HTTPS 协议
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null && _selectedImages.length < 5) {
      try {
        // 调用后台接口上传图片
        final request = http.MultipartRequest(
          'POST',
          Uri.parse('${ApiConfig.SERVER_BASE_URL}/api/picture/upload'),
        );
        request.files.add(await http.MultipartFile.fromPath('file', pickedFile.path));
        final response = await request.send();

        if (response.statusCode == 200) {
          final responseBody = await response.stream.bytesToString();
          final data = json.decode(responseBody);
          final fileUrl = data['fileUrl']; // 获取返回的 fileId
          // 新增：将 HTTP 替换为 HTTPS
          final secureUrl = fileUrl.replaceFirst('http://', 'https://');
          debugPrint('Image URL: ${secureUrl}');
          setState(() {
            _selectedImages.add(secureUrl); // 存储安全的图片 URL
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

  // 新增：删除选中的图片
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  // 修改：提交题目时不再上传图片，直接使用已有的 fileId 列表
  Future<void> _submitQuestion() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // 构建选项数据
      // List<Map<String, String>> options = [];
      // if (_selectedType == QuestionTypes[0] || _selectedType == QuestionTypes[1]) {
      //   for (int i = 0; i < _optionControllers.length; i++) {
      //     if (_optionControllers[i].text.isNotEmpty) {
      //       options.add({
      //         'label': String.fromCharCode(65 + i),
      //         // 'content': _optionControllers[i].text,
      //         'content': _optionController.text,
      //       });
      //     }
      //   }
      // }

      final response = await Request().post(
        '${ApiConfig.SERVER_BASE_URL}/api/question/create',
        options: Options(contentType: Headers.jsonContentType),
        data: {
          // 'title': _titleController.text,
          'content': _contentController.text,
          'options': _optionController.text,
          'answer': _answerController.text,
          'category': categories?[_selectedBranch],
          'type': _selectedType,
          'images': _selectedImages.join(','), // 直接使用 fileId 列表
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('题目添加成功')),
          );
          // Navigator.pop(context, true);
          // Get.toNamed('/questions');
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

  Widget _buildSingleOptionsSection() {
    if (_selectedType != QuestionTypes[0] && _selectedType != QuestionTypes[1]) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // const Padding(
        //   padding: EdgeInsets.symmetric(vertical: 8.0),
        //   child: Text('选项：'),
        // ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: TextFormField(
            controller: _optionController,
            decoration: InputDecoration(
              labelText: '选项',
              border: const OutlineInputBorder(),
            ),
            validator: (value) {
              if (_selectedType == QuestionTypes[0] && value!.isEmpty) {
                return '请输入选项内容';
              }
              return null;
            },
          ),
        )
      ],
    );
  }

  Widget _buildOptionsSection() {
    if (_selectedType != QuestionTypes[0] && _selectedType != QuestionTypes[1]) {
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
                if (_selectedType == QuestionTypes[0] && value!.isEmpty) {
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
    categories = context.get(CATEGORIES_KEY);
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
              DropdownButtonFormField<int>(
                value: categories!.keys.first as int?,
                decoration: const InputDecoration(
                  labelText: '数学分支',
                  border: OutlineInputBorder(),
                ),
                items: categories?.keys?.map((String id) {
                  return DropdownMenuItem<int>(
                    value: id as int?,
                    child: Text(categories![id]!),
                  );
                }).toList(),
                onChanged: (int? newValue) {
                  setState(() {
                    // print('set _selectedBranch = $newValue');
                    _selectedBranch = newValue!;
                    // print('_selectedBranch = $_selectedBranch');
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
                controller: _contentController,
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
              // _buildOptionsSection(),
              _buildSingleOptionsSection(),
              const SizedBox(height: 16),
              _buildImageSection(), // 新增：图片上传部分
              // const SizedBox(height: 16),
              // TextFormField(
              //   controller: _contentController,
              //   decoration: const InputDecoration(
              //     labelText: '题目解析',
              //     border: OutlineInputBorder(),
              //   ),
              //   maxLines: 3,
              //   validator: (value) {
              //     // if (value == null || value.isEmpty) {
              //     //   return '请输入题目解析';
              //     // }
              //     // return null;
              //   },
              // ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _answerController,
                decoration: const InputDecoration(
                  labelText: '解析和答案',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  // if (value == null || value.isEmpty) {
                  //   return '请输入答案';
                  // }
                  // return null;
                },
              ),
              const SizedBox(width:100, height: 24),
              Row(children: [
                Spacer(),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitQuestion,
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size(100, 50), // 设置固定宽度和高度
                    padding: EdgeInsets.zero, // 删除: padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
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
              ],),

            ],
          ),
        ),
      ),
    );
  }
} 













