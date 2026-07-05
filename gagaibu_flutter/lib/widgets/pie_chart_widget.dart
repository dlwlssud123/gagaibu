import 'dart:math';
import 'package:flutter/material.dart';

class PieChartWidget extends StatelessWidget {
  final Map<String, double> data; // 카테고리별 비중 (0.0 ~ 1.0)
  final String centerText;

  const PieChartWidget({
    super.key,
    required this.data,
    required this.centerText,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160.0,
      height: 160.0,
      child: CustomPaint(
        painter: _PieChartPainter(
          data: data,
          centerText: centerText,
        ),
      ),
    );
  }
}

class _PieChartPainter extends CustomPainter {
  final Map<String, double> data;
  final String centerText;

  _PieChartPainter({
    required this.data,
    required this.centerText,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width / 2;
    final Offset center = Offset(radius, radius);
    
    // 도넛 두께 설정
    const double strokeWidth = 24.0;
    final double paintRadius = radius - (strokeWidth / 2);

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    double startAngle = -pi / 2; // 12시 방향 시작

    // 지출 비중 그리기
    data.forEach((category, percentage) {
      if (percentage <= 0.0) return;

      paint.color = getCategoryColor(category);
      final double sweepAngle = percentage * 2 * pi;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: paintRadius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
    });

    // 만약 데이터가 아예 비어있다면 디폴트 회색 원 그리기
    if (data.isEmpty || data.values.every((val) => val <= 0.0)) {
      paint.color = const Color(0xFFE9ECEF);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: paintRadius),
        0,
        2 * pi,
        false,
        paint,
      );
    }

    // 도넛 내부 중앙 총액 텍스트 드로잉
    final textPainter = TextPainter(
      text: TextSpan(
        style: TextStyle(
          fontFamily: 'Outfit',
          fontSize: 14.5,
          fontWeight: FontWeight.w900,
          color: Colors.grey[800],
        ),
        children: [
          const TextSpan(
            text: '총 지출\n',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
              color: Colors.black45,
            ),
          ),
          TextSpan(text: centerText),
        ],
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - (textPainter.width / 2),
        center.dy - (textPainter.height / 2),
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  Color getCategoryColor(String cat) {
    switch (cat) {
      case '식비': return const Color(0xFFEF4444); // 빨강
      case '마트/편의점': return const Color(0xFF06B6D4); // 청록
      case '교통/차량': return const Color(0xFFF59E0B); // 주황
      case '주거/통신': return const Color(0xFF3B82F6); // 파랑
      case '구독/정기결제': return const Color(0xFF8B5CF6); // 보라
      case '패션/미용': return const Color(0xFFEC4899); // 핑크
      case '생활용품': return const Color(0xFF6B7280); // 회색
      case '문화/여가': return const Color(0xFF10B981); // 초록
      case '건강/의료': return const Color(0xFF14B8A6); // 청색
      case '여행/숙박': return const Color(0xFF0284C7); // 하늘
      case '교육/자기개발': return const Color(0xFF16A34A); // 연초록
      case '경조사/선물': return const Color(0xFFD97706); // 갈색
      default: return const Color(0xFFADB5BD); // 밝은회색
    }
  }
}
