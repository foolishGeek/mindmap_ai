/* =========================
   SERVICES (abstractions; empty implementations)
   ========================= */

abstract class IMindMapService {
  Future<Map<String, dynamic>> fetchForest(String mapId);

  Future<Map<String, dynamic>> createNode(
    String mapId, {
    required String parentId,
    required String label,
    required int version,
  });

  Future<Map<String, dynamic>> updateNode(
    String mapId,
    String nodeId, {
    String? label,
    String? parentId,
    required int version,
  });

  Future<void> deleteNode(String mapId, String nodeId, {required int version});
}
