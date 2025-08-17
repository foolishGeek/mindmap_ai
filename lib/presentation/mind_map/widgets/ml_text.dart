import 'dart:math' as math;
import 'package:flutter/material.dart';

class AIPromptBar extends StatefulWidget {
  const AIPromptBar({
    super.key,
    required this.controller,
    required this.onSubmit,
    this.hintText = 'Ask anything…',
    this.isLoading = false,
    this.enabled = true,
    this.maxWidth = 280,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSubmit;
  final String hintText;
  final bool isLoading;
  final bool enabled;
  final double maxWidth;

  @override
  State<AIPromptBar> createState() => _AIPromptBarState();
}

class _AIPromptBarState extends State<AIPromptBar>
    with TickerProviderStateMixin {
  static const _barHeight = 40.0;
  static const _radius = 26.0;
  static const _stroke = 2.0;

  static const _rainbow = <Color>[
    Color(0xFFFFE58A), // soft yellow
    Color(0xFFFFB59D), // peach
    Color(0xFFF6A9FF), // light magenta
    Color(0xFFBFC8FF), // periwinkle
    Color(0xFFADE8FF), // sky cyan
    Color(0xFFBDF6CF), // mint
    Color(0xFFFFE58A), // loop
  ];

  late final AnimationController _borderCtrl;
  late final AnimationController _sparkleCtrl;

  @override
  void initState() {
    super.initState();
    _borderCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _sparkleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    if (!widget.isLoading) _sparkleCtrl.stop();
  }

  @override
  void didUpdateWidget(covariant AIPromptBar old) {
    super.didUpdateWidget(old);
    if (widget.isLoading && !_sparkleCtrl.isAnimating) {
      _sparkleCtrl.repeat();
    } else if (!widget.isLoading && _sparkleCtrl.isAnimating) {
      _sparkleCtrl.stop();
    }
  }

  @override
  void dispose() {
    _borderCtrl.dispose();
    _sparkleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context)
        .textTheme
        .titleMedium
        ?.copyWith(color: const Color(0xFF202124), fontWeight: FontWeight.w600);

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: widget.maxWidth),
        child: SizedBox(
          height: _barHeight + 18,
          child: Stack(
            children: [
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _borderCtrl,
                  builder: (context, _) => CustomPaint(
                    painter: _AnimatedRainbowBorderPainter(
                      t: _borderCtrl.value,
                      radius: _radius,
                      stroke: _stroke,
                      colors: _rainbow,
                      glowBlur: 18,
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(_stroke),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(_radius - _stroke),
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFFFFFFF),
                            Color(0xFFF8F2FF),
                          ],
                        ),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: widget.controller,
                              enabled: widget.enabled && !widget.isLoading,
                              textInputAction: TextInputAction.send,
                              onSubmitted: (v) => widget.onSubmit(v.trim()),
                              style: textStyle,
                              cursorColor: const Color(0xFF202124),
                              decoration: InputDecoration(
                                isDense: true,
                                border: InputBorder.none,
                                hintText: widget.hintText,
                                hintStyle: textStyle?.copyWith(
                                  color: const Color(0x99202124),
                                  fontWeight: FontWeight.w500,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 0,
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _SparkleButton(
                            progress: _sparkleCtrl,
                            isLoading: widget.isLoading,
                            onTap: widget.isLoading
                                ? null
                                : () => widget
                                    .onSubmit(widget.controller.text.trim()),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedRainbowBorderPainter extends CustomPainter {
  _AnimatedRainbowBorderPainter({
    required this.t,
    required this.radius,
    required this.stroke,
    required this.colors,
    this.glowBlur = 16,
  });

  final double t;
  final double radius;
  final double stroke;
  final List<Color> colors;
  final double glowBlur;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );

    final shader = SweepGradient(
      colors: colors,
      transform: GradientRotation(t * 2 * math.pi),
    ).createShader(Offset.zero & size);

    // Outer soft glow
    final glow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke * 2.2
      ..shader = shader
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowBlur);
    canvas.drawRRect(rrect, glow);

    // Crisp border
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..shader = shader;
    canvas.drawRRect(rrect, line);
  }

  @override
  bool shouldRepaint(covariant _AnimatedRainbowBorderPainter old) =>
      old.t != t ||
      old.radius != radius ||
      old.stroke != stroke ||
      old.glowBlur != glowBlur ||
      old.colors != colors;
}

/// Pastel gradient circle with twinkling white stars.
class _SparkleButton extends StatelessWidget {
  const _SparkleButton({
    required this.progress,
    required this.isLoading,
    required this.onTap,
  });

  final Animation<double> progress;
  final bool isLoading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, _) {
        final t = progress.value;
        final rot = isLoading ? t * 2 * math.pi : 0.0;
        final pulseBig =
            isLoading ? (0.92 + 0.14 * math.sin(t * 2 * math.pi)) : 1.0;
        final pulseSm =
            isLoading ? (0.86 + 0.18 * math.cos(t * 2 * math.pi)) : 1.0;
        final alpha =
            isLoading ? (0.80 + 0.20 * math.sin(t * 2 * math.pi)) : 1.0;

        final sweep = SweepGradient(
          colors: const [
            Color(0xFF8AB6FF),
            Color(0xFFFFA6EE),
            Color(0xFF7CD8FF),
            Color(0xFF8AB6FF),
          ],
          transform: GradientRotation(rot),
        );

        return GestureDetector(
          onTap: onTap,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Opacity(
                opacity: isLoading ? 0.45 : 0.28,
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: Color(0x668AB6FF),
                          blurRadius: 28,
                          spreadRadius: 2),
                      BoxShadow(
                          color: Color(0x66FFA6EE),
                          blurRadius: 28,
                          spreadRadius: 2),
                    ],
                  ),
                ),
              ),
              // rotating gradient puck
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: sweep,
                ),
              ),
              // stars
              SizedBox(
                width: 44,
                height: 44,
                child: CustomPaint(
                  painter: _StarsPainter(
                    bigScale: pulseBig,
                    smallScale: pulseSm,
                    alpha: alpha,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StarsPainter extends CustomPainter {
  _StarsPainter({
    required this.bigScale,
    required this.smallScale,
    required this.alpha,
  });

  final double bigScale;
  final double smallScale;
  final double alpha;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.56, size.height * 0.44);
    final small = center + const Offset(-12, 10);

    _drawSparkle(canvas, center, 8 * bigScale,
        color: Colors.white.withOpacity(alpha));
    _drawSparkle(canvas, small, 5.5 * smallScale,
        color: Colors.white.withOpacity(alpha * 0.9));
  }

  void _drawSparkle(Canvas c, Offset o, double r, {required Color color}) {
    final p = Paint()..color = color;
    final rectW = r * 2;
    final rectH = r * 0.38;
    final rr = RRect.fromRectAndRadius(
      Rect.fromCenter(center: o, width: rectW, height: rectH),
      Radius.circular(rectH / 2),
    );

    // 0° and 90°
    c.drawRRect(rr, p);
    c.save();
    c.translate(o.dx, o.dy);
    c.rotate(math.pi / 2);
    c.translate(-o.dx, -o.dy);
    c.drawRRect(rr, p);
    c.restore();

    // 45° and 135°
    c.save();
    c.translate(o.dx, o.dy);
    c.rotate(math.pi / 4);
    c.translate(-o.dx, -o.dy);
    c.drawRRect(rr, p);
    c.restore();

    c.save();
    c.translate(o.dx, o.dy);
    c.rotate(3 * math.pi / 4);
    c.translate(-o.dx, -o.dy);
    c.drawRRect(rr, p);
    c.restore();
  }

  @override
  bool shouldRepaint(covariant _StarsPainter old) =>
      old.bigScale != bigScale ||
      old.smallScale != smallScale ||
      old.alpha != alpha;
}
