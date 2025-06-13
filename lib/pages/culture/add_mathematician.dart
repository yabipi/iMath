import 'package:flutter/material.dart';

class AddMathematicianScreen extends StatefulWidget {
  const AddMathematicianScreen({super.key});

  @override
  _AddMathematicianScreenState createState() => _AddMathematicianScreenState();
}

class _AddMathematicianScreenState extends State<AddMathematicianScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _birthDeathController = TextEditingController();
  final TextEditingController _achievementsController = TextEditingController();
  final TextEditingController _biographyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('添加数学家'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: '数学家名称'),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _birthDeathController,
              decoration: const InputDecoration(labelText: '生卒年'),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _achievementsController,
              decoration: const InputDecoration(labelText: '主要成就'),
              maxLines: 3,
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _biographyController,
              decoration: const InputDecoration(labelText: '生平介绍'),
              maxLines: 5,
            ),
            const SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () {
                // 这里可以添加保存逻辑
                print('数学家名称: ${_nameController.text}');
                print('生卒年: ${_birthDeathController.text}');
                print('主要成就: ${_achievementsController.text}');
                print('生平介绍: ${_biographyController.text}');
                Navigator.pop(context);
              },
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthDeathController.dispose();
    _achievementsController.dispose();
    _biographyController.dispose();
    super.dispose();
  }
}