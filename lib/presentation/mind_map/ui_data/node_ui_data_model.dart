/* =========================
   UI MODEL (presentation only)
   ========================= */
import 'dart:ui';
import 'package:mindmap_ai/utility/node_colors/node_color_palette.dart';

class UINode {
  UINode({
    required this.id,
    required this.label,
    required this.nodeColorPalette,
    List<UINode>? children,
  }) : children = children ?? [];

  final String id;
  String label;
  final INodeColorPalette nodeColorPalette;
  final List<UINode> children;
}

// For painters/layout:
typedef Node = UINode;

/* =========================
   LAYOUT (single tree)
   ========================= */
class LayoutResult {
  LayoutResult(this.positions, this.boxes, this.size);

  final Map<Node, Offset> positions; // top-left
  final Map<Node, Size> boxes; // measured
  final Size size;
}
