import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:math' as math;
import 'package:mindmap_ai/presentation/mind_map/ui_data/node_ui_data_model.dart';
import 'package:mindmap_ai/presentation/mind_map/widgets/custom_app_bar.dart';
import 'package:mindmap_ai/presentation/mind_map/widgets/forest_layout.dart';
import 'package:mindmap_ai/presentation/mind_map/widgets/hint_button.dart';
import 'package:mindmap_ai/presentation/mind_map/widgets/ml_text.dart';
import 'package:mindmap_ai/presentation/mind_map/widgets/node_context_menu.dart';
import 'package:mindmap_ai/presentation/mind_map/widgets/node_widget.dart';
import 'package:mindmap_ai/presentation/mind_map/widgets/painters/edge_painter.dart';
import 'package:mindmap_ai/presentation/mind_map/widgets/painters/hint_painter.dart';
import 'package:mindmap_ai/presentation/mind_map/widgets/toast.dart';
import 'package:mindmap_ai/utility/constant.dart';
import 'package:mindmap_ai/utility/styles.dart';
import 'package:mindmap_ai/view_model/mind_map/mind_map_view_model.dart';
import 'package:mindmap_ai/view_model/mind_map/ui_event.dart';

class MindMapPage extends StatefulWidget {
  const MindMapPage({super.key, required this.vm});

  final MindMapViewModel vm;

  @override
  State<MindMapPage> createState() => _MindMapPageState();
}

class _MindMapPageState extends State<MindMapPage>
    with TickerProviderStateMixin {
  Node? focused;
  Node? editing;
  final _editController = TextEditingController();
  final _editFocus = FocusNode();

  // controller for the bottom prompt
  final _promptController = TextEditingController();

  late ForestLayoutResult forest;
  final _viewerController = TransformationController();
  final GlobalKey _viewportKey = GlobalKey();

  double _zoom = 1.0;
  static const double _capIn = 1.6;
  static const double _capOut = 0.75;

  TapDownDetails? _lastDoubleTapDown;

  @override
  void initState() {
    super.initState();
    _viewerController.addListener(() {
      final s = _viewerController.value.getMaxScaleOnAxis();
      if (s != _zoom) setState(() => _zoom = s);
    });
    _editController.addListener(() {
      if (editing != null) setState(() {});
    });
  }

  @override
  void dispose() {
    _viewerController.dispose();
    _editController.dispose();
    _editFocus.dispose();
    _promptController.dispose();
    super.dispose();
  }

  void _goToWorldCenter(Offset worldCenter, {double scale = 1.0}) {
    final box = _viewportKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    final viewCenter = box.size.center(Offset.zero);

    final begin = _viewerController.value.clone();
    final end = Matrix4.identity()
      ..translate(viewCenter.dx, viewCenter.dy)
      ..scale(scale.clamp(0.6, 1.6))
      ..translate(-worldCenter.dx, -worldCenter.dy);

    final ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    final anim = Matrix4Tween(begin: begin, end: end)
        .animate(CurvedAnimation(parent: ctrl, curve: Curves.easeOut));
    ctrl.addListener(() => _viewerController.value = anim.value);
    ctrl.addStatusListener((s) {
      if (s == AnimationStatus.completed || s == AnimationStatus.dismissed) {
        ctrl.dispose();
      }
    });
    ctrl.forward();
  }

  void _centerOnFocused() {
    if (widget.vm.roots.isEmpty) return;

    final textMul = _textScaleCompensator();
    final style = Styles.kNodeFont.copyWith(fontSize: 16 * textMul);
    final overrides = editing != null ? {editing!: _editController.text} : null;

    final forest = ForestLayout()
        .compute(widget.vm.roots, style, labelOverrides: overrides);

    final target = focused ?? widget.vm.roots.first;
    final p = forest.positions[target];
    final sz = forest.boxes[target];
    if (p == null || sz == null) return;

    final nodeCenter = Offset(p.dx + sz.width / 2, p.dy + sz.height / 2);
    _goToWorldCenter(nodeCenter, scale: 1.0);
  }

  double _textScaleCompensator() {
    if (_zoom > _capIn) return _capIn / _zoom;
    if (_zoom < _capOut) return _capOut / _zoom;
    return 1.0;
  }

  void _startEditing(Node node) {
    setState(() {
      focused = node;
      editing = node;
      _editController.text = node.label;
      Future.microtask(() => _editFocus.requestFocus());
    });
  }

  void _commitEdit(Node node, String text) {
    final t = text.trim();
    if (t.isEmpty) {
      setState(() => editing = null);
      return;
    }
    setState(() => editing = null);
    widget.vm.updateLabel(nodeId: node.id, label: t);
  }

  void _onDoubleTapDown(TapDownDetails d) => _lastDoubleTapDown = d;

  void _onDoubleTap() => _animateZoomInAtTap(factor: 1.35);

  void _animateZoomInAtTap({required double factor}) {
    final tapPos = _lastDoubleTapDown?.localPosition;
    if (tapPos == null) return;

    final begin = _viewerController.value.clone();
    final end = begin.clone()
      ..translate(tapPos.dx, tapPos.dy)
      ..scale(factor)
      ..translate(-tapPos.dx, -tapPos.dy);

    final controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    final anim = Matrix4Tween(begin: begin, end: end).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeOut),
    );
    controller.addListener(() => _viewerController.value = anim.value);
    controller.addStatusListener((s) {
      if (s == AnimationStatus.completed || s == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });
    controller.forward();
  }

  Offset _hintPointFor(Node n, Map<Node, Offset> pos, Map<Node, Size> boxOf) {
    final p = pos[n];
    final sz = boxOf[n];
    if (p == null || sz == null) return Offset.zero;
    final right = Offset(p.dx + sz.width, p.dy + sz.height / 2);
    return Offset(right.dx + SizeConstants.hGap * 0.6, right.dy);
  }

  UINode? _resolveById(UINode? current, Iterable<Node> pool) {
    if (current == null) return null;
    for (final n in pool) {
      if (n is UINode && n.id == current.id) return n;
    }
    return null;
  }

  Future<void> _showContextMenu(
      BuildContext context, Node node, Offset global) async {
    final choice = await showNodeContextMenu(context, global: global);
    if (choice == 'add') {
      final label = await _promptForLabel(context, title: 'Add child node');
      if (label == null || label.trim().isEmpty) return;
      await widget.vm.addChild(parentId: node.id, label: label.trim());
      setState(() {});
    } else if (choice == 'delete') {
      await widget.vm.deleteNode(node.id);
      if (focused == node) focused = null;
      if (editing == node) editing = null;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final kbInset = media.viewInsets.bottom;
    final safeBottom = media.padding.bottom;

    final double bottomPad = 12 + (kbInset > 0 ? kbInset + 8 : safeBottom);

    const double fabSize = 64; // your SVG button height/width
    const double fabMargin = 16; // gap from edges
    const double fabHalo = 20; // any glow/halo
    const double rightSafe = fabSize + fabMargin + fabHalo;

    final double barWidth = math.min(560, media.size.width - 16 - rightSafe);
    return AnimatedBuilder(
      animation: widget.vm,
      builder: (context, _) {
        final hasMaps = widget.vm.roots.isNotEmpty;
        final textMul = _textScaleCompensator();
        final effectiveTextStyle =
            Styles.kNodeFont.copyWith(fontSize: 16 * textMul);

        final Map<Node, String>? overrides =
            editing != null ? {editing!: _editController.text} : null;

        Size canvasSize;
        Map<Node, Offset> positions = const {};
        Map<Node, Size> boxes = const {};

        if (hasMaps) {
          final forest = ForestLayout().compute(
            widget.vm.roots,
            effectiveTextStyle,
            labelOverrides: overrides,
          );
          canvasSize = forest.size;
          positions = forest.positions;
          final focusedResolved = _resolveById(focused, positions.keys);
          final editingResolved = _resolveById(editing, positions.keys);
          focused = focusedResolved;
          editing = editingResolved;
          boxes = forest.boxes;

          if (focusedResolved != null) {
            final p = positions[focusedResolved]!;
            final sz = boxes[focusedResolved]!;
            const hintRun =
                SizeConstants.hGap * SizeConstants.hintFractionOfGap +
                    SizeConstants.hintPlusDiameter +
                    SizeConstants.rightSafety;
            final neededRight = p.dx + sz.width + hintRun;
            if (neededRight + SizeConstants.canvasRightGutter >
                canvasSize.width) {
              canvasSize = Size(
                neededRight + SizeConstants.canvasRightGutter,
                canvasSize.height,
              );
            }
          }
        } else {
          canvasSize = const Size(1400, 900);
        }

        final viewer = InteractiveViewer(
          key: _viewportKey,
          transformationController: _viewerController,
          minScale: 0.4,
          maxScale: 3.0,
          boundaryMargin: const EdgeInsets.all(4000),
          constrained: false,
          panEnabled: true,
          scaleEnabled: true,
          clipBehavior: Clip.none,
          child: SizedBox(
            width: canvasSize.width,
            height: canvasSize.height,
            child: Stack(
              children: [
                if (hasMaps) ...[
                  CustomPaint(
                    size: canvasSize,
                    painter: EdgePainter(
                      positions: positions,
                      boxes: boxes,
                      rootsVisible: widget.vm.roots,
                    ),
                  ),
                  CustomPaint(
                    size: canvasSize,
                    painter: HintPainter(
                      focused: focused,
                      positions: positions,
                      boxes: boxes,
                      hGap: SizeConstants.hGap,
                    ),
                  ),
                  if (focused != null)
                    HintPlusButton(
                      target: _hintPointFor(focused!, positions, boxes),
                      onPressed: () async {
                        final label = await _promptForLabel(context,
                            title: 'Add child node');
                        if (label == null || label.trim().isEmpty) return;
                        await widget.vm.addChild(
                            parentId: focused!.id, label: label.trim());
                        setState(() {}); // rebuild
                      },
                    ),
                  ...positions.entries.map((e) {
                    final node = e.key;
                    final pos = e.value;
                    final sz = boxes[node]!;
                    return Positioned(
                      left: pos.dx,
                      top: pos.dy,
                      width: sz.width,
                      height: sz.height,
                      child: MindNodeCard(
                        label:
                            node == editing ? _editController.text : node.label,
                        nodeColorPalette: node.nodeColorPalette,
                        isFocused: node == focused,
                        isEditing: node == editing,
                        editController: _editController,
                        editFocus: _editFocus,
                        textStyle: effectiveTextStyle,
                        onTap: () {
                          focused = node;
                          _startEditing(node);
                        },
                        onCommit: (txt) => _commitEdit(node, txt),
                        onLongPressAt: (global) =>
                            _showContextMenu(context, node, global),
                      ),
                    );
                  }),
                ] else ...[
                  const Center(
                    child: Text(
                      'No mind maps available.\nData will load from API/AI service.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );

        return Scaffold(
          appBar: const MindMapAppBar(),
          backgroundColor: Colors.white,
          resizeToAvoidBottomInset: false,
          body: Stack(
            clipBehavior: Clip.none,
            children: [
              GestureDetector(
                onDoubleTapDown: _onDoubleTapDown,
                onDoubleTap: _onDoubleTap,
                child: viewer,
              ),
              Positioned(
                left: 16, // bottom-left anchor
                width: barWidth, // safe width (won’t touch the FAB)
                bottom: bottomPad, // sits above keyboard or safe area
                child: AIPromptBar(
                  controller: _promptController,
                  isLoading: widget.vm.isGenerating,
                  hintText: "Generate Mind Map...",
                  onSubmit: (q) => widget.vm.generate(q),
                ),
              ),
              ValueListenableBuilder<UiEvent?>(
                valueListenable: widget.vm.toastEvent,
                builder: (context, evt, _) {
                  if (evt != null) {
                    // Show after this frame so overlay can mount safely.
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      Toasts.show(
                        context,
                        type: evt.type,
                        title: evt.title,
                        message: evt.message,
                      );
                      widget.vm.clearToast();
                      // optional: clear the prompt on success
                      if (evt.type == UiEventType.success) {
                        _promptController.clear();
                      }
                    });
                  }
                  return const SizedBox.shrink();
                },
              )
            ],
          ),
          floatingActionButton: widget.vm.roots.isNotEmpty
              ? InkWell(
                  onTap: _centerOnFocused,
                  child: SvgPicture.asset(
                    ImageAssets.zoomButton,
                    height: 64,
                    width: 64,
                  ),
                )
              : null,
        );
      },
    );
  }

  Future<String?> _promptForLabel(BuildContext context,
      {required String title}) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (v) => Navigator.pop(ctx, v),
          decoration: const InputDecoration(
              labelText: 'Label', hintText: 'Type node text'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, controller.text),
              child: const Text('Add')),
        ],
      ),
    );
  }
}
