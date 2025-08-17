/* =========================
   HINT PAINTER
   - if focused node has children -> draw nothing (only + button remains)
   ========================= */

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:mindmap_ai/presentation/mind_map/ui_data/node_ui_data_model.dart';
import 'package:mindmap_ai/utility/constant.dart';

class HintPainter extends CustomPainter {
  HintPainter({
    required this.focused,
    required this.positions,
    required this.boxes,
    required this.hGap,
  });

  final Node? focused;
  final Map<Node, Offset> positions;
  final Map<Node, Size> boxes;
  final double hGap;

  static const double _stroke = 0.8;
  static const Color _color = Color(0x4D000000);
  static const double _dashLen = 6.0;
  static const double _dashGap = 5.0;

  static const double _arrowLen = 7.0;
  static const double _arrowSpread = 0.55;

  static const double _tipInset = 6.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (focused == null) return;

    if (focused!.children.isNotEmpty) return;

    final pos = positions[focused];
    final box = boxes[focused];
    if (pos == null || box == null) return;

    final start = Offset(pos.dx + box.width, pos.dy + box.height / 2);

    final plusCenter = Offset(
      start.dx + hGap * SizeConstants.hintFractionOfGap,
      start.dy,
    );
    const plusRadius = SizeConstants.hintPlusDiameter / 2.0;

    final tip = Offset(
      plusCenter.dx - plusRadius - _tipInset,
      plusCenter.dy,
    );

    final endForDashes = Offset(tip.dx - _arrowLen, tip.dy);

    final paint = Paint()
      ..color = _color
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    _drawDashedLine(canvas, start, endForDashes, paint, _dashLen, _dashGap);
    _drawOpenChevron(canvas, tip, 0.0, paint);
  }

  void _drawDashedLine(
    Canvas c,
    Offset a,
    Offset b,
    Paint p,
    double dash,
    double gap,
  ) {
    final v = b - a;
    final len = v.distance;
    if (len <= 0) return;

    final dir = v / len;
    double covered = 0.0;
    bool draw = true;

    while (covered < len) {
      final seg = draw ? dash : gap;
      final clamped = math.min(seg, len - covered);
      final s = a + dir * covered;
      final e = s + dir * clamped;
      if (draw) c.drawLine(s, e, p);
      covered += clamped;
      draw = !draw;
    }
  }

  void _drawOpenChevron(Canvas c, Offset tip, double angle, Paint p) {
    final a1 = angle - _arrowSpread;
    final a2 = angle + _arrowSpread;

    final arm1 = Offset(
      tip.dx - _arrowLen * math.cos(a1),
      tip.dy - _arrowLen * math.sin(a1),
    );
    final arm2 = Offset(
      tip.dx - _arrowLen * math.cos(a2),
      tip.dy - _arrowLen * math.sin(a2),
    );

    c.drawLine(tip, arm1, p);
    c.drawLine(tip, arm2, p);
  }

  @override
  bool shouldRepaint(covariant HintPainter old) =>
      old.focused != focused ||
      old.positions != positions ||
      old.boxes != boxes ||
      old.hGap != hGap;
}
