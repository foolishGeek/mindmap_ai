/* =========================
   VIEWMODEL (Controller)
   ========================= */
import 'package:flutter/material.dart';
import 'package:mindmap_ai/presentation/mind_map/ui_data/node_ui_data_model.dart';
import 'package:mindmap_ai/repository/mind_map/entity/mappers.dart';
import 'package:mindmap_ai/repository/mind_map/entity/node_entity_model.dart';
import 'package:mindmap_ai/repository/mind_map/mind_map_repository.dart';
import 'package:mindmap_ai/utility/node_colors/node_color_palette.dart';
import 'package:mindmap_ai/view_model/mind_map/ui_event.dart';

import 'mind_map_vm_interface.dart';

class MindMapViewModel extends ChangeNotifier implements IMindMapViewModel {
  MindMapViewModel({required this.repo, required this.mapId});

  final MindMapRepository repo;
  @override
  final String mapId;

  @override
  bool isGenerating = false;

  ForestEntity? _forest;
  final List<UINode> _roots = [];

  @override
  List<UINode> get roots => _roots;

  @override
  int get version => _forest?.version ?? 0;

  @override
  final ValueNotifier<UiEvent?> toastEvent = ValueNotifier<UiEvent?>(null);

  @override
  void clearToast() => toastEvent.value = null;

  @override
  Future<void> load() async {
    _forest = await repo.loadForest(mapId);
    _roots
      ..clear()
      ..addAll(uiRootsFromForest(_forest!));
    notifyListeners();
  }

  String _newId() => DateTime.now().microsecondsSinceEpoch.toString();

  UINode? _find(String id) {
    UINode? dfs(List<UINode> list) {
      for (final n in list) {
        if (n.id == id) return n;
        final r = dfs(n.children);
        if (r != null) return r;
      }
      return null;
    }

    return dfs(_roots);
  }

  UINode? _findParentOf(String id) {
    UINode? dfs(List<UINode> list, UINode? parent) {
      for (final n in list) {
        if (n.id == id) return parent;
        final r = dfs(n.children, n);
        if (r != null) return r;
      }
      return null;
    }

    return dfs(_roots, null);
  }

  @override
  Future<void> generate(String prompt) async {
    isGenerating = true;
    notifyListeners();
    try {
      final forest = await repo.generateForestFromPrompt(prompt);
      _forest = forest;
      _roots
        ..clear()
        ..addAll(uiRootsFromForest(forest));
      toastEvent.value = UiEvent.success('Success', 'Your list created!');
    } catch (e) {
      toastEvent.value = UiEvent.error('Failed', 'Oops something is broken!');
    } finally {
      isGenerating = false;
      notifyListeners();
    }
  }

  @override
  Future<UINode?> addChild(
      {required String parentId, required String label}) async {
    final p = _find(parentId);
    if (p == null) return null;
    final rootColor = _treeRootColorOf(p);
    final child = UINode(
        id: _newId(), label: label, nodeColorPalette: rootColor, children: []);
    p.children.add(child);
    notifyListeners();
    return child;
  }

  @override
  Future<void> updateLabel(
      {required String nodeId, required String label}) async {
    final n = _find(nodeId);
    if (n == null) return;
    n.label = label;
    notifyListeners();
  }

  @override
  Future<void> deleteNode(String nodeId) async {
    final parent = _findParentOf(nodeId);
    if (parent == null) {
      _roots.removeWhere((e) => e.id == nodeId); // deleting a root
    } else {
      parent.children.removeWhere((e) => e.id == nodeId);
    }
    notifyListeners();
  }

  INodeColorPalette _treeRootColorOf(UINode node) {
    UINode cur = node;
    while (true) {
      final parent = _findParentOf(cur.id);
      if (parent == null) return cur.nodeColorPalette; // reached root
      cur = parent;
    }
  }
}
