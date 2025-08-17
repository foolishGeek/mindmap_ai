/* =========================
   EDGE PAINTER (L→R, top→bottom only)
   - Straight run from parent row, trunk goes DOWN only
   - Bottom child gets a quadratic elbow
   - 6 px gap at tail (parent) and head (child)
   ========================= */

import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:mindmap_ai/presentation/mind_map/ui_data/node_ui_data_model.dart';
import 'package:mindmap_ai/utility/constant.dart';
import 'package:mindmap_ai/utility/styles.dart';

class EdgePainter extends CustomPainter {
  EdgePainter({
    required this.positions,
    required this.boxes,
    required this.rootsVisible,
  });

  final Map<Node, Offset> positions;
  final Map<Node, Size> boxes;
  final List<Node> rootsVisible;

  // Tunables
  static const double _stubLen = 34.0;
  static const double _minLastStub = 8.0;
  static const double _radius = 8.0;
  static const double _epsY = 0.75;
  static const double _safety = 6.0;
  static const double _gapHead = 6.0;
  static const double _gapTail = 6.0;

  @override
  void paint(Canvas canvas, Size size) {
    final runPaint = Paint()
      ..color = ColorConstants.edgeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = SizeConstants.kEdgeStroke
      ..strokeCap = StrokeCap.butt
      ..strokeJoin = StrokeJoin.miter;

    final stubPaint = Paint()
      ..color = ColorConstants.edgeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = SizeConstants.kEdgeStroke
      ..strokeCap = StrokeCap.butt
      ..strokeJoin = StrokeJoin.miter;

    void drawGroup(Node parent) {
      final kids = parent.children;
      if (kids.isEmpty) return;

      final pTL = positions[parent]!;
      final pBox = boxes[parent]!;
      final pRight = Offset(pTL.dx + pBox.width, pTL.dy + pBox.height / 2);
      final runStart = Offset(pRight.dx + _gapTail, pRight.dy);

      final tips = <Offset>[];
      for (final c in kids) {
        final cp = positions[c]!;
        final cb = boxes[c]!;
        tips.add(Offset(cp.dx - _gapHead, cp.dy + cb.height / 2));
      }

      if (tips.length == 1 && (tips.first.dy - runStart.dy).abs() < _epsY) {
        final tip = tips.first;
        canvas.drawLine(runStart, tip, runPaint);
        _drawChevron(canvas, tip, 0);
        return;
      }

      tips.sort((a, b) => a.dy.compareTo(b.dy));
      final topY = tips.first.dy;
      final botY = tips.last.dy;

      final minTipX = tips.map((t) => t.dx).reduce(math.min);
      final totalGap = (minTipX - runStart.dx).abs();
      double stub = math.min(_stubLen, math.max(0, totalGap - _safety));
      if (stub <= 0) stub = totalGap * 0.5;
      final trunkX = minTipX - stub;

      canvas.drawLine(runStart, Offset(trunkX, runStart.dy), runPaint);

      final trunkTopY = runStart.dy;
      final arcStartY = botY - _radius;
      if (arcStartY > trunkTopY) {
        canvas.drawLine(
            Offset(trunkX, trunkTopY), Offset(trunkX, arcStartY), runPaint);
      }

      final Path elbow = Path()
        ..moveTo(trunkX, math.min(arcStartY, botY))
        ..quadraticBezierTo(trunkX, botY, trunkX + _radius, botY);
      canvas.drawPath(elbow, runPaint);

      for (int i = 0; i < tips.length; i++) {
        final tip = tips[i];
        final isBottom =
            (i == tips.length - 1) || (tip.dy - botY).abs() <= _epsY;

        double startX = isBottom ? (trunkX + _radius) : trunkX;
        if (isBottom && (tip.dx - startX) < _minLastStub) {
          startX = tip.dx - _minLastStub;
        }
        canvas.drawLine(Offset(startX, tip.dy), tip, stubPaint);
        _drawChevron(canvas, tip, 0);
      }
    }

    void walk(Node n) {
      drawGroup(n);
      for (final c in n.children) {
        walk(c);
      }
    }

    for (final r in rootsVisible) {
      walk(r);
    }
  }

  void _drawChevron(Canvas canvas, Offset tip, double angle) {
    final paint = Paint()
      ..color = ColorConstants.edgeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = SizeConstants.kEdgeStroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.miter;

    final p1 = Offset(
      tip.dx -
          SizeConstants.kArrowLen *
              math.cos(angle - SizeConstants.kArrowSpread),
      tip.dy -
          SizeConstants.kArrowLen *
              math.sin(angle - SizeConstants.kArrowSpread),
    );
    final p2 = Offset(
      tip.dx -
          SizeConstants.kArrowLen *
              math.cos(angle + SizeConstants.kArrowSpread),
      tip.dy -
          SizeConstants.kArrowLen *
              math.sin(angle + SizeConstants.kArrowSpread),
    );
    canvas.drawLine(tip, p1, paint);
    canvas.drawLine(tip, p2, paint);
  }

  @override
  bool shouldRepaint(covariant EdgePainter old) =>
      old.positions != positions ||
      old.boxes != boxes ||
      old.rootsVisible != rootsVisible;
}
