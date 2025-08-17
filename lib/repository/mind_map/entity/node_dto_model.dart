/* =========================
   DTOs (for JSON)
   ========================= */

class NodeDto {
  final String id;
  final String label;
  final List<NodeDto> children;

  NodeDto({required this.id, required this.label, this.children = const []});

  factory NodeDto.fromJson(Map<String, dynamic> j) => NodeDto(
        id: j['id'] as String,
        label: j['label'] as String,
        children: (j['children'] as List? ?? [])
            .map((e) => NodeDto.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class TreeDto {
  final NodeDto root;

  TreeDto(this.root);

  factory TreeDto.fromJson(Map<String, dynamic> j) =>
      TreeDto(NodeDto.fromJson(j['root'] as Map<String, dynamic>));
}

class ForestDto {
  final String mapId;
  final String title;
  final List<TreeDto> trees;
  final int version;

  ForestDto({
    required this.mapId,
    required this.title,
    required this.trees,
    required this.version,
  });

  factory ForestDto.fromJson(Map<String, dynamic> j) => ForestDto(
        mapId: j['mapId'] as String,
        title: (j['title'] as String?) ?? '',
        version: (j['version'] as num?)?.toInt() ?? 0,
        trees: (j['trees'] as List).map((e) => TreeDto.fromJson(e)).toList(),
      );
}
