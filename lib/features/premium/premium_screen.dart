import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Wire real purchases via `in_app_purchase` (App Store / Play Billing) or
/// RevenueCat, then flip `users/{uid}.premium = true` through a verified
/// server-side purchase-validation Cloud Function (never trust client-set
/// flags for entitlement).
class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final perks = [
      ('Unlimited AI scans', Icons.all_inclusive_rounded),
      ('Priority, faster analysis', Icons.speed_rounded),
      ('Deep security reports', Icons.analytics_rounded),
      ('Ad-free experience', Icons.block_rounded),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('CyberMind Premium')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(gradient: AppColors.heroGradient, borderRadius: BorderRadius.circular(24)),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.workspace_premium_rounded, color: Colors.black, size: 36),
                  SizedBox(height: 12),
                  Text('Unlock full protection', style: TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            for (final p in perks)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Icon(p.$2, color: AppColors.neonCyan),
                    const SizedBox(width: 12),
                    Text(p.$1, style: const TextStyle(fontSize: 15)),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text('\$4.99 / month', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    const Text('or \$39.99 / year (save 33%)', style: TextStyle(color: AppColors.textSecondary)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Hook in_app_purchase / RevenueCat purchase flow here.
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Connect in_app_purchase / RevenueCat to enable checkout.')),
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40),
                        child: Text('Subscribe'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
