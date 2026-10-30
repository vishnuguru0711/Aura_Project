import 'package:flutter/material.dart';
import '../main.dart';

class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 8),
    child: Text(text.toUpperCase(),
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
            letterSpacing: 1.2, color: AppTheme.textMuted)),
  );
}

class DarkCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? borderColor;
  final VoidCallback? onTap;
  const DarkCard({super.key, required this.child, this.padding, this.borderColor, this.onTap});

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding ?? const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor ?? AppTheme.border),
      ),
      child: child,
    );
    return onTap != null ? GestureDetector(onTap: onTap, child: card) : card;
  }
}

class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const StatusBadge({super.key, required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
        color: color, fontFamily: 'monospace')),
  );
}

class DirectionTag extends StatelessWidget {
  final String direction;
  const DirectionTag(this.direction, {super.key});
  Color get _color {
    if (direction == 'LEFT')  return AppTheme.blue;
    if (direction == 'RIGHT') return AppTheme.accent2;
    return AppTheme.accent;
  }
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: _color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: _color.withOpacity(0.3)),
    ),
    child: Text(direction, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
        color: _color, fontFamily: 'monospace')),
  );
}

class PulsingDot extends StatefulWidget {
  final Color color;
  final double size;
  const PulsingDot({super.key, required this.color, this.size = 8});
  @override
  State<PulsingDot> createState() => _PulsingDotState();
}
class _PulsingDotState extends State<PulsingDot> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
        ..repeat(reverse: true);
  late final Animation<double> _a =
      Tween<double>(begin: 0.3, end: 1.0).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _a,
    builder: (_, __) => Opacity(opacity: _a.value,
        child: Container(width: widget.size, height: widget.size,
            decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle))),
  );
}

class VoiceOrb extends StatefulWidget {
  final bool active;
  final VoidCallback? onTap;
  const VoiceOrb({super.key, this.active = false, this.onTap});
  @override State<VoiceOrb> createState() => _VoiceOrbState();
}
class _VoiceOrbState extends State<VoiceOrb> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 2800))
        ..repeat(reverse: true);
  late final Animation<double> _s =
      Tween<double>(begin: 1.0, end: 1.08).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _s,
    builder: (_, child) => Transform.scale(scale: _s.value, child: child),
    child: GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: 90, height: 90,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const RadialGradient(
            colors: [Color(0xFF1AF5A0), Color(0xFF00B87A), Color(0xFF006644)],
            center: Alignment(-0.3, -0.3),
          ),
          boxShadow: [BoxShadow(
            color: AppTheme.accent.withOpacity(widget.active ? 0.5 : 0.2),
            blurRadius: widget.active ? 36 : 16,
            spreadRadius: widget.active ? 8 : 2,
          )],
        ),
        child: const Icon(Icons.mic, color: Colors.black54, size: 36),
      ),
    ),
  );
}
