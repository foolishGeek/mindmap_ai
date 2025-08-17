import 'package:flutter/material.dart';
import 'package:mindmap_ai/presentation/mind_map/ui_data/node_ui_data_model.dart';
import 'dart:math' as math;
import 'package:mindmap_ai/utility/constant.dart';

class MindMapLayout {
  static const double _leftMargin = 24;
  static const double _topBottomMargin = 24;

  Size _measureBox(String text, TextStyle style) {
    const maxTextWidth =
        SizeConstants.kMaxNodeWidth - 2 * SizeConstants.kNodeHPad;

    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textHeightBehavior: const TextHeightBehavior(
        applyHeightToFirstAscent: false,
        applyHeightToLastDescent: false,
      ),
      strutStyle: StrutStyle(
        fontSize: style.fontSize,
        height: 1.0,
        leading: 0,
        forceStrutHeight: true,
      ),
      maxLines: null,
    )..layout(maxWidth: maxTextWidth);

    // No extra fudge
    final lines = tp.computeLineMetrics();
    double maxLineW = 0;
    for (final lm in lines) {
      if (lm.width > maxLineW) maxLineW = lm.width;
    }
    final textW = math.max(tp.width, maxLineW);
    final textH = tp.height;

    final width =
        (textW + 2 * SizeConstants.kNodeHPad + SizeConstants.measureRightGutter)
            .clamp(SizeConstants.kMinNodeWidth, SizeConstants.kMaxNodeWidth);

    final height = math.max(
      textH + 2 * SizeConstants.kNodeVPad + SizeConstants.measureBottomGutter,
      SizeConstants.kMinNodeHeight,
    );

    return Size(width.ceilToDouble(), height.ceilToDouble());
  }

  LayoutResult compute(
    Node rootVisible,
    TextStyle style, {
    Map<Node, String>? labelOverrides,
  }) {
    final positions = <Node, Offset>{};
    final boxes = <Node, Size>{};

    void measure(Node n) {
      final text = labelOverrides != null && labelOverrides.containsKey(n)
          ? labelOverrides[n]!
          : n.label;
      boxes[n] = _measureBox(text, style);
      for (final c in n.children) {
        measure(c);
      }
    }

    final Map<Node, double> subH = {};
    double hOf(Node n) {
      if (n.children.isEmpty) {
        subH[n] = boxes[n]!.height;
        return subH[n]!;
      }
      double sum = 0;
      for (final c in n.children) {
        sum += hOf(c);
      }
      sum += SizeConstants.vGap * (n.children.length - 1);
      subH[n] = math.max(boxes[n]!.height, sum);
      return subH[n]!;
    }

    void place(Node n, {required double x, required double centerY}) {
      final box = boxes[n]!;
      final top = centerY - box.height / 2;
      positions[n] = Offset(x, top);

      if (n.children.isEmpty) return;

      final childX = x + box.width + SizeConstants.hGap;

      final kids = n.children;
      double current = centerY;

      for (int i = 0; i < kids.length; i++) {
        final c = kids[i];
        place(c, x: childX, centerY: current);

        if (i < kids.length - 1) {
          final thisHalf = (subH[c] ?? SizeConstants.kMinNodeHeight) / 2;
          final nextHalf =
              (subH[kids[i + 1]] ?? SizeConstants.kMinNodeHeight) / 2;
          current += thisHalf + SizeConstants.vGap + nextHalf;
        }
      }
    }

    measure(rootVisible);
    hOf(rootVisible);

    final rootCenterY = _topBottomMargin +
        (subH[rootVisible] ?? SizeConstants.kMinNodeHeight) / 2;
    const rootX = _leftMargin + 60;
    place(rootVisible, x: rootX, centerY: rootCenterY);

    double maxRight = 0, maxBottom = 0;
    positions.forEach((n, p) {
      final sz = boxes[n]!;
      maxRight = math.max(maxRight, p.dx + sz.width);
      maxBottom = math.max(maxBottom, p.dy + sz.height);
    });

    const extraRight = 64.0;
    const extraBottom = 64.0;

    final width = maxRight + extraRight;
    final height = maxBottom + extraBottom;

    return LayoutResult(positions, boxes, Size(width, height));
  }
}
