import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:imath/config/constants.dart';
import 'package:imath/state/settings_provider.dart';

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
  // 保存上传图像选项
  String _uploadImage = '开启';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // _mathLevel = ref.watch(mathLevelProvider);
  }

  @override
  Widget build(BuildContext context) {
    final _mathLevel = ref.watch(mathLevelProvider);
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
                      ref.read(mathLevelProvider.notifier).state = MATH_LEVEL.values[index];
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
                  isSelected: MATH_LEVEL.values.map((level) => level == _mathLevel).toList(),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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
                  isSelected: [false, true].asMap().map((i, _) => MapEntry(i, i == _runModeIndex)).values.toList(),
                ),
              ]
            ),

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
          ],
        ),
      ),
    );
  }
}