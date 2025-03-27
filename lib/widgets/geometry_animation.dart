import 'package:flutter/material.dart';
import 'dart:math' as math;

class GeometryAnimation extends StatefulWidget {
  const GeometryAnimation({super.key});

  @override
  State<GeometryAnimation> createState() => _GeometryAnimationState();
}

class _GeometryAnimationState extends State<GeometryAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(300, 300),
          painter: TrianglePainter(
            progress: _animation.value,
          ),
        );
      },
    );
  }
}

class TrianglePainter extends CustomPainter {
  final double progress;

  TrianglePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
    );

    // 计算三角形的顶点
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.width * 0.3;

    // 点A (60°)
    final pointA = Offset(
      centerX + radius * math.cos(math.pi / 3),
      centerY - radius * math.sin(math.pi / 3),
    );

    // 点B (0°)
    final pointB = Offset(
      centerX + radius,
      centerY,
    );

    // 点C (120°)
    final pointC = Offset(
      centerX + radius * math.cos(2 * math.pi / 3),
      centerY - radius * math.sin(2 * math.pi / 3),
    );

    // 绘制三角形
    final path = Path()
      ..moveTo(pointA.dx, pointA.dy)
      ..lineTo(pointB.dx, pointB.dy)
      ..lineTo(pointC.dx, pointC.dy)
      ..close();

    // 绘制边
    canvas.drawPath(path, paint);

    // 绘制顶点标签
    final labels = ['A', 'B', 'C'];
    final points = [pointA, pointB, pointC];
    for (var i = 0; i < labels.length; i++) {
      textPainter.text = TextSpan(
        text: labels[i],
        style: const TextStyle(
          color: Colors.black,
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

    // 绘制角度
    final anglePaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // 绘制60度角
    final angleRadius = radius * 0.2;
    final anglePath = Path()
      ..moveTo(pointA.dx, pointA.dy)
      ..arcToPoint(
        Offset(
          pointA.dx + angleRadius * math.cos(math.pi / 3),
          pointA.dy - angleRadius * math.sin(math.pi / 3),
        ),
        Radius.circular(angleRadius),
        -math.pi / 3,
        math.pi / 3,
        false,
      );
    canvas.drawPath(anglePath, anglePaint);

    // 绘制边长
    final lengthPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // 绘制AB边
    final abMidpoint = Offset(
      (pointA.dx + pointB.dx) / 2,
      (pointA.dy + pointB.dy) / 2,
    );
    textPainter.text = const TextSpan(
      text: '8',
      style: TextStyle(
        color: Colors.green,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        abMidpoint.dx - textPainter.width / 2,
        abMidpoint.dy - textPainter.height / 2,
      ),
    );

    // 绘制AC边
    final acMidpoint = Offset(
      (pointA.dx + pointC.dx) / 2,
      (pointA.dy + pointC.dy) / 2,
    );
    textPainter.text = const TextSpan(
      text: '6',
      style: TextStyle(
        color: Colors.green,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        acMidpoint.dx - textPainter.width / 2,
        acMidpoint.dy - textPainter.height / 2,
      ),
    );

    // 绘制面积计算过程
    if (progress > 0.5) {
      final formulaPaint = Paint()
        ..color = Colors.purple
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      const formulaText = TextSpan(
        text: 'S = (1/2) × 8 × 6 × sin(60°) = 12√3',
        style: TextStyle(
          color: Colors.purple,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      );

      textPainter.text = formulaText;
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          centerX - textPainter.width / 2,
          centerY + radius + 20,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(TrianglePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
} 