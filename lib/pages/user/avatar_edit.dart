import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:imath/config/constants.dart';
import 'package:imath/constant/errors.dart';
import 'package:imath/state/global_state.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:universal_platform/universal_platform.dart';
import 'package:file_picker/file_picker.dart';
import 'package:imath/http/user.dart';
import 'package:imath/core/context.dart';

class AvatarEditScreen extends StatefulWidget {
  final String? currentAvatarPath;
  final String? currentAvatarBase64;
  final Function(bool success, String? avatarData)? onAvatarChanged;

  const AvatarEditScreen({
    Key? key,
    this.currentAvatarPath,
    this.currentAvatarBase64,
    this.onAvatarChanged,
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
                          : widget.currentAvatarBase64 != null
                              ? Image.memory(
                                  base64Decode(widget.currentAvatarBase64!),
                                  fit: BoxFit.cover,
                                  width: 150,
                                  height: 150,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildPlaceholderAvatar();
                                  },
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
                      icon: UniversalPlatform.isMacOS 
                          ? const Icon(Icons.folder_open)
                          : const Icon(Icons.photo_library),
                      label: Text(UniversalPlatform.isMacOS ? '选择文件' : '选择图片'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                  ),
                  // macOS桌面端显示帮助信息和测试按钮
                  if (UniversalPlatform.isMacOS) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline, size: 16, color: Colors.blue[700]),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '支持 JPG、PNG、GIF 格式，文件大小不超过 5MB',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue[700],
                                  ),
                                ),
                              ),
                            ],
                          ),


                        ],
                      ),
                    ),
                  ],
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
    // 在macOS桌面端，直接调用文件选择器
    if (UniversalPlatform.isMacOS) {
      _pickImageFromFileSystem();
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

  // macOS桌面端的文件选择器
  void _showMacOSImagePicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('选择头像图片'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('请选择一张图片作为您的头像'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, size: 20, color: Colors.blue),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '支持格式：JPG、PNG、GIF\n建议尺寸：200x200 像素以上',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _pickImageFromFileSystem();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('选择文件'),
            ),
          ],
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

  // 从文件系统选择图片（macOS桌面端）
  Future<void> _pickImageFromFileSystem() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // 调试信息
      print('macOS文件选择器启动...');
      print('当前平台: ${UniversalPlatform.operatingSystem}');
      print('是否为macOS: ${UniversalPlatform.isMacOS}');

      // 首先尝试使用系统文件选择器
      FilePickerResult? result;
      try {
        result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowMultiple: false,
          allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'bmp'],
          allowCompression: true,
        );
      } catch (pickerError) {
        print('FilePicker错误: $pickerError');
        
        // 如果FilePicker失败，尝试使用image_picker作为备选方案
        print('尝试使用image_picker作为备选方案...');
        final ImagePicker picker = ImagePicker();
        final XFile? image = await picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 85,
        );
        
        if (image != null) {
          setState(() {
            _selectedImage = File(image.path);
          });
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('已选择图片: ${path.basename(image.path)}'),
                duration: Duration(seconds: 2),
                backgroundColor: Colors.green,
              ),
            );
          }
          return;
        }
      }

      print('文件选择结果: ${result != null ? '成功' : '失败'}');
      if (result != null) {
        print('选择的文件数量: ${result.files.length}');
        if (result.files.isNotEmpty) {
          print('第一个文件: ${result.files.first.name}');
          print('文件路径: ${result.files.first.path}');
          print('文件大小: ${result.files.first.size} bytes');
        }
      }

      if (result != null && result.files.isNotEmpty) {
        final PlatformFile file = result.files.first;
        
        // 验证文件大小（限制为5MB）
        if (file.size > 5 * 1024 * 1024) {
          _showErrorDialog('图片文件过大。请选择小于5MB的图片。');
          return;
        }

        // 获取文件路径
        String? filePath = file.path;
        if (filePath == null) {
          _showErrorDialog('无法获取文件路径。');
          return;
        }

        final File imageFile = File(filePath);
        
        // 验证文件是否存在
        if (!await imageFile.exists()) {
          _showErrorDialog('选择的文件不存在。');
          return;
        }

        // 在macOS桌面端，跳过裁剪步骤，直接使用选择的图片
        setState(() {
          _selectedImage = imageFile;
        });

        // 显示成功提示
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('已选择图片: ${file.name}'),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.green,
            ),
          );
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

      // 将图片转换为base64编码（优化大小）
      final String base64Image = await _convertImageToBase64(_selectedImage!);
      
      // 获取当前用户ID
      final currentUser = GlobalState.currentUser;
      if (currentUser?.id == null) {
        throw Exception('用户信息不完整，无法更新头像');
      }

      // 调用后台API更新头像
      final response = await UserHttp.update(currentUser!.id!, {
        'avatar': base64Image,
      });

              // 检查响应结果
        if (response['code'] == SUCCESS) {
          // 更新本地用户信息
          if (currentUser != null) {
            // 更新用户头像信息
            currentUser.avatar = base64Image;
            
            // 更新本地存储的用户信息
            // 这里可以根据实际需求更新本地存储
          }

          // 调用回调函数
          widget.onAvatarChanged?.call(true, base64Image);

          // 显示成功消息
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('头像更新成功'),
                backgroundColor: Colors.green,
              ),
            );
            context.go('/profile');
            // 返回上一页
            // Navigator.pop(context, true); // 传递true表示更新成功
          }
        } else {
          // API返回错误
          final errorMessage = response['message'] ?? '头像更新失败';
          throw Exception(errorMessage);
        }
    } catch (e) {
      // 调用回调函数，传递失败状态
      widget.onAvatarChanged?.call(false, null);
      _showErrorDialog('保存头像失败: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 将图片转换为base64编码，并优化大小
  Future<String> _convertImageToBase64(File imageFile) async {
    try {
      // 读取图片字节
      final List<int> imageBytes = await imageFile.readAsBytes();
      
      // 如果图片大小超过1MB，进行压缩
      if (imageBytes.length > 1024 * 1024) {
        // 这里可以添加图片压缩逻辑
        // 为了简化，我们直接使用原图，但建议在实际项目中添加压缩
        print('Warning: Image size is ${(imageBytes.length / 1024 / 1024).toStringAsFixed(2)}MB, consider compression');
      }
      
      // 转换为base64编码
      final String base64Image = base64Encode(imageBytes);
      
      // 添加data URL前缀（可选，取决于后端API要求）
      // return 'data:image/jpeg;base64,$base64Image';
      return base64Image;
    } catch (e) {
      throw Exception('图片转换失败: $e');
    }
  }

  // 测试文件选择权限
  Future<void> _testFilePickerPermissions() async {
    try {
      print('测试文件选择权限...');
      
      // 尝试选择任何类型的文件
      FilePickerResult? result;
      try {
        result = await FilePicker.platform.pickFiles(
          type: FileType.any,
          allowMultiple: false,
        );
      } catch (pickerError) {
        print('FilePicker权限测试失败: $pickerError');
        
        // 尝试使用image_picker作为备选测试
        print('尝试使用image_picker测试权限...');
        final ImagePicker picker = ImagePicker();
        final XFile? image = await picker.pickImage(
          source: ImageSource.gallery,
        );
        
        if (image != null) {
          print('image_picker权限测试成功！');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('image_picker权限测试成功！选择了: ${path.basename(image.path)}'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          print('用户取消了image_picker选择');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('用户取消了文件选择'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }
      
      if (result != null) {
        print('权限测试成功！选择了文件: ${result.files.first.name}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('权限测试成功！选择了: ${result.files.first.name}'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        print('用户取消了文件选择');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('用户取消了文件选择'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      print('权限测试失败: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('权限测试失败: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
