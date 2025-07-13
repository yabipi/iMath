import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:imath/config/constants.dart';
import 'package:imath/providers/settings_provider.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  // 保存数学级别选项
  // late MATH_LEVEL _mathLevel;
  // 保存运行模式选项
  String _runMode = '生产模式';

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
            const Text(
              '数学级别',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              value: _mathLevel.value,
              onChanged: (String? newValue) {
                setState(() {
                  if (newValue != null) {
                    ref.read(mathLevelProvider.notifier).state = MATH_LEVEL.values.firstWhere((level) => level.value == newValue);
                  }
                });
              },
              items: MATH_LEVEL.values.map<DropdownMenuItem<String>>((level) {
                return DropdownMenuItem<String>(
                  value: level.value,
                  child: Text(level.value),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Text(
              '运行模式',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              value: _runMode,
              onChanged: (String? newValue) {
                setState(() {
                  if (newValue != null) {
                    _runMode = newValue;
                  }
                });
              },
              items: <String>['开发者模式', '生产模式']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}