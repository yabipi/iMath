import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:imath/config/api_config.dart';
import 'package:imath/pages/markdown_edit.dart';
import 'package:imath/utils/image_utils.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../services/camera_service.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

import '../question/add_question.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final _cameraService = CameraService();
  bool _isLoading = false;
  CroppedFile? _imageFile;
  String? _recognizedText;
  String? _latexText;
  String? _fileName;
  String? _filePath;

  Future<void> _takePicture() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final image = await _cameraService.takePicture();
      if (image != null) {
        final croppedImg = await ImageUtils.cropImage(image: image, width: 200, height: 200);
        setState(() {
          _imageFile = croppedImg;
        });
        // await _processImage(croppedImg);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('拍照失败: $e'),
            action: e.toString().contains('权限') ? SnackBarAction(
              label: '去设置',
              onPressed: () async {
                await openAppSettings();
              },
            ) : null,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> pickAndUploadFile() async {
    // 检查权限
    if (Platform.isAndroid || Platform.isIOS) {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('需要存储权限才能选择文件')),
        );
        return;
      }
    }

    try {
      // 选择文件
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,  // 可以选择任何类型文件
        allowMultiple: false,  // 是否允许多选
      );
      final croppedImg = await ImageUtils.cropImage(image: result?.files.single.path!, width: 200, height: 200);
      if (result != null) {
        setState(() {
          _fileName = result.files.single.name;
          _filePath = result.files.single.path;
          // _imageFile = File(result.files.single.path!);
          _imageFile = croppedImg;
        });

        // 上传文件
        // await _uploadFile(_filePath!);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('选择文件出错: $e')),
      );
    }
  }

  Future<void> _uploadFile(String filePath) async {
    if (filePath.isEmpty) return;

    setState(() {
      // _isUploading = true;
      // _uploadProgress = 0;
    });

    try {
      // 创建FormData
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(
          filePath,
          filename: path.basename(filePath),
        ),
        // 可以添加其他参数
        "other_field": "value",
      });

      // 使用Dio上传
      // Dio dio = Dio();
      // Response response = await dio.post(
      //   "https://your-server.com/upload",  // 替换为你的上传接口
      //   data: formData,
      //   onSendProgress: (int sent, int total) {
      //     setState(() {
      //       _uploadProgress = sent / total;
      //     });
      //   },
      // );

      // ScaffoldMessenger.of(context).showSnackBar(
      //   // SnackBar(content: Text('上传成功: ${response.data}')),
      // );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('上传失败: $e')),
      );
    } finally {
      setState(() {
        // _isUploading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final image = await _cameraService.pickImage();
      if (image != null) {
        final croppedImg = await ImageUtils.cropImage(image: image, width: 200, height: 200);
        setState(() {
          _imageFile = croppedImg;
        });
        // await _processImage(croppedImg);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('选择图片失败: $e'),
            action: e.toString().contains('权限') ? SnackBarAction(
              label: '去设置',
              onPressed: () async {
                await openAppSettings();
              },
            ) : null,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _processImage(File image) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _cameraService.processImage(image);
      if (result['success']) {
        setState(() {
          _recognizedText = result['text'];
          _latexText = result['latex'];
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'])),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('处理失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('请先拍照或选择图片')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final bytes = await _imageFile!.readAsBytes();
      final response = await http.post(
        Uri.parse('${ApiConfig.minerUrl}/api/image/upload'),
        body: bytes,
        headers: {'Content-Type': 'application/octet-stream'},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('上传成功')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('上传失败: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('上传失败: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _submitImage() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('请先拍照或选择图片')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final bytes = await _imageFile!.readAsBytes();
      final response = await http.post(
        Uri.parse('${ApiConfig.minerUrl}/api/image/upload'),
        body: bytes,
        headers: {'Content-Type': 'application/octet-stream'},
      );

      if (response.statusCode == 200) {
        // 解析返回的 JSON 数据
        final responseData = response.body;
        // final parsedData = json.decode(responseData); // 假设返回的是 JSON 格式
        // final markdownContent = parsedData['content'] as String?; // 提取需要显示的内容

        // 跳转到 MarkdownEdit 页面并传递数据
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MarkdownEdit(markdownText: responseData),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('提交失败: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('提交失败: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _uploadLocalImage() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // final image = await pickAndUploadFile();
      // if (image != null) {
      //   setState(() {
      //     _imageFile = image;
      //   });
      //   await _processImage(image);
      // }
      await pickAndUploadFile();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('选择本地图片失败: $e'),
            action: e.toString().contains('权限') ? SnackBarAction(
              label: '去设置',
              onPressed: () async {
                await openAppSettings();
              },
            ) : null,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // 新增三个保存方法
  Future<void> _saveAsKnowledge() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('请先拍照或选择图片')),
      );
      return;
    }

    try {
      final bytes = await _imageFile!.readAsBytes();
      final response = await http.post(
        Uri.parse('${ApiConfig.minerUrl}/api/save/knowledge'),
        body: bytes,
        headers: {'Content-Type': 'application/octet-stream'},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存为知识点成功')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('保存失败: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('拍照识别'),
      ),
      body: Column(
        children: [
          // 按钮组
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _takePicture,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('拍照'),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _pickImage,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('相册'),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _uploadLocalImage,
                  icon: const Icon(Icons.folder_open),
                  label: const Text('上传本地'),
                ),
              ],
            ),
          ),
          // 图片预览区域
          Expanded(
            child: Center(
              child: _imageFile != null
                  ? Container(
                      height: 600,
                      width: 600,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(_imageFile!.path!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  : const Text('请拍照或选择图片'),
            ),
          ),
        ],
      ),
      // 新增底部按钮栏
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _submitImage,
              icon: const Icon(Icons.save),
              label: const Text('提交'),
            ),
          ],
        ),
      ),
    );
  }
}
