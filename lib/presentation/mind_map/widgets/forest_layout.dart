import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:mindmap_ai/presentation/mind_map/ui_data/node_ui_data_model.dart';
import 'package:mindmap_ai/presentation/mind_map/widgets/mind_map_layout.dart';

/// Result of packing the whole forest
class ForestLayoutResult {
  ForestLayoutResult(this.positions, this.boxes, this.size);

  /// Absolute canvas positions for every node in every tree
  final Map<Node, Offset> positions;

  /// Measured box (w,h) for every node
  final Map<Node, Size> boxes;

  /// Canvas size needed to show everything (InteractiveViewer child size)
  final Size size;
}

/// Packs multiple trees one **below** another with a safe gap.
/// Recomputed on every build so edits/additions never overlap trees.
class ForestLayout {
  static const double _forestTop = 60;

  // Minimum space between two trees
  static const double _minTreeGap = 80;

  ForestLayoutResult compute(
    List<Node> roots,
    TextStyle textStyle, {
    Map<Node, String>? labelOverrides,
  }) {
    final positions = <Node, Offset>{};
    final boxes = <Node, Size>{};

    double cursorY = _forestTop;

    for (final root in roots) {
      final tree = MindMapLayout().compute(
        root,
        textStyle,
        labelOverrides: labelOverrides,
      );

      tree.positions.forEach((node, p) {
        positions[node] = Offset(p.dx, p.dy + cursorY);
        boxes[node] = tree.boxes[node]!;
      });

      final rect = _bounds(tree.positions, tree.boxes);
      cursorY += rect.height + _minTreeGap;
    }

    double maxRight = 0, maxBottom = 0;
    positions.forEach((n, p) {
      final sz = boxes[n]!;
      maxRight = math.max(maxRight, p.dx + sz.width);
      maxBottom = math.max(maxBottom, p.dy + sz.height);
    });

    const extraRight = 64.0;
    const extraBottom = 64.0;

    final size = Size(maxRight + extraRight, maxBottom + extraBottom);
    return ForestLayoutResult(positions, boxes, size);
  }

  /// Tight bounding rectangle around a single tree
  Rect _bounds(Map<Node, Offset> pos, Map<Node, Size> box) {
    double minX = double.infinity, minY = double.infinity;
    double maxX = -double.infinity, maxY = -double.infinity;

    pos.forEach((n, p) {
      final s = box[n]!;
      minX = math.min(minX, p.dx);
      minY = math.min(minY, p.dy);
      maxX = math.max(maxX, p.dx + s.width);
      maxY = math.max(maxY, p.dy + s.height);
    });

    if (minX == double.infinity) return Rect.zero;
    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }
}
