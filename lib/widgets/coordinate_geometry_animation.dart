import 'package:flutter/material.dart';

class CoordinateGeometryAnimation extends StatefulWidget {
  const CoordinateGeometryAnimation({super.key});

  @override
  State<CoordinateGeometryAnimation> createState() => _CoordinateGeometryAnimationState();
}

class _CoordinateGeometryAnimationState extends State<CoordinateGeometryAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
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
          size: const Size(400, 400),
          painter: CoordinateSystemPainter(
            progress: _animation.value,
          ),
        );
      },
    );
  }
}

class CoordinateSystemPainter extends CustomPainter {
  final double progress;
  static const double scale = 40.0; // 每个单位长度对应的像素数

  CoordinateSystemPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    // 绘制坐标系
    _drawCoordinateSystem(canvas, size, paint, textPainter);

    // 绘制点和线段
    if (progress > 0.2) {
      _drawPoints(canvas, size, paint, textPainter);
    }

    // 绘制运动轨迹
    if (progress > 0.4) {
      _drawMotionPath(canvas, size, paint, textPainter);
    }
  }

  void _drawCoordinateSystem(Canvas canvas, Size size, Paint paint, TextPainter textPainter) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // 绘制x轴
    canvas.drawLine(
      Offset(0, centerY),
      Offset(size.width, centerY),
      paint,
    );

    // 绘制y轴
    canvas.drawLine(
      Offset(centerX, 0),
      Offset(centerX, size.height),
      paint,
    );

    // 绘制刻度
    for (int i = -8; i <= 8; i++) {
      // x轴刻度
      canvas.drawLine(
        Offset(centerX + i * scale, centerY - 5),
        Offset(centerX + i * scale, centerY + 5),
        paint,
      );

      // y轴刻度
      canvas.drawLine(
        Offset(centerX - 5, centerY - i * scale),
        Offset(centerX + 5, centerY - i * scale),
        paint,
      );

      // 绘制刻度值
      if (i != 0) {
        textPainter.text = TextSpan(
          text: i.toString(),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 12,
          ),
        );
        textPainter.layout();
        
        // x轴刻度值
        textPainter.paint(
          canvas,
          Offset(
            centerX + i * scale - textPainter.width / 2,
            centerY + 10,
          ),
        );

        // y轴刻度值
        textPainter.paint(
          canvas,
          Offset(
            centerX - 20,
            centerY - i * scale - textPainter.height / 2,
          ),
        );
      }
    }
  }

  void _drawPoints(Canvas canvas, Size size, Paint paint, TextPainter textPainter) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // 绘制点A(4, 0)
    final pointA = Offset(centerX + 4 * scale, centerY);
    canvas.drawCircle(pointA, 4, paint..style = PaintingStyle.fill);
    textPainter.text = const TextSpan(
      text: 'A(4, 0)',
      style: TextStyle(
        color: Colors.black,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(pointA.dx + 10, pointA.dy));

    // 绘制点B(0, 4)
    final pointB = Offset(centerX, centerY - 4 * scale);
    canvas.drawCircle(pointB, 4, paint);
    textPainter.text = const TextSpan(
      text: 'B(0, 4)',
      style: TextStyle(
        color: Colors.black,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(pointB.dx - 40, pointB.dy));

    // 绘制点C(6, 4)
    final pointC = Offset(centerX + 6 * scale, centerY - 4 * scale);
    canvas.drawCircle(pointC, 4, paint);
    textPainter.text = const TextSpan(
      text: 'C(6, 4)',
      style: TextStyle(
        color: Colors.black,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(pointC.dx + 10, pointC.dy));

    // 绘制线段BC
    paint.color = Colors.blue;
    canvas.drawLine(pointB, pointC, paint);

    // 绘制线段AC
    paint.color = Colors.red;
    canvas.drawLine(pointA, pointC, paint);
  }

  void _drawMotionPath(Canvas canvas, Size size, Paint paint, TextPainter textPainter) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // 绘制点D的运动轨迹
    paint.color = Colors.green;
    paint.style = PaintingStyle.stroke;
    
    final path = Path();
    for (double t = 0; t <= progress; t += 0.01) {
      final x = 6 + t * scale;
      final y = 4 - t * scale;
      if (t == 0) {
        path.moveTo(centerX + x, centerY - y);
      } else {
        path.lineTo(centerX + x, centerY - y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CoordinateSystemPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
} 