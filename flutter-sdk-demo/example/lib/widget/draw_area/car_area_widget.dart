import 'dart:ui';

import 'package:flutter/material.dart';

class CarAreaWidget extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final pointPaint = Paint()
      ..color = Colors.blue
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 10;

    final redLinePaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 4;

    final yellowLinePaint = Paint()
      ..color = Colors.yellow
      ..strokeWidth = 4;

    final textPaint = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // 绘制点
    final points = [
      Offset(20, 20),
      Offset(300, 20),
      Offset(300, 160),
      Offset(20, 160),
    ];
    canvas.drawPoints(PointMode.points, points, pointPaint);

    // 绘制红色线
    canvas.drawLine(points[0], points[1], redLinePaint);
    canvas.drawLine(points[1], points[2], redLinePaint);
    canvas.drawLine(points[3], points[0], redLinePaint);

    // 绘制黄色线
    canvas.drawLine(points[2], points[3], yellowLinePaint);

    // 绘制字母A
    textPaint.text = TextSpan(
      style: TextStyle(color: Colors.red, fontSize: 20),
      text: 'A',
    );
    textPaint.layout();
    textPaint.paint(canvas, Offset(125, 125)); // 根据需要调整位置

    // 绘制字母B
    textPaint.text = TextSpan(
      style: TextStyle(color: Colors.yellow, fontSize: 20),
      text: 'B',
    );
    textPaint.layout();
    textPaint.paint(canvas, Offset(125, 170)); // 根据需要调整位置
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
