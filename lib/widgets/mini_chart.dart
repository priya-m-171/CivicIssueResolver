import 'package:flutter/material.dart';
import 'dart:math' as math;

class MiniBarChart extends StatelessWidget {
  final List<double> data;
  final Color color;
  final double height;
  final List<String>? labels;

  const MiniBarChart({
    super.key,
    required this.data,
    required this.color,
    this.height = 90,
    this.labels,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();
    final maxVal = data.reduce((a, b) => a > b ? a : b);
    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: data.asMap().entries.map((entry) {
          final i = entry.key;
          final val = entry.value;
          final ratio = maxVal > 0 ? (val / maxVal) : 0.0;
          final barHeight = ratio * (height - 22);
          final isLast = i == data.length - 1;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    height: barHeight > 4 ? barHeight : 4,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          isLast ? color : color.withValues(alpha: 0.65),
                          isLast
                              ? color.withValues(alpha: 0.75)
                              : color.withValues(alpha: 0.35),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (labels != null && i < labels!.length)
                    Text(
                      labels![i],
                      style: TextStyle(
                        fontSize: 8,
                        color: isLast ? color : const Color(0xFF9CA3AF),
                        fontWeight: isLast
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    )
                  else
                    Text(
                      'W${i + 1}',
                      style: TextStyle(
                        fontSize: 8,
                        color: isLast ? color : const Color(0xFF9CA3AF),
                      ),
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class MiniDonutChart extends StatelessWidget {
  final Map<String, double> data;
  final Map<String, Color> colors;
  final double size;
  final String? centerLabel;
  final String? centerSub;

  const MiniDonutChart({
    super.key,
    required this.data,
    required this.colors,
    this.size = 120,
    this.centerLabel,
    this.centerSub,
  });

  @override
  Widget build(BuildContext context) {
    final total = data.values.fold(0.0, (a, b) => a + b);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _DonutPainter(data: data, colors: colors),
          ),
          if (centerLabel != null)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  centerLabel!,
                  style: TextStyle(
                    fontSize: size * 0.18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                if (centerSub != null)
                  Text(
                    centerSub!,
                    style: TextStyle(
                      fontSize: size * 0.09,
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),
              ],
            )
          else if (total > 0)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${total.toInt()}',
                  style: TextStyle(
                    fontSize: size * 0.17,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                Text(
                  'Total',
                  style: TextStyle(
                    fontSize: size * 0.09,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final Map<String, double> data;
  final Map<String, Color> colors;

  _DonutPainter({required this.data, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final total = data.values.fold(0.0, (a, b) => a + b);
    if (total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = size.width * 0.22;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    double startAngle = -math.pi / 2;
    const double gap = 0.04;

    for (final entry in data.entries) {
      if (entry.value == 0) continue;
      final sweepAngle = (entry.value / total) * (2 * math.pi) - gap;
      paint.color = colors[entry.key] ?? Colors.grey;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
      startAngle += sweepAngle + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
