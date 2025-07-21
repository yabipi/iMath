import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:go_router/go_router.dart';
import 'package:imath/http/article.dart';
import 'package:imath/utils/device_util.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'package:flutter_linux_webview/flutter_linux_webview.dart';
// Import for Android features.
// import 'package:webview_flutter_android/webview_flutter_android.dart';
// Import for iOS/macOS features.
// import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class ArticleViewer extends StatefulWidget {
  final int articleId;
  final String title;

  const ArticleViewer({Key? key, required this.articleId, required this.title})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => ArticleViewerState();
}

class ArticleViewerState extends State<ArticleViewer> {
  String title = '';
  late Future _future;
  late String content;
  // late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _future = _fetchArticle();
    // #docregion platform_features
    // late final PlatformWebViewControllerCreationParams params;
    // 注意: webview在linux下不支持，需要使用linux_webview
  }

  Future<void> _fetchArticle() async {
    // 假设延迟2秒模拟网络请求
    // await Future.delayed(Duration(seconds: 2));
    final article = await ArticleHttp.loadArticle(widget.articleId);
    content = article['content'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true, // 标题居中
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            context.pop();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              context.push("/admin/editArticle/${widget.articleId}");
            },
          ),
        ],
      ),
      body: FutureBuilder(
          future: _future,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else {
              return SingleChildScrollView(
                // child: Text(widget.content),
                child: Html(
                  data: content,
                  style: {
                    'flutter': Style(
                      display: Display.block,
                      fontSize: FontSize(5, Unit.em),
                    ),
                  },
                  // padding: EdgeInsets.all(8.0),
                  // onLinkTap: (url) {
                  //
                  // },
                  // customRender: (node, children) {

                ),
              );
            }

          },
      )
    );
  }

  // void initWebView()  {
  //   if (DeviceUtil.isLinux) {
  //     print("object");
  //   }
  //   if (DeviceUtil.isMobile || DeviceUtil.isWeb) {
  //     final WebViewController controller = WebViewController()
  //       ..setJavaScriptMode(JavaScriptMode.unrestricted)
  //       ..setNavigationDelegate(
  //         NavigationDelegate(
  //           onProgress: (int progress) {
  //             // Update loading bar.
  //           },
  //           onPageStarted: (String url) {},
  //           onPageFinished: (String url) {},
  //           onHttpError: (HttpResponseError error) {},
  //           onWebResourceError: (WebResourceError error) {},
  //           onNavigationRequest: (NavigationRequest request) {
  //             return NavigationDecision.navigate;
  //           },
  //         ),
  //       );
  //     _controller = controller;
  //     _controller.loadHtmlString(content);
  //   }
  // }
}