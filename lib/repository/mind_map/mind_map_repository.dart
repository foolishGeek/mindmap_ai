/* =========================
   REPOSITORY (abstraction + impl)
   ========================= */

import 'package:mindmap_ai/repository/mind_map/entity/mappers.dart';
import 'package:mindmap_ai/repository/mind_map/entity/node_dto_model.dart';
import 'package:mindmap_ai/repository/mind_map/entity/node_entity_model.dart';
import 'package:mindmap_ai/services/mind_map/mind_map_service_interface.dart';
import 'package:mindmap_ai/services/mind_map/ml_service/mind_map_ml_service.dart';

abstract class MindMapRepository {
  Future<ForestEntity> generateForestFromPrompt(String prompt);

  Future<ForestEntity> loadForest(String mapId);

  Future<void> addNode(String mapId,
      {required String parentId, required String label, required int version});

  Future<void> patchNode(String mapId, String nodeId,
      {String? label, String? parentId, required int version});

  Future<void> removeNode(String mapId, String nodeId, {required int version});
}

class MindMapRepositoryImpl implements MindMapRepository {
  MindMapRepositoryImpl(this.service, this.aiPromptService);

  final IMindMapService service;
  final IAiPromptService aiPromptService;

  @override
  Future<ForestEntity> loadForest(String mapId) async {
    final jsonMap = await service.fetchForest(mapId);
    final jsonData = jsonMap;
    final dto = ForestDto.fromJson(jsonData);
    final entity = forestToEntity(dto);
    return entity;
  }

  @override
  Future<void> addNode(String mapId,
      {required String parentId,
      required String label,
      required int version}) async {
    // would call service.createNode(...)
  }

  @override
  Future<void> patchNode(String mapId, String nodeId,
      {String? label, String? parentId, required int version}) async {
    // would call service.updateNode(...)
  }

  @override
  Future<void> removeNode(String mapId, String nodeId,
      {required int version}) async {
    // would call service.deleteNode(...)
  }

  @override
  Future<ForestEntity> generateForestFromPrompt(String prompt) async {
    final jsonMap = await aiPromptService.generateFromPrompt(prompt);
    final dto = ForestDto.fromJson(jsonMap);
    final entity = forestToEntity(dto);
    return entity;
  }
}
