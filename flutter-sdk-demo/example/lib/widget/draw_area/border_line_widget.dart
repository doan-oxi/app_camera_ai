import 'dart:ui';

import 'package:flutter/material.dart';

class BorderLineWidget extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final pointPaint = Paint()
      ..color = Colors.green
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 10;

    final linePaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 4;

    final textPaint = Paint()..color = Colors.red;

    final arrowPaint = Paint()
      ..color = Colors.yellow
      ..strokeWidth = 2;

    // 绘制点
    final point1 = Offset(200, 50);
    final point2 = Offset(200, 200);
    canvas.drawPoints(PointMode.points, [point1, point2], pointPaint);

    // 绘制连接线
    canvas.drawLine(point1, point2, linePaint);

    // 绘制字母A
    final textSpanA = TextSpan(
      style: TextStyle(color: Colors.red, fontSize: 20),
      text: 'A',
    );
    final textPainterA = TextPainter(
      text: textSpanA,
      textDirection: TextDirection.ltr,
    );
    textPainterA.layout();
    textPainterA.paint(
        canvas, Offset(160, (point1.dy + point2.dy) / 2 - 10)); // 根据需要调整位置

    // 绘制箭头
    final middlePoint =
        Offset((point1.dx + point2.dx) / 2, (point1.dy + point2.dy) / 2);
    final arrowEnd = Offset(middlePoint.dx + 30, middlePoint.dy); // 箭头长度为30
    canvas.drawLine(middlePoint, arrowEnd, arrowPaint);
    canvas.drawLine(
        arrowEnd, Offset(arrowEnd.dx - 10, arrowEnd.dy - 10), arrowPaint);
    canvas.drawLine(
        arrowEnd, Offset(arrowEnd.dx - 10, arrowEnd.dy + 10), arrowPaint);

    // 绘制字母B
    final textSpanB = TextSpan(
      style: TextStyle(color: Colors.yellow, fontSize: 20),
      text: 'B',
    );
    final textPainterB = TextPainter(
      text: textSpanB,
      textDirection: TextDirection.ltr,
    );
    textPainterB.layout();
    textPainterB.paint(
        canvas, Offset(arrowEnd.dx + 5, arrowEnd.dy - 20)); // 根据需要调整位置
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
