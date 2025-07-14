import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:universal_platform/universal_platform.dart';

class AvatarEditScreen extends StatefulWidget {
  final String? currentAvatarPath;
  // final Function(String) onAvatarChanged;

  const AvatarEditScreen({
    Key? key,
    this.currentAvatarPath,
    // required this.onAvatarChanged,
  }) : super(key: key);

  @override
  State<AvatarEditScreen> createState() => _AvatarEditScreenState();
}

class _AvatarEditScreenState extends State<AvatarEditScreen> {
  File? _selectedImage;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑头像'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 头像预览区域
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '头像预览',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // 头像显示
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).primaryColor,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: _selectedImage != null
                          ? Image.file(
                              _selectedImage!,
                              fit: BoxFit.cover,
                              width: 150,
                              height: 150,
                            )
                          : widget.currentAvatarPath != null
                              ? Image.file(
                                  File(widget.currentAvatarPath!),
                                  fit: BoxFit.cover,
                                  width: 150,
                                  height: 150,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildPlaceholderAvatar();
                                  },
                                )
                              : _buildPlaceholderAvatar(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 操作按钮区域
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // 选择图片按钮
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _showImageSourceDialog,
                      icon: const Icon(Icons.photo_library),
                      label: const Text('选择图片'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  // 保存按钮
                  if (_selectedImage != null)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _saveAvatar,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Icon(Icons.save),
                        label: Text(_isLoading ? '保存中...' : '保存头像'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderAvatar() {
    return Container(
      width: 150,
      height: 150,
      color: Colors.grey[200],
      child: Icon(
        Icons.person,
        size: 80,
        color: Colors.grey[400],
      ),
    );
  }

  void _showImageSourceDialog() {
    // 在macOS桌面端，直接选择图片，不显示底部弹窗
    if (UniversalPlatform.isMacOS) {
      _pickImage(ImageSource.gallery);
      return;
    }
    
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '选择图片来源',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildSourceOption(
                      icon: Icons.photo_library,
                      title: '相册',
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.gallery);
                      },
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildSourceOption(
                      icon: Icons.camera_alt,
                      title: '拍照',
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.camera);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 40,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final ImagePicker picker = ImagePicker();
      
      // 在macOS桌面端，强制使用gallery源
      ImageSource actualSource = source;
      if (UniversalPlatform.isMacOS) {
        actualSource = ImageSource.gallery;
      }
      
      final XFile? image = await picker.pickImage(
        source: actualSource,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        // 进行图片裁剪
        final File? croppedImage = await _cropImage(File(image.path));
        if (croppedImage != null) {
          setState(() {
            _selectedImage = croppedImage;
          });
        }
      }
    } catch (e) {
      _showErrorDialog('选择图片失败: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<File?> _cropImage(File imageFile) async {
    try {
      // 在macOS桌面端，暂时跳过裁剪步骤
      if (UniversalPlatform.isMacOS) {
        return imageFile;
      }
      
      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: '裁剪头像',
            toolbarColor: Theme.of(context).primaryColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
            hideBottomControls: false,
            showCropGrid: true,
            cropGridColor: Colors.white,
            cropFrameColor: Theme.of(context).primaryColor,
            cropFrameStrokeWidth: 2,
            cropGridColumnCount: 3,
            cropGridRowCount: 3,
          ),
          IOSUiSettings(
            title: '裁剪头像',
            aspectRatioLockEnabled: true,
            aspectRatioPickerButtonHidden: true,
            resetAspectRatioEnabled: false,
            rotateButtonsHidden: true,
            rotateClockwiseButtonHidden: true,
            doneButtonTitle: '完成',
            cancelButtonTitle: '取消',
          ),
        ],
      );

      if (croppedFile != null) {
        return File(croppedFile.path);
      }
    } catch (e) {
      _showErrorDialog('裁剪图片失败: $e');
    }
    return null;
  }

  Future<void> _saveAvatar() async {
    if (_selectedImage == null) return;

    try {
      setState(() {
        _isLoading = true;
      });

      // 获取应用文档目录
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String avatarDir = path.join(appDir.path, 'avatars');
      
      // 创建头像目录
      await Directory(avatarDir).create(recursive: true);
      
      // 生成唯一的文件名
      final String fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String avatarPath = path.join(avatarDir, fileName);
      
      // 复制文件到应用目录
      await _selectedImage!.copy(avatarPath);
      
      // 调用回调函数
      // widget.onAvatarChanged(avatarPath);
      
      // 显示成功消息
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('头像保存成功'),
            backgroundColor: Colors.green,
          ),
        );
        
        // 返回上一页
        Navigator.pop(context);
      }
    } catch (e) {
      _showErrorDialog('保存头像失败: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('错误'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }
}
