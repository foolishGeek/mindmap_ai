import 'dart:ui';

abstract class INodeColorPalette {
  Color get bgColor;

  Color get textColor;
}

// Orange node colour
class OrangeNodeColor extends INodeColorPalette {
  @override
  Color get bgColor => const Color(0xFFFFF9F1);

  @override
  Color get textColor => const Color(0xFFFF9500);
}

// Green node color
class GreenNodeColor extends INodeColorPalette {
  @override
  Color get bgColor => const Color(0xFFECFFF1);

  @override
  Color get textColor => const Color(0xFF34C759);
}

// Purple node color
class PurpleNodeColor extends INodeColorPalette {
  @override
  Color get bgColor => const Color(0xFFF9EDFF);

  @override
  Color get textColor => const Color(0xFFAF52DE);
}

//Mint node color
class MintNodeColor extends INodeColorPalette {
  @override
  Color get bgColor => const Color(0xFFE1FAFF);

  @override
  Color get textColor => const Color(0xFF00C7BE);
}

class NodeColors {
  NodeColors._();

  static List<INodeColorPalette> presets = [
    OrangeNodeColor(),
    GreenNodeColor(),
    PurpleNodeColor(),
    MintNodeColor()
  ];
}
