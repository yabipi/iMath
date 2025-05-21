# imath

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## 安装依赖
flutter pub add markdown_widget

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


