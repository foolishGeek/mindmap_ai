import 'dart:convert';

import 'package:mindmap_ai/mock_data/mind_map_mocks.dart';
import 'package:mindmap_ai/services/mind_map/mind_map_service_interface.dart';

class ApiMindMapService implements IMindMapService {
  @override
  Future<Map<String, dynamic>> fetchForest(String mapId) async {
    return Future.value(jsonDecode(mockForestJson) as Map<String, dynamic>);
  }

  @override
  Future<Map<String, dynamic>> createNode(String mapId,
          {required String parentId,
          required String label,
          required int version}) =>
      throw UnimplementedError();

  @override
  Future<Map<String, dynamic>> updateNode(String mapId, String nodeId,
          {String? label, String? parentId, required int version}) =>
      throw UnimplementedError();

  @override
  Future<void> deleteNode(String mapId, String nodeId,
          {required int version}) =>
      throw UnimplementedError();
}
