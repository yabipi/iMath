# imath

数学宝典app

setState(() {
if(widget.categoryId != _categoryId) {
_loadMoreQuestions(categoryId: widget.categoryId);
}
});

# Run
Android studio里设置additional run args: --dart-define-from-file=.env/dev.json

## 图标和启动图
flutter pub run flutter_launcher_icons
flutter pub run flutter_native_splash:create

# 构建
flutter run --flavor staging --dart-define=HOST="test"
flutter run --flavor staging --dart-define-from-file=.staging.json
flutter build ios --release --flavor staging --dart-define-from-file=.staging.json
flutter build apk --release --flavor staging --dart-define-from-file=.staging.json

## 运行
- flutter run -d web-server
- flutter run -d web-server --web-port 8080
- flutter run -d web-server --web-port 8080 --dart-define=ENV=local
- flutter run -d chrome
- flutter run -d chrome --release

## Flutter指引

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## 安装依赖
flutter pub add markdown_widget
flutter_screenutil: ^5.9.3
cached_network_image
cupertino_icons

## 构建
- flutter build apk
- flutter build ios
- flutter build macos
- flutter build windows
- flutter build web
- flutter pub get        # 获取依赖
## 运行
- flutter run
- flutter run --dart-define=ENV=DEV
- flutter build apk --dart-define=ENV=production
// debug 模式（使用 chrome 浏览器）
flutter run -d chrome --web-renderer html
// debug 模式（使用 edge 浏览器）
flutter run -d edge --web-renderer html
// debug 模式（不指定浏览器）
flutter run -d web-server --web-renderer html

// release 包
flutter build web --web-renderer html
### web方式运行
flutter build web
pm2 start -n iMath python -- -m http.server 8000

## 启动画面
dart run flutter_native_splash:create

## 依赖组件
### Math相关组件
- https://github.com/shahxad-akram/flutter_tex: A Flutter Package to render Mathematics, Physics and Chemistry Equations based on LaTeX
- https://github.com/simpleclub/flutter_math: Fork of flutter_math addressing compatibility problems while flutter_math is not being maintained.
- https://github.com/xushengs/flutter_markdown_latex
- https://gitlab.com/testapp-system/katex_flutter
- https://github.com/djade007/latext

### HTML相关
- webview_flutter和flutter_inappwebview
- flutter_html

### 图片图像
- https://github.com/hnvn/flutter_image_cropper/tree/master?tab=readme-ov-file
- https://github.com/Yalantis/uCrop
- 
## 认证
- https://pub.dev/packages/dart_jsonwebtoken
