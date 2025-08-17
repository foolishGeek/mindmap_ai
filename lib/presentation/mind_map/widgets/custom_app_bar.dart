import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mindmap_ai/utility/constant.dart';
import 'package:mindmap_ai/utility/styles.dart';

class MindMapAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MindMapAppBar({
    super.key,
    this.onBack,
    this.onSave,
    this.onFullscreen,
    this.onMore,
  });

  final VoidCallback? onBack;
  final VoidCallback? onSave;
  final VoidCallback? onFullscreen;
  final VoidCallback? onMore;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 8);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: preferredSize.height,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _CircleIconButton(
                  icon: SvgPicture.asset(
                    ImageAssets.chevronRight,
                    height: 14,
                    fit: BoxFit.contain,
                  ),
                  onTap: onBack,
                ),
                Row(
                  children: [
                    LightPillButton(
                      onTap: onSave,
                      child: Row(
                        children: [
                          SvgPicture.asset(ImageAssets.tick,
                              height: 16, width: 16, fit: BoxFit.contain),
                          const SizedBox(
                            width: 4,
                          ),
                          const Text(
                            'Save',
                            style: Styles.kNodeFont,
                          )
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    _CircleIconButton(
                      icon: SvgPicture.asset(
                        ImageAssets.twoArrow,
                        height: 18,
                        width: 18,
                        fit: BoxFit.contain,
                      ),
                      onTap: onFullscreen,
                    ),
                    const SizedBox(width: 14),
                    _CircleIconButton(
                      icon: SvgPicture.asset(
                        ImageAssets.threeDots,
                        height: 18,
                        width: 18,
                        fit: BoxFit.contain,
                      ),
                      onTap: onMore,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, this.onTap});

  final Widget icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: ColorConstants.iconBgColor,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: icon,
        ),
      ),
    );
  }
}

class LightPillButton extends StatelessWidget {
  const LightPillButton({
    super.key,
    required this.child,
    this.onTap,
    this.horizontalPadding = 12.0,
    this.background = const Color(0xFF1E1F22),
    this.borderColor = const Color(0xFF121315),
    this.textColor = Colors.white,
  });

  final Widget child;
  final VoidCallback? onTap;

  final double horizontalPadding;

  final Color background;
  final Color borderColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(18);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: r,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: r,
            color: background,
            border: Border.all(color: borderColor, width: 1),
            // single, light drop shadow (no grey rim)
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000), // 10% black
                blurRadius: 14,
                spreadRadius: -2,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints.tightFor(height: 36),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Center(
                // child is always centered
                child: IconTheme(
                  data: IconThemeData(color: textColor, size: 18),
                  child: DefaultTextStyle.merge(
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1.05,
                    ),
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
