import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mindmap_ai/utility/constant.dart';
import 'package:mindmap_ai/utility/node_colors/node_color_palette.dart';

class MindNodeCard extends StatefulWidget {
  const MindNodeCard({
    super.key,
    required this.label,
    required this.nodeColorPalette,
    required this.isFocused,
    required this.isEditing,
    required this.editController,
    required this.editFocus,
    required this.textStyle,
    required this.onTap,
    required this.onCommit,
    required this.onLongPressAt,
  });

  final String label;
  final INodeColorPalette nodeColorPalette;
  final bool isFocused;
  final bool isEditing;
  final TextEditingController editController;
  final FocusNode editFocus;
  final TextStyle textStyle;

  final VoidCallback onTap;
  final ValueChanged<String> onCommit;

  final FutureOr<void> Function(Offset global) onLongPressAt;

  @override
  State<MindNodeCard> createState() => _MindNodeCardState();
}

class _MindNodeCardState extends State<MindNodeCard> {
  bool _pressed = false;

  void _setPressed(bool v) {
    if (_pressed == v) return;
    setState(() => _pressed = v);
  }

  StrutStyle get _tightStrut => StrutStyle(
        fontSize: widget.textStyle.fontSize,
        height: 1.0,
        leading: 0,
        forceStrutHeight: true,
      );

  @override
  Widget build(BuildContext context) {
    final palette = widget.nodeColorPalette;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _setPressed(true),
      onTapCancel: () => _setPressed(false),
      onTapUp: (_) {
        _setPressed(false);
        widget.onTap();
      },
      onLongPressStart: (d) async {
        HapticFeedback.lightImpact();
        _setPressed(true);
        try {
          await Future.sync(() => widget.onLongPressAt(d.globalPosition));
        } finally {
          if (mounted) _setPressed(false);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: palette.bgColor,
          borderRadius: const BorderRadius.all(Radius.circular(6)),
          border: Border.all(width: 0.6, color: palette.textColor),
          boxShadow: _pressed
              ? const [
                  BoxShadow(
                    color: Color(0x33000000), // subtle press elevation
                    blurRadius: 16,
                    offset: Offset(0, 6),
                  ),
                ]
              : const [],
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: SizeConstants.kNodeHPad,
          vertical: SizeConstants.kNodeVPad,
        ),
        alignment: Alignment.center,
        child: widget.isEditing
            ? Focus(
                onFocusChange: (has) {
                  if (!has) widget.onCommit(widget.editController.text);
                },
                child: TextField(
                  focusNode: widget.editFocus,
                  controller: widget.editController,
                  autofocus: true,
                  maxLines: null,
                  minLines: 1,
                  textInputAction: TextInputAction.done,
                  textAlign: TextAlign.center,
                  style: widget.textStyle.copyWith(color: palette.textColor),
                  cursorHeight: (widget.textStyle.fontSize ?? 16) * 1.2,
                  cursorRadius: const Radius.circular(2),
                  onSubmitted: widget.onCommit,
                  onEditingComplete: () {
                    widget.onCommit(widget.editController.text);
                    FocusScope.of(context).unfocus();
                  },
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  strutStyle: _tightStrut,
                ),
              )
            : Text(
                widget.label,
                softWrap: true,
                maxLines: null,
                textAlign: TextAlign.center,
                style: widget.textStyle.copyWith(color: palette.textColor),
                strutStyle: _tightStrut,
              ),
      ),
    );
  }
}
