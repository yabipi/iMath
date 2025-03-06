import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/camera_service.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final _cameraService = CameraService();
  bool _isLoading = false;
  File? _imageFile;
  String? _recognizedText;
  String? _latexText;

  Future<void> _takePicture() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final image = await _cameraService.takePicture();
      if (image != null) {
        setState(() {
          _imageFile = image;
        });
        await _processImage(image);
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

  Future<void> _pickImage() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final image = await _cameraService.pickImage();
      if (image != null) {
        setState(() {
          _imageFile = image;
        });
        await _processImage(image);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('拍照识别'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 图片预览
            if (_imageFile != null)
              Container(
                height: 300,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    _imageFile!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            // 按钮组
            Row(
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
              ],
            ),
            const SizedBox(height: 24),
            // 识别结果
            if (_recognizedText != null) ...[
              const Text(
                '识别结果：',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_recognizedText!),
              ),
            ],
            const SizedBox(height: 16),
            // LaTeX结果
            if (_latexText != null) ...[
              const Text(
                'LaTeX：',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_latexText!),
              ),
            ],
            // 加载指示器
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
} 