import 'package:flutter/material.dart';

import 'package:universal_platform/universal_platform.dart';

class SplashScreen extends StatelessWidget {
  /// Root Page of the app.
  const SplashScreen({super.key, required this.isAnon});

  final bool isAnon;

  @override
  Widget build(BuildContext context) {
    return Text('Splash Screen');
    // if (isAnon) {
    //   return FutureBuilder<void>(
    //     future: _registerIfNeeded(),
    //     builder: (context, snapshot) {
    //       if (snapshot.connectionState != ConnectionState.done) {
    //         return const SizedBox.shrink();
    //       }
    //       return _buildChild(context);
    //     },
    //   );
    // } else {
    //   return _buildChild(context);
    // }
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
