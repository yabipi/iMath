import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:imath/models/question.dart';
import 'package:imath/components/math_cell.dart';

import 'package:imath/state/questions_provider.dart';
import 'package:imath/utils/device_util.dart';

class QuestionListview extends ConsumerStatefulWidget {
  // int? categoryId = ALL_CATEGORY;
  const QuestionListview({super.key});

  @override
  ConsumerState<QuestionListview> createState() => _QuestionListviewState();
}

class _QuestionListviewState extends ConsumerState<QuestionListview> {
  // List<Question> _questions = <Question>[];

  late PageController _pageController; // 新增：用于监听 PageView 滑动事件
  bool _isPanelExpanded = true; // 新增：控制功能条展开/折叠状态
  bool _isControllerReady = false; // 新增：标记controller是否准备就绪

  @override
  void initState() {
    super.initState();

    try {
      _pageController = PageController();

      // 监听 PageView 滑动事件
      _pageController.addListener(() async {
        try {
          // 只有当滑动到最后一个页面时才加载更多
          if (_pageController.page != null &&
              _pageController.position.pixels ==
                  _pageController.position.maxScrollExtent) {
            // 滑动到最底部，加载更多题目
            int newPageNo = ref.read(pageNoProvider) + 1;
            ref.read(questionsProvider.notifier).onChangePageNo(newPageNo);
          }
        } catch (e) {
          debugPrint('PageView滑动监听器错误: $e');
        }
      });

      // 标记controller准备就绪
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _isControllerReady = true;
          });
        }
      });
    } catch (e) {
      debugPrint('PageController初始化失败: $e');
      // 如果初始化失败，创建一个默认的controller
      _pageController = PageController();
    }
  }

  @override
  void dispose() {
    try {
      _pageController.dispose();
    } catch (e) {
      debugPrint('PageController销毁失败: $e');
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(QuestionListview oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  Widget _buildQuestionCard(Question question, int index) {
    if (question.title == null) {
      return const Card(
        child: ListTile(
          title: Text('无效的题目数据'),
        ),
      );
    }

    List<String> imageUrls = _parseImageUrls(question.images);
    bool isChoiceQuestion = _isChoiceQuestion(question);

    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: Stack(
        children: [
          // 底层：题目内容（可滚动）
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  // 题目内容
                  MathCell(
                    content: question.content ?? '',
                  ),
                  const SizedBox(height: 8),
                  // 图片位置：选择题放在题干和选项之间，非选择题放在题目下方
                  if (imageUrls.isNotEmpty && isChoiceQuestion) ...[
                    _buildQuestionImages(imageUrls),
                    const SizedBox(height: 8),
                  ],
                  // 选项内容（如果有的话）
                  if (question.options != null &&
                      question.options!.isNotEmpty) ...[
                    MathCell(
                      content: question.options!,
                    ),
                    const SizedBox(height: 8),
                  ],
                  // 图片位置：非选择题放在题目下方
                  if (imageUrls.isNotEmpty && !isChoiceQuestion) ...[
                    _buildQuestionImages(imageUrls),
                    const SizedBox(height: 8),
                  ],
                ],
              ),
            ),
          ),
          // 上层：右侧功能条
          Positioned(
            right: 20,
            top: 0,
            bottom: 0,
            child: LayoutBuilder(
              builder: (context, constraints) {
                // 计算右箭头中心位置：屏幕高度的一半
                final arrowCenterY = constraints.maxHeight / 2;
                // 右箭头高度的一半：24像素
                final arrowHalfHeight = 24;
                // 4像素间距
                final spacing = 4;
                // 功能条顶部位置：右箭头底部 + 间距
                // 右箭头底部 = 中心Y + 高度的一半
                final arrowBottomY = arrowCenterY + arrowHalfHeight;
                final panelTopY = arrowBottomY + spacing;

                return Transform.translate(
                  offset: Offset(0, panelTopY),
                  child: _buildCollapsiblePanel(question),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 判断是否为选择题
  bool _isChoiceQuestion(Question question) {
    // 根据题目类型或选项内容判断是否为选择题
    if (question.type != null) {
      final type = question.type!.toLowerCase();
      return type.contains('选择') ||
          type.contains('choice') ||
          type.contains('select');
    }

    // 如果类型字段为空，根据选项内容判断
    if (question.options != null && question.options!.isNotEmpty) {
      final options = question.options!;
      // 检查是否包含选项标识符（A、B、C、D等）
      return RegExp(r'[A-D][\s\.、]').hasMatch(options);
    }

    return false;
  }

  // 构建可折叠的功能条
  Widget _buildCollapsiblePanel(Question question) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 折叠/展开按钮（带横线）
          GestureDetector(
            onTap: () {
              setState(() {
                _isPanelExpanded = !_isPanelExpanded;
              });
            },
            child: Container(
              width: 48,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[300]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 横线
                  Container(
                    width: 16,
                    height: 2,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(height: 2),
                  // 箭头图标
                  Icon(
                    _isPanelExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          // 功能条内容
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _isPanelExpanded
                ? _buildPanel(question)
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  // 新增：右侧操作面板
  Widget _buildPanel(Question question) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 点赞
          _buildActionItem(
            icon: Icons.thumb_up_outlined,
            count: 0, // TODO: 从数据库获取点赞数
            onTap: () {
              // TODO: 实现点赞功能
            },
          ),
          const SizedBox(height: 8),
          // 收藏
          _buildActionItem(
            icon: Icons.bookmark_outline,
            count: 0, // TODO: 从数据库获取收藏数
            onTap: () {
              // TODO: 实现收藏功能
            },
          ),
          const SizedBox(height: 8),
          // 评论
          _buildActionItem(
            icon: Icons.comment_outlined,
            count: 0, // TODO: 从数据库获取评论数
            onTap: () {
              // TODO: 实现评论功能
            },
          ),
          const SizedBox(height: 8),
          // 答案
          _buildActionItem(
            icon: Icons.lightbulb_outline,
            count: 0, // 答案不显示数量
            onTap: () {
              context.push('/admin/viewAnswer', extra: question);
            },
            isAnswer: true,
          ),
        ],
      ),
    );
  }

  // 构建操作项
  Widget _buildActionItem({
    required IconData icon,
    required int count,
    required VoidCallback onTap,
    bool isAnswer = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 24,
            color: isAnswer ? Colors.orange : Colors.grey[600],
          ),
          if (!isAnswer) ...[
            const SizedBox(height: 4),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuestionsPageView(List<Question> questions) {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController, // 使用自定义的 PageController
                physics: DeviceUtil.isMobile
                    ? const ClampingScrollPhysics()
                    : const PageScrollPhysics(), // desktop模式下使用PageScrollPhysics支持鼠标拖拽
                scrollDirection: Axis.horizontal,
                itemCount: questions.length,
                onPageChanged: (int page) {
                  try {
                    // 验证页面索引的有效性
                    if (page >= 0 && page < questions.length) {
                      // 可以在这里添加页面变化的日志
                      debugPrint('页面切换到: $page');
                    } else {
                      debugPrint('无效的页面索引: $page, 总页数: ${questions.length}');
                    }
                  } catch (e) {
                    debugPrint('页面变化处理失败: $e');
                  }
                  // 当滑动到倒数第二个页面时，开始加载更多数据
                },
                itemBuilder: (context, index) {
                  return _buildQuestionCard(questions[index], index);
                },
              ),
              // 左右导航箭头 - 仅在desktop模式下显示
              if (!DeviceUtil.isMobile) ...[
                // 左箭头
                if (_shouldShowLeftArrow(questions))
                  Positioned(
                    left: 20,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: _buildNavigationArrow(
                        icon: Icons.chevron_left,
                        onTap: () => _previousPage(),
                        isLeft: true,
                      ),
                    ),
                  ),
                // 右箭头
                if (_shouldShowRightArrow(questions))
                  Positioned(
                    right: 20,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: _buildNavigationArrow(
                        icon: Icons.chevron_right,
                        onTap: () => _nextPage(),
                        isLeft: false,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // 构建导航箭头按钮
  Widget _buildNavigationArrow({
    required IconData icon,
    required VoidCallback onTap,
    required bool isLeft,
  }) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Icon(
            icon,
            color: Colors.grey[700],
            size: 28,
          ),
        ),
      ),
    );
  }

  // 上一页
  void _previousPage() {
    try {
      if (!_pageController.hasClients) return;
      if (_pageController.positions.isEmpty) return;

      final currentPage = _pageController.page;
      if (currentPage == null || currentPage <= 0) return;

      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } catch (e) {
      debugPrint('上一页操作失败: $e');
      // 如果动画失败，尝试直接跳转
      try {
        if (!_pageController.hasClients) return;
        if (_pageController.positions.isEmpty) return;

        final currentPage = _pageController.page;
        if (currentPage == null || currentPage <= 0) return;

        _pageController.jumpToPage(currentPage.round() - 1);
      } catch (e2) {
        debugPrint('跳转页面也失败: $e2');
      }
    }
  }

  // 下一页
  void _nextPage() {
    try {
      if (!_pageController.hasClients) return;
      if (_pageController.positions.isEmpty) return;

      final currentPage = _pageController.page;
      if (currentPage == null) return;

      final questions = _getCurrentQuestions();
      if (currentPage >= (questions.length - 1)) return;

      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } catch (e) {
      debugPrint('下一页操作失败: $e');
      // 如果动画失败，尝试直接跳转
      try {
        if (!_pageController.hasClients) return;
        if (_pageController.positions.isEmpty) return;

        final currentPage = _pageController.page;
        if (currentPage == null) return;

        final questions = _getCurrentQuestions();
        if (currentPage >= (questions.length - 1)) return;

        _pageController.jumpToPage(currentPage.round() + 1);
      } catch (e2) {
        debugPrint('跳转页面也失败: $e2');
      }
    }
  }

  // 获取当前题目列表
  List<Question> _getCurrentQuestions() {
    return ref.read(questionsProvider).value ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final questions = ref.watch(questionsProvider).value ?? [];
    // 监听分类变化和加载状态
    ref.watch(categoryChangeProvider);
    ref.watch(pageChangeProvider);
    ref.watch(autoQuestionsFutureProvider); // 自动触发初始加载
    final isLoading = ref.watch(isLoadingProvider);
    // final questions = ref.watch(questionsProvider);
    // 更新本地状态
    // _isLoading = isLoading;
    // _hasMore = hasMore;

    return KeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKeyEvent: (KeyEvent event) {
        if (event is KeyDownEvent) {
          switch (event.logicalKey) {
            case LogicalKeyboardKey.arrowLeft:
              _previousPage();
              break;
            case LogicalKeyboardKey.arrowRight:
              _nextPage();
              break;
          }
        }
      },
      child: RefreshIndicator(
        // onRefresh: ref.refresh(questionsProvider.future),
        onRefresh: _onRefresh,
        child: Stack(
          children: [
            _buildQuestionsPageView(questions),
            // 显示加载指示器
            if (isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
            // 显示无数据提示
            if (questions.isEmpty)
              const Center(
                child: Text('暂无数据'),
              ),
          ],
        ),
      ),
    );
  }

  /**
   * 下拉刷新方法,为list重新赋值
   */
  Future<Null> _onRefresh() async {
    // 重置页码为1
    ref.read(pageNoProvider.notifier).state = 1;
    // 重置是否有更多数据
    ref.read(hasMoreProvider.notifier).state = true;
    // 触发重新加载

    // 等待加载完成
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // 解析图片URL字符串，返回URL列表
  List<String> _parseImageUrls(String? imagesString) {
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

  // 构建题目图片显示组件
  Widget _buildQuestionImages(List<String> imageUrls) {
    if (imageUrls.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        if (imageUrls.length == 1)
          SizedBox(
            height: 140,
            child: _buildImageItem(imageUrls.first),
          )
        else
          // 多张图片时使用垂直列表布局，确保每张图片都能完整显示
          Expanded(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: imageUrls.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                return SizedBox(
                  height: 120, // 固定高度确保图片不会被裁剪
                  child: _buildImageItem(imageUrls[index]),
                );
              },
            ),
          ),
      ],
    );
  }

  // 构建单个图片项
  Widget _buildImageItem(String imageUrl) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: GestureDetector(
          onTap: () => _showImageDialog(imageUrl),
          child: Stack(
            children: [
              // 使用 Center 包装确保图片居中显示
              Center(
                child: Image.network(
                  imageUrl,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.contain, // 保持宽高比，确保图片完整显示
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      width: double.infinity,
                      height: double.infinity,
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
                      width: double.infinity,
                      height: double.infinity,
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
              ),
              // 添加点击提示
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.zoom_in,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 显示图片放大对话框
  void _showImageDialog(String imageUrl) {
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

  // 判断是否显示左箭头
  bool _shouldShowLeftArrow(List<Question> questions) {
    try {
      // if (!_isControllerReady) return false;
      // if (!_pageController.hasClients) return false;
      // if (questions.isEmpty) return false;
      //
      // // 安全地检查页面状态
      // if (_pageController.positions.isEmpty) return false;

      final currentPage = _pageController.page;
      if (currentPage == null) return false;

      return currentPage > 0 && currentPage < questions.length;
    } catch (e) {
      debugPrint('检查左箭头显示状态失败: $e');
      return false;
    }
  }

  // 判断是否显示右箭头
  bool _shouldShowRightArrow(List<Question> questions) {
    try {
      if (!_isControllerReady) return false;
      if (!_pageController.hasClients) return false;
      if (questions.isEmpty) return false;

      // 安全地检查页面状态
      if (_pageController.positions.isEmpty) return false;

      final currentPage = _pageController.page;
      if (currentPage == null) return false;

      return currentPage >= 0 && currentPage < (questions.length - 1);
    } catch (e) {
      debugPrint('检查右箭头显示状态失败: $e');
      return false;
    }
  }
}
