import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mindmap_ai/utility/constant.dart';

Future<String?> showNodeContextMenu(
  BuildContext context, {
  required Offset global,
}) {
  final pos = RelativeRect.fromLTRB(
      global.dx + 0, global.dy + 30, global.dx + 20, global.dy - 20);

  return showMenu<String>(
    context: context,
    position: pos,
    color: Colors.white,
    clipBehavior: Clip.antiAlias,
    constraints: const BoxConstraints(minWidth: 200),
    shape: RoundedRectangleBorder(
      side: BorderSide(width: 1, color: Colors.white.withOpacity(0.12)),
      // #0000001F
      borderRadius: BorderRadius.circular(12),
    ),
    items: [
      PopupMenuItem<String>(
        height: 28,
        value: 'add',
        padding: EdgeInsets.zero,
        child: _MenuTile(
          icon: SvgPicture.asset(
            ImageAssets.node, // ← your asset name
            width: 28,
            height: 28,
            colorFilter:
                const ColorFilter.mode(Colors.black87, BlendMode.srcIn),
          ),
          label: 'Add a Node',
        ),
      ),
      PopupMenuItem<String>(
        height: 28,
        value: 'delete',
        padding: EdgeInsets.zero,
        child: _MenuTile(
          icon: SvgPicture.asset(
            ImageAssets.trash,
            width: 20,
            height: 20,
            colorFilter:
                const ColorFilter.mode(Colors.black87, BlendMode.srcIn),
          ),
          label: 'Delete Node',
        ),
      ),
    ],
  );
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.label,
  });

  final Widget icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      highlightColor: const Color(0x0F000000),
      splashColor: const Color(0x14000000),
      child: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 8, left: 18, right: 36),
        child: Row(
          children: [
            // Left icon
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: icon,
              ),
            ),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13, // big, like the mock
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
