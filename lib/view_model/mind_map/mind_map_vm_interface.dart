import 'package:flutter/foundation.dart';
import 'package:mindmap_ai/presentation/mind_map/ui_data/node_ui_data_model.dart';
import 'package:mindmap_ai/view_model/mind_map/ui_event.dart';

abstract class IMindMapViewModel implements Listenable {
  String get mapId;

  bool get isGenerating;

  List<UINode> get roots;

  int get version;

  ValueNotifier<UiEvent?> get toastEvent;

  // Actions
  Future<void> load();

  Future<void> generate(String prompt);

  Future<UINode?> addChild({
    required String parentId,
    required String label,
  });

  Future<void> updateLabel({
    required String nodeId,
    required String label,
  });

  Future<void> deleteNode(String nodeId);

  void clearToast();
}
