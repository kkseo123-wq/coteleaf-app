import 'dart:math';
import 'package:flutter/material.dart';

/// 방사형(레이더) 차트에 표시할 데이터 항목
class RadarChartData {
  final String label;
  final double value; // 0-100
  final double maxValue;

  RadarChartData({
    required this.label,
    required this.value,
    this.maxValue = 100,
  });
}

/// 커스텀 방사형(레이더/스파이더) 차트 위젯
class RadarChart extends StatelessWidget {
  final List<RadarChartData> data;
  final Color fillColor;
  final Color strokeColor;
  final Color gridColor;
  final Color labelColor;
  final double size;
  final int gridLevels;

  const RadarChart({
    super.key,
    required this.data,
    this.fillColor = const Color(0x334ECDC4),
    this.strokeColor = const Color(0xFF4ECDC4),
    this.gridColor = const Color(0xFFE0E0E0),
    this.labelColor = const Color(0xFF2C3E50),
    this.size = 280,
    this.gridLevels = 4,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        size: Size(size, size),
        painter: _RadarChartPainter(
          data: data,
          fillColor: fillColor,
          strokeColor: strokeColor,
          gridColor: gridColor,
          labelColor: labelColor,
          gridLevels: gridLevels,
        ),
      ),
    );
  }
}

class _RadarChartPainter extends CustomPainter {
  final List<RadarChartData> data;
  final Color fillColor;
  final Color strokeColor;
  final Color gridColor;
  final Color labelColor;
  final int gridLevels;

  _RadarChartPainter({
    required this.data,
    required this.fillColor,
    required this.strokeColor,
    required this.gridColor,
    required this.labelColor,
    required this.gridLevels,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 36;
    final count = data.length;
    final angleStep = (2 * pi) / count;
    // 12시 방향에서 시작 (-pi/2)
    const startAngle = -pi / 2;

    // 1. 그리드 (동심 다각형) 그리기
    _drawGrid(canvas, center, radius, count, angleStep, startAngle);

    // 2. 축선 그리기
    _drawAxes(canvas, center, radius, count, angleStep, startAngle);

    // 3. 데이터 영역 그리기
    _drawDataArea(canvas, center, radius, count, angleStep, startAngle);

    // 4. 데이터 포인트 그리기
    _drawDataPoints(canvas, center, radius, count, angleStep, startAngle);

    // 5. 라벨 그리기
    _drawLabels(canvas, center, radius, count, angleStep, startAngle, size);
  }

  void _drawGrid(Canvas canvas, Offset center, double radius, int count,
      double angleStep, double startAngle) {
    final gridPaint = Paint()
      ..color = gridColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    for (int level = 1; level <= gridLevels; level++) {
      final levelRadius = radius * level / gridLevels;
      final path = Path();

      for (int i = 0; i <= count; i++) {
        final angle = startAngle + angleStep * (i % count);
        final x = center.dx + levelRadius * cos(angle);
        final y = center.dy + levelRadius * sin(angle);

        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }
  }

  void _drawAxes(Canvas canvas, Offset center, double radius, int count,
      double angleStep, double startAngle) {
    final axisPaint = Paint()
      ..color = gridColor.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (int i = 0; i < count; i++) {
      final angle = startAngle + angleStep * i;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);
      canvas.drawLine(center, Offset(x, y), axisPaint);
    }
  }

  void _drawDataArea(Canvas canvas, Offset center, double radius, int count,
      double angleStep, double startAngle) {
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path();

    for (int i = 0; i <= count; i++) {
      final index = i % count;
      final ratio = (data[index].value / data[index].maxValue).clamp(0.0, 1.0);
      final angle = startAngle + angleStep * index;
      final x = center.dx + radius * ratio * cos(angle);
      final y = center.dy + radius * ratio * sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);
  }

  void _drawDataPoints(Canvas canvas, Offset center, double radius, int count,
      double angleStep, double startAngle) {
    final pointPaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.fill;

    final pointBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    for (int i = 0; i < count; i++) {
      final ratio = (data[i].value / data[i].maxValue).clamp(0.0, 1.0);
      final angle = startAngle + angleStep * i;
      final x = center.dx + radius * ratio * cos(angle);
      final y = center.dy + radius * ratio * sin(angle);

      canvas.drawCircle(Offset(x, y), 5, pointBorderPaint);
      canvas.drawCircle(Offset(x, y), 3.5, pointPaint);
    }
  }

  void _drawLabels(Canvas canvas, Offset center, double radius, int count,
      double angleStep, double startAngle, Size size) {
    for (int i = 0; i < count; i++) {
      final angle = startAngle + angleStep * i;
      final labelRadius = radius + 20;
      var x = center.dx + labelRadius * cos(angle);
      var y = center.dy + labelRadius * sin(angle);

      final label = data[i].label;
      final score = data[i].value.round();
      final text = '$label\n$score';

      final textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: labelColor,
            fontSize: 11,
            fontWeight: FontWeight.w500,
            height: 1.3,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );

      textPainter.layout();

      // 라벨 위치 보정
      var dx = x - textPainter.width / 2;
      var dy = y - textPainter.height / 2;

      // 상단 라벨은 위로
      if (angle < -pi / 4 && angle > -3 * pi / 4) {
        dy = y - textPainter.height;
      }
      // 하단 라벨은 아래로
      if (angle > pi / 4 && angle < 3 * pi / 4) {
        dy = y;
      }
      // 좌측 라벨
      if (cos(angle) < -0.5) {
        dx = x - textPainter.width - 2;
      }
      // 우측 라벨
      if (cos(angle) > 0.5) {
        dx = x + 2;
      }

      // 화면 경계 클램프
      dx = dx.clamp(0, size.width - textPainter.width);
      dy = dy.clamp(0, size.height - textPainter.height);

      textPainter.paint(canvas, Offset(dx, dy));
    }
  }

  @override
  bool shouldRepaint(covariant _RadarChartPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.strokeColor != strokeColor;
  }
}
