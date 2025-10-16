import 'package:flutter/material.dart';

class DraggableShape extends StatefulWidget {
  final List<Offset> points;

  DraggableShape(this.points);

  @override
  _DraggableShapeState createState() => _DraggableShapeState();
}

class _DraggableShapeState extends State<DraggableShape> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: widget.points.map((point) {
        return Positioned(
          left: point.dx,
          top: point.dy,
          child: Draggable<Offset>(
            data: point,
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            feedback: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
            ),
            onDraggableCanceled: (velocity, offset) {
              setState(() {
                int index = widget.points.indexOf(point);
                widget.points[index] = offset;
              });
            },
          ),
        );
      }).toList()
        ..add(
          Positioned.fill(
            child: CustomPaint(
              painter: ShapePainter(widget.points),
            ),
          ),
        ),
    );
  }
}

class ShapePainter extends CustomPainter {
  final List<Offset> points;

  ShapePainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    Path path = Path()..moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
