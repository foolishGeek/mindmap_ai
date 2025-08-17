/* =========================
   DOMAIN ENTITIES
   ========================= */
class NodeEntity {
  final String id;
  final String label;
  final List<NodeEntity> children;

  const NodeEntity(
      {required this.id, required this.label, this.children = const []});
}

class TreeEntity {
  final NodeEntity root;

  const TreeEntity(this.root);
}

class ForestEntity {
  final String mapId;
  final String title;
  final List<TreeEntity> trees;
  final int version;

  const ForestEntity({
    required this.mapId,
    required this.title,
    required this.trees,
    required this.version,
  });
}
