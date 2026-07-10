import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Animated circular risk-score gauge used across Link/Scam/File scanners.
class RiskGauge extends StatelessWidget {
  const RiskGauge({super.key, required this.score, this.size = 140});
  final int score;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.riskColor(score);
    return SizedBox(
      width: size,
      height: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: score / 100),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOutCubic,
        builder: (context, value, _) {
          return Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  value: value,
                  strokeWidth: 10,
                  backgroundColor: AppColors.border,
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(value * 100).round()}',
                    style: TextStyle(fontSize: size * 0.26, fontWeight: FontWeight.w800, color: color),
                  ),
                  const Text('/ 100', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class VerdictBadge extends StatelessWidget {
  const VerdictBadge({super.key, required this.verdict});
  final String verdict; // safe | suspicious | dangerous

  @override
  Widget build(BuildContext context) {
    final color = switch (verdict) {
      'dangerous' => AppColors.danger,
      'suspicious' => AppColors.warning,
      _ => AppColors.safe,
    };
    final icon = switch (verdict) {
      'dangerous' => Icons.dangerous_rounded,
      'suspicious' => Icons.warning_amber_rounded,
      _ => Icons.verified_user_rounded,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(verdict.toUpperCase(), style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12)),
        ],
      ),
    );
  }
}
