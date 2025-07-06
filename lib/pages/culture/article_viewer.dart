import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:imath/utils/device_util.dart';
import 'package:webview_flutter/webview_flutter.dart';
// import 'package:flutter_linux_webview/flutter_linux_webview.dart';
// Import for Android features.
// import 'package:webview_flutter_android/webview_flutter_android.dart';
// Import for iOS/macOS features.
// import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class ArticleViewer extends StatefulWidget {
  final String title;
  final String content;

  const ArticleViewer({Key? key, required this.title, required this.content})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => ArticleViewerState();
}

class ArticleViewerState extends State<ArticleViewer> {
  String title = '';
  String content = '';
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    // #docregion platform_features
    // late final PlatformWebViewControllerCreationParams params;
    // 注意: webview在linux下不支持，需要使用linux_webview
    if (WebViewPlatform.instance != null) {
      final WebViewController controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {
              // Update loading bar.
            },
            onPageStarted: (String url) {},
            onPageFinished: (String url) {},
            onHttpError: (HttpResponseError error) {},
            onWebResourceError: (WebResourceError error) {},
            onNavigationRequest: (NavigationRequest request) {
              return NavigationDecision.navigate;
            },
          ),
        );
      _controller = controller;
      _controller.loadHtmlString(widget.content);
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true, // 标题居中
      ),
      body: WebViewPlatform.instance == null ?
        SingleChildScrollView(
          child: Text(widget.content),
        )
        :WebViewWidget(
          controller: _controller,
        )

    );
  }
}