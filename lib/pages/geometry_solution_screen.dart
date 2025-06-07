import 'package:flutter/material.dart';
import '../widgets/coordinate_geometry_animation.dart';

class GeometrySolutionScreen extends StatelessWidget {
  const GeometrySolutionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('坐标几何题解答'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '题目：',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '在平面直角坐标系中，A(4, 0)，B(0, 4)，点C在第一象限，BC//x轴，且BC=6。'
              '过点D作DE//AC交x轴于点E，∠EDC与∠CAG平分线相交于点F，DF与AC交于点H。'
              '点D沿射线CB运动时，射线CB同时以每秒1个单位长度的速度向下平移，记点D的横坐标为m。'
              '当△OAD的面积大于6时，求m的取值范围。',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 24),
            Text(
              '解答过程：',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '1. 首先确定点C的坐标：\n'
              '   由BC//x轴且B(0, 4)，可知C的纵坐标也为4\n'
              '   由BC=6，可知C(6, 4)\n\n'
              '2. 当点D沿CB运动时：\n'
              '   设D点的坐标为(m, y)，其中m > 6\n'
              '   由于CB每秒向下平移1个单位长度\n'
              '   所以y = 4 - (m - 6) = 10 - m\n\n'
              '3. △OAD的面积：\n'
              '   S = (1/2) × |xA × yD - xD × yA|\n'
              '   S = (1/2) × |4 × (10-m) - m × 0|\n'
              '   S = (1/2) × |40-4m|\n\n'
              '4. 当S > 6时：\n'
              '   (1/2) × |40-4m| > 6\n'
              '   |40-4m| > 12\n'
              '   40-4m > 12 或 40-4m < -12\n'
              '   -4m > -28 或 -4m < -52\n'
              '   m < 7 或 m > 13\n\n'
              '5. 由于m > 6（D点在C点右侧），\n'
              '   所以m的取值范围为：m > 13',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 24),
            Text(
              '图形演示：',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: SizedBox(
                height: 400,
                width: 400,
                child: CoordinateGeometryAnimation(),
              ),
            ),
            SizedBox(height: 24),
            Text(
              '答案：',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'm > 13',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
