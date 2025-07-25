import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:imath/http/culture.dart';
import 'package:imath/config/api_config.dart';

class AddMathematicianScreen extends StatefulWidget {
  const AddMathematicianScreen({super.key});

  @override
  _AddMathematicianScreenState createState() => _AddMathematicianScreenState();
}

class _AddMathematicianScreenState extends State<AddMathematicianScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _introductionController = TextEditingController();
  // final TextEditingController _biographyController = TextEditingController();
  
  String? _selectedImage; // 存储选中的图片URL

  // 图片上传相关方法
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
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
          final fileUrl = data['fileUrl'];
          // 将 HTTP 替换为 HTTPS
          final secureUrl = fileUrl.replaceFirst('http://', 'https://');
          debugPrint('Image URL: ${secureUrl}');
          setState(() {
            _selectedImage = secureUrl;
          });
        } else {
          throw Exception('图片上传失败');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('图片上传失败: $e')),
        );
      }
    }
  }

  // 删除选中的图片
  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  // 构建图片上传区域
  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text('上传数学家照片：'),
        ),
        Row(
          children: [
            if (_selectedImage != null)
              Stack(
                children: [
                  Image.network(
                    _selectedImage!,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      debugPrint('图片加载失败: ${_selectedImage} ${error}');
                      return Container(
                        width: 120,
                        height: 120,
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
                    headers: {
                      'Accept': 'image/*',
                    },
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: _removeImage,
                    ),
                  ),
                ],
              ),
            if (_selectedImage == null)
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
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: const Icon(Icons.add_a_photo, size: 40),
                ),
              ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('添加数学家'),
        actions: [
          TextButton(
            onPressed: () async {
              await _submit();
            },
            child: const Icon(Icons.save)
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: '数学家名称'),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: '简介标题'),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _introductionController,
              decoration: const InputDecoration(labelText: '完整介绍'),
              maxLines: 3,
            ),
            const SizedBox(height: 16.0),
            Expanded(child: _buildImageSection()),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    await CultureHttp.addMathematician({
      "name": _nameController.text,
      "title": _titleController.text,
      "introduction": _introductionController.text,
      "image": _selectedImage ?? "", // 添加图片URL
    });
    context.go('/culture');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _titleController.dispose();
    _introductionController.dispose();

    super.dispose();
  }
}