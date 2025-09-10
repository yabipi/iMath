import 'package:flutter/material.dart';
import 'package:imath/math/math_cell.dart';

// 选项项数据类
class OptionItem {
  final String label; // 选项标识符 (A, B, C, D)
  final String content; // 选项内容
  final String? imageUrl; // 图片URL（如果有的话）
  final bool isImage; // 是否为图片选项

  OptionItem({
    required this.label,
    required this.content,
    this.imageUrl,
    required this.isImage,
  });
}

// 图片选项组件
class _ImageOptionWidget extends StatefulWidget {
  final OptionItem option;
  final VoidCallback onTap;

  const _ImageOptionWidget({
    required this.option,
    required this.onTap,
  });

  @override
  State<_ImageOptionWidget> createState() => _ImageOptionWidgetState();
}

class _ImageOptionWidgetState extends State<_ImageOptionWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: IntrinsicWidth(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 图片内容 - 按实际宽度显示
              Image.network(
                widget.option.imageUrl!,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 100,
                    color: Colors.grey[200],
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 100,
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(
                        Icons.broken_image,
                        color: Colors.grey,
                        size: 30,
                      ),
                    ),
                  );
                },
              ),
              // 悬停时显示的放大图标
              if (_isHovered)
                Positioned(
                  top: 4,
                  right: 4,
                  child: AnimatedOpacity(
                    opacity: _isHovered ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(
                        Icons.zoom_in,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// 题目图片组件
class _QuestionImageWidget extends StatefulWidget {
  final String imageUrl;
  final VoidCallback onTap;

  const _QuestionImageWidget({
    required this.imageUrl,
    required this.onTap,
  });

  @override
  State<_QuestionImageWidget> createState() => _QuestionImageWidgetState();
}

class _QuestionImageWidgetState extends State<_QuestionImageWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: IntrinsicWidth(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 图片内容 - 按实际宽度显示，确保完整显示
              Image.network(
                widget.imageUrl,
                fit: BoxFit.contain, // 保持宽高比，确保图片完整显示
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 140, // 保持原有的高度设置
                    color: Colors.grey[200],
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 140, // 保持原有的高度设置
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(
                        Icons.broken_image,
                        color: Colors.grey,
                        size: 40,
                      ),
                    ),
                  );
                },
              ),
              // 悬停时显示的放大图标
              if (_isHovered)
                Positioned(
                  top: 4,
                  right: 4,
                  child: AnimatedOpacity(
                    opacity: _isHovered ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(
                        Icons.zoom_in,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

mixin ImageViewerMixin {
  late BuildContext context;

  // 构建题目图片显示组件
  Widget buildQuestionImages(List<String> imageUrls) {
    if (imageUrls.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        if (imageUrls.length == 1)
          buildImageItem(imageUrls.first)
        else
          // 多张图片时使用垂直列表布局，确保每张图片都能完整显示
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: imageUrls.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              return buildImageItem(imageUrls[index]);
            },
          ),
      ],
    );
  }

  // 构建单个图片项
  Widget buildImageItem(String imageUrl) {
    return _QuestionImageWidget(
      imageUrl: imageUrl,
      onTap: () => showImageDialog(imageUrl),
    );
  }

  // 显示图片放大对话框
  void showImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              // 背景遮罩
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  color: Colors.black.withOpacity(0.8),
                ),
              ),
              // 图片内容
              Center(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: 300,
                          height: 300,
                          color: Colors.white,
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 300,
                          height: 300,
                          color: Colors.white,
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.broken_image,
                                  color: Colors.grey,
                                  size: 60,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  '图片加载失败',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              // 关闭按钮
              Positioned(
                top: 40,
                right: 20,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 解析图片URL字符串，返回URL列表
  List<String> parseImageUrls(String? imagesString) {
    if (imagesString == null || imagesString.trim().isEmpty) {
      return [];
    }

    // 按逗号分割，并去除空白字符
    return imagesString
        .split(',')
        .map((url) => url.trim())
        .where((url) => url.isNotEmpty)
        .toList();
  }

  // 解析选项中的图片，返回选项列表，每个选项包含选项标识符和图片URL（如果有的话）
  List<OptionItem> parseOptionsWithImages(String lineStr) {
    List<OptionItem> options = [];
    // 按换行符分割选项
    List<String> optionLines = lineStr
        .split(RegExp(r'\r\n|\n|\\n|[;,]'))
        .where((line) => line.trim().isNotEmpty)
        .toList();

    for (String line in optionLines) {
      line = line.trim();
      if (line.isEmpty) continue;

      RegExp optionRegex = RegExp(r'^([A-F]|[①②③④⑤⑥⑦⑧]|\([A-Z]\))[\.、\s]\s*(.*)$');
      RegExp urlRegex = RegExp(r'^(https?://).*');
      Match? match = optionRegex.firstMatch(line);

      if (match != null) {
        String optionLabel = match.group(1)!;
        String content = match.group(2)!;

        // 检查内容是否包含markdown图片格式
        RegExp imageRegex = RegExp(r'!\[([^\]]*)\]\(([^)]+)\)');
        Match? imageMatch = imageRegex.firstMatch(content);

        // 检查内容是否包含HTTP/HTTPS URL（可能前面有数字或其他字符）
        Match? urlMatch = urlRegex.firstMatch(content);

        if (imageMatch != null) {
          // 包含markdown图片格式的选项
          String imageUrl = imageMatch.group(2)!;
          options.add(OptionItem(
            label: optionLabel,
            content: content,
            imageUrl: imageUrl,
            isImage: true,
          ));
        } else if (urlMatch != null) {
          // 包含HTTP/HTTPS URL的选项（如：① https://example.com/image.jpg）
          String imageUrl = urlMatch.group(0)!;
          options.add(OptionItem(
            label: optionLabel,
            content: content,
            imageUrl: imageUrl,
            isImage: true,
          ));
        } else {
          // 普通文本选项
          options.add(OptionItem(
            label: optionLabel,
            content: content,
            imageUrl: null,
            isImage: false,
          ));
        }
      }
    }

    return options;
  }

  // 构建选项显示组件
  Widget buildOptionsDisplay(List<OptionItem> options) {
    if (options.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: options.map((option) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 选项标识符
              Text(
                '${option.label}. ',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              // 选项内容
              Expanded(
                child: option.isImage
                    ? _buildImageOption(option)
                    : MathCell(content: option.content),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // 构建图片选项
  Widget _buildImageOption(OptionItem option) {
    return _ImageOptionWidget(
      option: option,
      onTap: () => showImageDialog(option.imageUrl!),
    );
  }
}
