import 'package:flutter/material.dart';
import 'package:mindmap_ai/utility/constant.dart';

class HintPlusButton extends StatelessWidget {
  const HintPlusButton({
    super.key,
    required this.target,
    required this.onPressed,
  });

  final Offset target;
  final VoidCallback onPressed;

  static const double _tapDiameter = SizeConstants.hintPlusDiameter;
  static const double _outerDiameter = 32.0;
  static const double _innerDiameter = 16.0;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: target.dx - _tapDiameter / 2,
      top: target.dy - _tapDiameter / 2,
      width: _tapDiameter,
      height: _tapDiameter,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Center(
            child: Container(
              width: _outerDiameter,
              height: _outerDiameter,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0x08000000), // #00000008
                border: Border.all(
                  color: const Color(0x0D000000), // #0000000D
                  width: 0.5,
                ),
              ),
              child: Center(
                child: Container(
                  width: _innerDiameter,
                  height: _innerDiameter,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(
                      color: const Color(0xFF000000),
                      width: 1.2,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.add,
                      size: 10,
                      color: Color(0xFF000000),
                    ),
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
