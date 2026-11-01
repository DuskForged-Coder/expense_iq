import 'dart:ui';

import 'package:flutter/material.dart';

class GradientShell extends StatelessWidget {
  const GradientShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.dark
        ? const <Color>[Color(0xFF0E1715), Color(0xFF102C2D), Color(0xFF261F3A)]
        : const <Color>[Color(0xFFF7FFFC), Color(0xFFE7F4FF), Color(0xFFFFF3DF)];
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: child,
    );
  }
}

class GlassCard extends StatelessWidget {
  const GlassCard({
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.margin,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: padding,
            decoration: BoxDecoration(
              color: (isDark ? Colors.white : Colors.white)
                  .withValues(alpha: isDark ? 0.08 : 0.58),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: isDark ? 0.12 : 0.72),
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.26 : 0.08),
                  blurRadius: 28,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class MetricTile extends StatelessWidget {
  const MetricTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    super.key,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.14),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 16),
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 4),
          FittedBox(
            child: Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
