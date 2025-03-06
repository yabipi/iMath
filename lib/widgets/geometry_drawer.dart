import 'package:flutter/material.dart';

class GeometryDrawer extends StatelessWidget {
  final String type;
  final String content;
  final double width;
  final double height;

  const GeometryDrawer({
    super.key,
    required this.type,
    required this.content,
    this.width = 300,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _GeometryPainter(type: type),
      ),
    );
  }
}

class _GeometryPainter extends CustomPainter {
  final String type;

  _GeometryPainter({required this.type});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = Colors.blue.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    switch (type) {
      case '平面几何':
        _drawTriangle(canvas, size, paint, fillPaint);
        break;
      case '立体几何':
        _drawCube(canvas, size, paint);
        break;
    }
  }

  void _drawTriangle(Canvas canvas, Size size, Paint paint, Paint fillPaint) {
    // 计算三角形的顶点
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.width * 0.3;

    final points = [
      Offset(centerX, centerY - radius), // A点
      Offset(centerX - radius, centerY + radius), // B点
      Offset(centerX + radius, centerY + radius), // C点
    ];

    // 绘制三角形
    final path = Path()
      ..moveTo(points[0].dx, points[0].dy)
      ..lineTo(points[1].dx, points[1].dy)
      ..lineTo(points[2].dx, points[2].dy)
      ..close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, paint);

    // 绘制顶点标签
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    final labels = ['A', 'B', 'C'];
    for (var i = 0; i < points.length; i++) {
      textPainter.text = TextSpan(
        text: labels[i],
        style: const TextStyle(
          color: Colors.blue,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          points[i].dx - textPainter.width / 2,
          points[i].dy - textPainter.height / 2,
        ),
      );
    }
  }

  void _drawCube(Canvas canvas, Size size, Paint paint) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final side = size.width * 0.3;

    // 计算立方体的顶点
    final points = [
      // 前面
      Offset(centerX - side, centerY - side), // A
      Offset(centerX + side, centerY - side), // B
      Offset(centerX + side, centerY + side), // C
      Offset(centerX - side, centerY + side), // D
      // 后面
      Offset(centerX - side + side * 0.3, centerY - side + side * 0.3), // E
      Offset(centerX + side + side * 0.3, centerY - side + side * 0.3), // F
      Offset(centerX + side + side * 0.3, centerY + side + side * 0.3), // G
      Offset(centerX - side + side * 0.3, centerY + side + side * 0.3), // H
    ];

    // 绘制前面
    _drawFace(canvas, [points[0], points[1], points[2], points[3]], paint);
    // 绘制后面
    _drawFace(canvas, [points[4], points[5], points[6], points[7]], paint);
    // 绘制连接线
    for (var i = 0; i < 4; i++) {
      canvas.drawLine(points[i], points[i + 4], paint);
    }

    // 绘制顶点标签
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    final labels = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];
    for (var i = 0; i < points.length; i++) {
      textPainter.text = TextSpan(
        text: labels[i],
        style: const TextStyle(
          color: Colors.blue,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          points[i].dx - textPainter.width / 2,
          points[i].dy - textPainter.height / 2,
        ),
      );
    }
  }

  void _drawFace(Canvas canvas, List<Offset> points, Paint paint) {
    final path = Path()
      ..moveTo(points[0].dx, points[0].dy)
      ..lineTo(points[1].dx, points[1].dy)
      ..lineTo(points[2].dx, points[2].dy)
      ..lineTo(points[3].dx, points[3].dy)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 