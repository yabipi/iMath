import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraService {
  final _imagePicker = ImagePicker();
  final _textRecognizer = TextRecognizer();
  final String _apiEndpoint = 'YOUR_API_ENDPOINT'; // 替换为实际的API端点

  // 检查相机权限
  Future<bool> checkCameraPermission() async {
    final status = await Permission.camera.status;
    if (status.isDenied) {
      final result = await Permission.camera.request();
      return result.isGranted;
    }
    return status.isGranted;
  }

  // 检查存储权限
  Future<bool> checkStoragePermission() async {
    final status = await Permission.storage.status;
    if (status.isDenied) {
      final result = await Permission.storage.request();
      return result.isGranted;
    }
    return status.isGranted;
  }

  // 拍照
  Future<File?> takePicture() async {
    try {
      // 检查相机权限
      if (!await checkCameraPermission()) {
        throw Exception('需要相机权限才能拍照');
      }

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      return image != null ? File(image.path) : null;
    } catch (e) {
      print('拍照失败: $e');
      return null;
    }
  }

  // 从相册选择图片
  Future<File?> pickImage() async {
    try {
      // 检查存储权限
      if (!await checkStoragePermission()) {
        throw Exception('需要存储权限才能访问相册');
      }

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      return image != null ? File(image.path) : null;
    } catch (e) {
      print('选择图片失败: $e');
      return null;
    }
  }

  // 识别图片中的文字
  Future<String?> recognizeText(File imageFile) async {
    try {
      final inputImage = InputImage.fromFilePath(imageFile.path);
      final recognizedText = await _textRecognizer.processImage(inputImage);
      return recognizedText.text;
    } catch (e) {
      print('文字识别失败: $e');
      return null;
    }
  }

  // 将文字转换为LaTeX
  Future<String?> convertToLatex(String text) async {
    try {
      // 模拟API调用，实际项目中替换为真实的API
      await Future.delayed(const Duration(seconds: 1));
      return text; // 临时返回原文，实际项目中需要调用真实的API
    } catch (e) {
      print('LaTeX转换失败: $e');
      return null;
    }
  }

  // 提交LaTeX到后端
  Future<bool> submitLatex(String latex) async {
    try {
      // 模拟API调用，实际项目中替换为真实的API
      await Future.delayed(const Duration(seconds: 1));
      return true; // 临时返回成功，实际项目中需要调用真实的API
    } catch (e) {
      print('提交失败: $e');
      return false;
    }
  }

  // 完整的处理流程
  Future<Map<String, dynamic>> processImage(File imageFile) async {
    try {
      // 1. 识别文字
      final text = await recognizeText(imageFile);
      if (text == null) {
        return {'success': false, 'message': '文字识别失败'};
      }

      // 2. 转换为LaTeX
      final latex = await convertToLatex(text);
      if (latex == null) {
        return {'success': false, 'message': 'LaTeX转换失败'};
      }

      // 3. 提交到后端
      final success = await submitLatex(latex);
      if (!success) {
        return {'success': false, 'message': '提交失败'};
      }

      return {
        'success': true,
        'text': text,
        'latex': latex,
      };
    } catch (e) {
      return {'success': false, 'message': '处理失败: $e'};
    }
  }


} 