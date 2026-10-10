import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Glossy pill button with a solid "3D" bottom edge that sinks when pressed.
class ChunkyButton extends StatefulWidget {
  const ChunkyButton({
    super.key,
    required this.onPressed,
    required this.child,
    required this.topColor,
    required this.bottomColor,
    required this.edgeColor,
    required this.width,
    required this.height,
  });

  final VoidCallback onPressed;
  final Widget child;
  final Color topColor;
  final Color bottomColor;
  final Color edgeColor;
  final double width;
  final double height;

  @override
  State<ChunkyButton> createState() => _ChunkyButtonState();
}

class _ChunkyButtonState extends State<ChunkyButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final depth = widget.height * 0.1;
    final radius = BorderRadius.circular(widget.height / 2);

    return Semantics(
      button: true,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) {
          setState(() => _pressed = false);
          HapticFeedback.lightImpact();
          widget.onPressed();
        },
        child: SizedBox(
          width: widget.width,
          height: widget.height + depth,
          child: Stack(
            children: [
              // Bottom edge.
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: widget.height,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: widget.edgeColor,
                    borderRadius: radius,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(50),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
              // Face.
              AnimatedPositioned(
                duration: const Duration(milliseconds: 70),
                left: 0,
                right: 0,
                top: _pressed ? depth : 0,
                height: widget.height,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: radius,
                    border: Border.all(color: Colors.white.withAlpha(140), width: 2),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [widget.topColor, widget.bottomColor],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Gloss highlight.
                      Positioned(
                        left: widget.height * 0.35,
                        right: widget.height * 0.35,
                        top: widget.height * 0.08,
                        height: widget.height * 0.28,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(90),
                            borderRadius: BorderRadius.circular(widget.height),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: widget.height * 0.3),
                        child: Center(
                          child: FittedBox(fit: BoxFit.scaleDown, child: widget.child),
                        ),
                      ),
                    ],
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
