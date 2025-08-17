import 'package:flutter/material.dart';
import 'package:mindmap_ai/presentation/mind_map/widgets/mind_map_page.dart';
import 'package:mindmap_ai/repository/mind_map/mind_map_repository.dart';
import 'package:mindmap_ai/services/mind_map/api_service/mind_map_api_service.dart';
import 'package:mindmap_ai/services/mind_map/ml_service/mind_map_ml_service.dart';
import 'package:mindmap_ai/view_model/mind_map/mind_map_view_model.dart';

class MindMapApp extends StatelessWidget {
  const MindMapApp({super.key});

  @override
  Widget build(BuildContext context) {
    final service = ApiMindMapService();
    final aiService = AiPromptService();
    final repo = MindMapRepositoryImpl(service, aiService);
    final vm = MindMapViewModel(repo: repo, mapId: 'demo_001')..load(); //Mocked data later real api service class

    return MaterialApp(
      title: 'Mind Map AI',
      debugShowCheckedModeBanner: false,
      home: MindMapPage(vm: vm),
    );
  }
}
