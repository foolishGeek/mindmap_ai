/* =========================
   MAPPERS
   ========================= */

import 'package:mindmap_ai/presentation/mind_map/ui_data/node_ui_data_model.dart';
import 'package:mindmap_ai/repository/mind_map/entity/node_dto_model.dart';
import 'package:mindmap_ai/repository/mind_map/entity/node_entity_model.dart';
import 'package:mindmap_ai/utility/node_colors/node_color_palette.dart';

NodeEntity _toEntity(NodeDto d) => NodeEntity(
    id: d.id, label: d.label, children: d.children.map(_toEntity).toList());

ForestEntity forestToEntity(ForestDto f) => ForestEntity(
      mapId: f.mapId,
      title: f.title,
      version: f.version,
      trees: f.trees.map((t) => TreeEntity(_toEntity(t.root))).toList(),
    );

List<UINode> uiRootsFromForest(ForestEntity forest) {
  final out = <UINode>[];
  for (int i = 0; i < forest.trees.length; i++) {
    final colorPalette = NodeColors.presets[i % NodeColors.presets.length];
    UINode build(NodeEntity e) => UINode(
          id: e.id,
          label: e.label,
          nodeColorPalette: colorPalette, // per-tree color
          children: e.children.map(build).toList(),
        );
    out.add(build(forest.trees[i].root));
  }
  return out;
}
