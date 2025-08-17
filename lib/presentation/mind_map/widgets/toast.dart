import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:mindmap_ai/view_model/mind_map/ui_event.dart';

class Toasts {
  static Flushbar<dynamic>? _active;

  static void show(
    BuildContext context, {
    required UiEventType type,
    required String title,
    required String message,
  }) {
    _active?.dismiss();

    final bool isSuccess = type == UiEventType.success;

    // palette
    final Color darkText =
        isSuccess ? Colors.green.shade800 : Colors.red.shade800;
    final Color ringColor =
        isSuccess ? Colors.green.shade600 : Colors.red.shade600;
    final List<Color> bg = isSuccess
        ? [const Color(0xFFE9F9EF), Colors.white]
        : [const Color(0xFFFFEEF0), Colors.white];
    final Color glowColor = isSuccess ? Colors.green : Colors.red;

    final Widget outlinedIcon = Padding(
      padding: const EdgeInsets.only(left: 12, right: 8),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: ringColor, width: 2),
        ),
        alignment: Alignment.center,
        child: Icon(
          isSuccess ? Icons.check_rounded : Icons.close_rounded,
          size: 16,
          color: ringColor,
        ),
      ),
    );

    final fb = Flushbar(
      flushbarStyle: FlushbarStyle.FLOATING,
      flushbarPosition: FlushbarPosition.BOTTOM,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      borderRadius: BorderRadius.circular(16),
      duration: const Duration(seconds: 3),
      animationDuration: const Duration(milliseconds: 280),
      forwardAnimationCurve: Curves.easeOutCubic,
      reverseAnimationCurve: Curves.easeInCubic,

      // light gradient card + soft colored glow
      backgroundGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: bg,
      ),
      boxShadows: [
        BoxShadow(
          color: glowColor.withOpacity(0.12),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ],

      icon: outlinedIcon,

      titleText: Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Text(
          title,
          style: TextStyle(
            color: darkText,
            fontWeight: FontWeight.w700,
            fontSize: 16,
            height: 1.1,
          ),
        ),
      ),
      messageText: Text(
        message,
        style: TextStyle(
          color: darkText.withOpacity(0.9),
          fontSize: 14,
          height: 1.25,
        ),
      ),

      // trailing close
      mainButton: Builder(
        builder: (ctx) => IconButton(
          icon: Icon(Icons.close_rounded, color: darkText.withOpacity(0.6)),
          onPressed: () => _active?.dismiss(),
          tooltip: 'Dismiss',
        ),
      ),
    );

    _active = fb;
    fb.show(context).then((_) => _active = null);
  }
}
