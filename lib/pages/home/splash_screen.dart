import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:universal_platform/universal_platform.dart';

class SplashScreen extends StatefulWidget {
  /// Root Page of the app.
  const SplashScreen({super.key, this.isAnon});

  final bool? isAnon;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // 3秒后自动跳转
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        // 根据是否匿名用户跳转到不同页面
        context.go('/home');
        // if (widget.isAnon) {
        //   context.go('/login');
        // } else {
        //   context.go('/home');
        // }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isPortrait = size.height > size.width;
    
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/splash_math.png'),
            fit: BoxFit.cover, // 使用 cover 确保图片填满整个屏幕
            alignment: Alignment.center, // 图片居中对齐
          ),
        ),
        child: Container(
          // 添加轻微遮罩以提高文字可读性
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.1),
          ),
          child: Stack(
            children: [
              // 底部加载指示器 - 使用响应式定位
              Positioned(
                bottom: _getBottomPadding(size, isPortrait),
                left: 0,
                right: 0,
                child: Center(
                  child: Column(
                    children: [
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 3,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '正在加载...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: _getFontSize(size, isPortrait),
                          fontWeight: FontWeight.w500,
                          shadows: [
                            Shadow(
                              offset: const Offset(1, 1),
                              blurRadius: 3,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 根据屏幕尺寸和方向计算底部间距
  double _getBottomPadding(Size size, bool isPortrait) {
    if (isPortrait) {
      // 竖屏模式
      if (size.height > 800) {
        return 120; // 大屏幕
      } else if (size.height > 600) {
        return 100; // 中等屏幕
      } else {
        return 80; // 小屏幕
      }
    } else {
      // 横屏模式
      return size.height * 0.15; // 使用屏幕高度的15%
    }
  }

  // 根据屏幕尺寸和方向计算字体大小
  double _getFontSize(Size size, bool isPortrait) {
    if (isPortrait) {
      if (size.height > 800) {
        return 18; // 大屏幕
      } else if (size.height > 600) {
        return 16; // 中等屏幕
      } else {
        return 14; // 小屏幕
      }
    } else {
      // 横屏模式，根据屏幕高度调整
      return (size.height * 0.02).clamp(12.0, 20.0);
    }
  }
}

// 如果你需要支持桌面端的启动画面，可以使用这个：
class _DesktopSplashBody extends StatelessWidget {
  const _DesktopSplashBody();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image(
            fit: BoxFit.cover,
            width: size.width,
            height: size.height,
            image: const AssetImage(
              'assets/images/splash_math.png',
            ),
          ),
          const CircularProgressIndicator.adaptive(),
        ],
      ),
    );
  }
}
