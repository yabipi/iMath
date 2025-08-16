import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:imath/models/question.dart';
import 'package:imath/math/math_cell.dart';

import 'package:imath/state/questions_provider.dart';
import 'package:imath/utils/device_util.dart';

import 'image_viewer.dart';
import 'question_mixin.dart';

class QuestionListview extends ConsumerStatefulWidget {
  // int? categoryId = ALL_CATEGORY;
  // final Function(Question?)? onCurrentQuestionChanged; // 新增：当前题目变化回调

  const QuestionListview({
    super.key,
  });

  @override
  ConsumerState<QuestionListview> createState() => _QuestionListviewState();
}

class _QuestionListviewState extends ConsumerState<QuestionListview> with ImageViewerMixin, QuestionMixin {
  // List<Question> _questions = <Question>[];

  late PageController _pageController; // 新增：用于监听 PageView 滑动事件
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

    List<String> imageUrls = parseImageUrls(question.qImages);
    bool isChoice = isChoiceQuestion(question);

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: // Text('第${content}题')
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          // children: List.generate(
          //   50, // 重复次数
          //       (index) => MathCell(content: question.title ?? ''), // 要重复的组件
          // ),
          children: [
            MathCell(
                content: question.title ?? '',
                textStyle:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            // Text(question.content ?? ''),
            // 题目内容
            MathCell(
              content: question.content ?? '',
            ),
            const SizedBox(height: 8),
            // 图片位置：选择题放在题干和选项之间，非选择题放在题目下方
            if (imageUrls.isNotEmpty && isChoice)
              buildQuestionImages(imageUrls),
              const SizedBox(height: 8),

            // 选项内容（如果有的话）
            if (question.options != null && question.options!.isNotEmpty)
              MathCell(
                content: question.options!,
              ),

            // if (question.options != null && question.options!.isNotEmpty) ...[
            //   MathCell(
            //     content: question.options!,
            //   ),
            //   const SizedBox(height: 8),
            // ],
            // 图片位置：非选择题放在题目下方
            const SizedBox(height: 8),
            if (imageUrls.isNotEmpty && !isChoice)
              buildQuestionImages(imageUrls),
            // Spacer(),
          ],
        ),
      ),
    );
  }



  Widget _buildQuestionsPageView(List<Question> questions) {
    return PageView.builder(
      controller: _pageController,
      physics: DeviceUtil.isMobile
          ? const ClampingScrollPhysics()
          : const PageScrollPhysics(),
      scrollDirection: Axis.horizontal,
      itemCount: questions.length,
      onPageChanged: (int page) {
        try {
          if (page >= 0 && page < questions.length) {
            debugPrint('页面切换到: $page');
            ref.read(currentQuestionProvider.notifier).state = questions[page];

          } else {
            debugPrint('无效的页面索引: $page, 总页数: ${questions.length}');
          }
        } catch (e) {
          debugPrint('页面变化处理失败: $e');
        }
      },
      itemBuilder: (context, index) {
        return Stack(
          children: [
            // 底层：题目内容
            _buildQuestionCard(questions[index], index),
            // 上层：导航箭头（仅在desktop模式下显示）
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
        );
      },
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

  // 获取当前题目
  Question? getCurrentQuestion() {
    try {
      if (!_pageController.hasClients || _pageController.positions.isEmpty) {
        return null;
      }

      final currentPage = _pageController.page;
      if (currentPage == null) return null;

      final questions = _getCurrentQuestions();
      final pageIndex = currentPage.round();

      if (pageIndex >= 0 && pageIndex < questions.length) {
        return questions[pageIndex];
      }

      return null;
    } catch (e) {
      debugPrint('获取当前题目失败: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    this.context = context;
    final questions = ref.watch(questionsProvider).value ?? [];
    // widget.onCurrentQuestionChanged?.call(questions[0]);
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
            if (!isLoading && questions.isEmpty)
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


  // 判断是否显示左箭头
  bool _shouldShowLeftArrow(List<Question> questions) {
    try {
      // if (!_isControllerReady) return false;
      // if (!_pageController.hasClients) return false;
      // if (questions.isEmpty) return false;
      //
      // // 安全地检查页面状态
      // if (_pageController.positions.isEmpty) return false;

      // final currentPage = _pageController.page;
      // if (currentPage == null) return false;
      //
      // return currentPage > 0 && currentPage < questions.length;
      return true;
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
