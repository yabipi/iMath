import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 字体大小状态管理
/// 提供全局的字体大小设置功能
class FontSizeNotifier extends StateNotifier<double> {
  FontSizeNotifier() : super(1.0); // 默认缩放倍数为1.0

  /// 设置字体大小倍数
  void setFontSize(double scale) {
    state = scale.clamp(0.5, 2.0); // 限制在0.5到2.0倍之间
  }

  /// 重置为默认字体大小
  void resetFontSize() {
    state = 1.0;
  }

  /// 获取当前字体大小倍数
  double get currentFontSize => state;
}

/// 字体大小状态提供者
final fontSizeProvider = StateNotifierProvider<FontSizeNotifier, double>((ref) {
  return FontSizeNotifier();
});

/// 字体大小预设选项
class FontSizePreset {
  final String name;
  final double scale;
  final String description;

  const FontSizePreset({
    required this.name,
    required this.scale,
    required this.description,
  });
}

/// 字体大小预设列表
final fontSizePresets = [
  const FontSizePreset(
    name: '小',
    scale: 0.7,
    description: '适合小屏幕设备',
  ),
  const FontSizePreset(
    name: '中',
    scale: 1.0,
    description: '默认大小',
  ),
  const FontSizePreset(
    name: '大',
    scale: 1.3,
    description: '适合阅读',
  ),
  const FontSizePreset(
    name: '特大',
    scale: 1.6,
    description: '适合视力不佳用户',
  ),
];
