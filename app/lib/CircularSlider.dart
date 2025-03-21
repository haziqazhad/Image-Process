import 'package:flutter/material.dart';
import 'dart:math';

class CircularSlider extends StatefulWidget {
  final double min;
  final double max;
  final double initialValue;
  final ValueChanged<double> onChanged;
  final double size;

  const CircularSlider({
    Key? key,
    this.min = 0,
    this.max = 100,
    this.initialValue = 0,
    required this.onChanged,
    this.size = 150,
  }) : super(key: key);

  @override
  _CircularSliderState createState() => _CircularSliderState();
}

class _CircularSliderState extends State<CircularSlider> {
  double _currentValue = 0;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
  }

  void _updateValue(Offset localPosition, Size size) {
    final center = size.center(Offset.zero);
    final dx = localPosition.dx - center.dx;
    final dy = localPosition.dy - center.dy;
    final angle = atan2(dy, dx);

    // Normalize the angle to 0..2π
    final normalizedAngle = (angle + 2 * pi) % (2 * pi);
    final value =
        normalizedAngle / (2 * pi) * (widget.max - widget.min) + widget.min;

    setState(() {
      _currentValue = value.clamp(widget.min, widget.max);
    });

    widget.onChanged(_currentValue);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        if (context.size != null) {
          _updateValue(details.localPosition, context.size!);
        }
      },
      child: CustomPaint(
        size: Size(widget.size, widget.size),
        painter: CircularSliderPainter(
          value: _currentValue,
          min: widget.min,
          max: widget.max,
          size: widget.size,
        ),
      ),
    );
  }
}

class CircularSliderPainter extends CustomPainter {
  final double value;
  final double min;
  final double max;
  final double size;

  CircularSliderPainter({
    required this.value,
    required this.min,
    required this.max,
    required this.size,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = this.size / 15; // Adjust stroke width dynamically

    // Draw the background circle
    final backgroundPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(
      size.center(Offset.zero),
      size.width / 2 - strokeWidth,
      backgroundPaint,
    );

    // Draw the progress arc
    final progressPaint = Paint()
      ..color = const Color.fromARGB(255, 213, 177, 245)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final startAngle = -pi / 2; // Start at the top
    final sweepAngle = (value - min) / (max - min) * 2 * pi;

    canvas.drawArc(
      Rect.fromCircle(
        center: size.center(Offset.zero),
        radius: size.width / 2 - strokeWidth,
      ),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );

    // Draw the knob
    final knobPaint = Paint()..color = const Color.fromARGB(255, 145, 33, 243);
    final knobAngle = startAngle + sweepAngle;
    final knobRadius = size.width / 2 - strokeWidth;
    final knobX = size.center(Offset.zero).dx + knobRadius * cos(knobAngle);
    final knobY = size.center(Offset.zero).dy + knobRadius * sin(knobAngle);

    canvas.drawCircle(
      Offset(knobX, knobY),
      strokeWidth / 2, // Knob size based on stroke width
      knobPaint,
    );

    // Draw the current value in the center
    final textStyle = TextStyle(
      color: const Color.fromARGB(255, 145, 33, 243),
      fontSize: 24,
      fontWeight: FontWeight.bold,
    );

    final textPainter = TextPainter(
      text: TextSpan(text: value.toStringAsFixed(0), style: textStyle),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    final x = (size.width - textPainter.width) / 2;
    final y = (size.height - textPainter.height) / 2;

    textPainter.paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(covariant CircularSliderPainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.min != min ||
        oldDelegate.max != max;
  }
}
