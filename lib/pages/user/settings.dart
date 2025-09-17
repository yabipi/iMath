import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:imath/config/constants.dart';
import 'package:imath/state/settings_provider.dart';
import 'package:imath/state/font_size_provider.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  // 保存数学级别选项
  // late MATH_LEVEL _mathLevel;
  // 修改：将运行模式选项改为类似数学级别的 ToggleButtons 方式
  int _runModeIndex = 1; // 0: 开发者模式, 1: 生产模式

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // _mathLevel = ref.watch(mathLevelProvider);
  }

  @override
  Widget build(BuildContext context) {
    final _mathLevel = ref.watch(mathLevelProvider);
    final fontSizeScale = ref.watch(fontSizeProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '数学级别:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                ToggleButtons(
                  onPressed: (int index) {
                    setState(() {
                      ref.read(mathLevelProvider.notifier).state =
                          MATH_LEVEL.values[index];
                    });
                  },
                  borderRadius: BorderRadius.circular(5),
                  selectedBorderColor: Colors.blue,
                  selectedColor: Colors.white,
                  fillColor: Colors.blue,
                  constraints: BoxConstraints.tight(const Size(100, 30)),
                  children: const <Widget>[
                    Text('初等数学'),
                    Text('高等数学'),
                  ],
                  isSelected: MATH_LEVEL.values
                      .map((level) => level == _mathLevel)
                      .toList(),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text(
                '运行模式:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              ToggleButtons(
                onPressed: (int index) {
                  setState(() {
                    _runModeIndex = index;
                  });
                },
                borderRadius: BorderRadius.circular(5),
                selectedBorderColor: Colors.blue,
                selectedColor: Colors.white,
                fillColor: Colors.blue,
                constraints: BoxConstraints.tight(const Size(100, 30)),
                children: const <Widget>[
                  Text('开发者模式'),
                  Text('生产模式'),
                ],
                isSelected: [false, true]
                    .asMap()
                    .map((i, _) => MapEntry(i, i == _runModeIndex))
                    .values
                    .toList(),
              ),
            ]),

            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '上传图像:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        // 处理点击事件，例如导航到新页面或弹出对话框
                        context.go('/profile/avatarEdit');
                      },
                      child: const Icon(Icons.arrow_forward_ios, size: 16),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            // 字体大小设置
            const Text(
              '显示字体:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: fontSizePresets.map((preset) {
                final isSelected = (fontSizeScale - preset.scale).abs() < 0.1;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: InkWell(
                      onTap: () {
                        ref
                            .read(fontSizeProvider.notifier)
                            .setFontSize(preset.scale);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue : Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? Colors.blue : Colors.grey[300]!,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              preset.name,
                              style: TextStyle(
                                color:
                                    isSelected ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              preset.description,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white70
                                    : Colors.grey[600],
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            // 自定义滑块
            Row(
              children: [
                const Text('自定义:', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 10),
                Expanded(
                  child: Slider(
                    value: fontSizeScale,
                    min: 0.5,
                    max: 2.0,
                    divisions: 15,
                    label: '${(fontSizeScale * 100).round()}%',
                    onChanged: (value) {
                      ref.read(fontSizeProvider.notifier).setFontSize(value);
                    },
                  ),
                ),
                Text(
                  '${(fontSizeScale * 100).round()}%',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
