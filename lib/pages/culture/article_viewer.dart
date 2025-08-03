import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html_math/flutter_html_math.dart';
import 'package:go_router/go_router.dart';
import 'package:imath/http/article.dart';
import 'package:imath/utils/device_util.dart';
import 'package:imath/utils/string_util.dart';
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
    content = StringUtil.firstNonEmptyString(article['html'],
        [article['content'], article['lake'], article['markdown']]);
  }

  /// 根据平台和设备类型获取合适的字体大小
  double _getFontSize() {
    if (DeviceUtil.isWeb) {
      // Web平台使用较大的字体
      return 16.0;
    } else if (DeviceUtil.isMobile) {
      // 移动端根据屏幕密度调整
      final mediaQuery = MediaQuery.of(context);
      final pixelRatio = mediaQuery.devicePixelRatio;
      if (pixelRatio >= 3.0) {
        return 18.0; // 高密度屏幕
      } else if (pixelRatio >= 2.0) {
        return 16.0; // 中等密度屏幕
      } else {
        return 14.0; // 低密度屏幕
      }
    } else {
      // 桌面端
      return 16.0;
    }
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
                padding: EdgeInsets.all(16.0),
                child: Html(
                  extensions: [
                    MathHtmlExtension(
                        onMathErrorBuilder: (tex, exception, exceptionWithType) {
                          print(exception);
                          //optionally try and correct the Tex string here
                          return Text(exception);
                        }
                    ),
                  ],
                  data: content,
                  style: {
                    'body': Style(
                      fontSize: FontSize(_getFontSize(), Unit.px),
                      lineHeight: LineHeight(1.6),
                    ),
                    'p': Style(
                      fontSize: FontSize(_getFontSize(), Unit.px),
                      margin: Margins.only(bottom: 8),
                    ),
                    'h1': Style(
                      fontSize: FontSize(_getFontSize() * 1.8, Unit.px),
                      fontWeight: FontWeight.bold,
                      margin: Margins.only(top: 16, bottom: 8),
                    ),
                    'h2': Style(
                      fontSize: FontSize(_getFontSize() * 1.5, Unit.px),
                      fontWeight: FontWeight.bold,
                      margin: Margins.only(top: 14, bottom: 6),
                    ),
                    'h3': Style(
                      fontSize: FontSize(_getFontSize() * 1.3, Unit.px),
                      fontWeight: FontWeight.bold,
                      margin: Margins.only(top: 12, bottom: 4),
                    ),
                    'li': Style(
                      fontSize: FontSize(_getFontSize(), Unit.px),
                      margin: Margins.only(bottom: 4),
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