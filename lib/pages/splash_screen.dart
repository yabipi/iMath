import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:universal_platform/universal_platform.dart';

class SplashScreen extends StatefulWidget {
  /// Root Page of the app.
  const SplashScreen({super.key, required this.isAnon});

  final bool isAnon;

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
        if (widget.isAnon) {
          context.go('/login');
        } else {
          context.go('/home');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/splash.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // 底部加载指示器
            Positioned(
              bottom: 100,
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
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Body extends StatelessWidget {
  const Body({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      // child: UniversalPlatform.isMobile
      //     ? const FlowySvg(FlowySvgs.app_logo_xl, blendMode: null)
      //     : const _DesktopSplashBody(),
    );
  }
}

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
              'assets/images/appflowy_launch_splash.jpg',
            ),
          ),
          const CircularProgressIndicator.adaptive(),
        ],
      ),
    );
  }
}
