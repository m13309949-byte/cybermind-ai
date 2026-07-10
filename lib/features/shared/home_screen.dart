import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tiles = [
      _Tile('Link Scanner', Icons.link_rounded, AppColors.neonCyan, '/link-scanner'),
      _Tile('Scam Detector', Icons.report_gmailerrorred_rounded, AppColors.neonPink, '/scam-detector'),
      _Tile('Password Checker', Icons.password_rounded, AppColors.safe, '/password-checker'),
      _Tile('QR Scanner', Icons.qr_code_scanner_rounded, AppColors.neonViolet, '/qr-scanner'),
      _Tile('File Scanner', Icons.folder_zip_rounded, AppColors.warning, '/file-scanner'),
      _Tile('Security News', Icons.newspaper_rounded, AppColors.neonCyan, '/news'),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('CyberMind AI')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppColors.heroGradient,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.shield_moon_rounded, color: Colors.black, size: 36),
                  const SizedBox(height: 12),
                  Text('Stay ahead of threats',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.black, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  const Text('Your AI cybersecurity companion', style: TextStyle(color: Colors.black87)),
                ],
              ),
            ).animate().fadeIn().slideY(begin: 0.1, end: 0),
            const SizedBox(height: 24),
            GridView.count(
              crossAxisCount: MediaQuery.of(context).size.width > 700 ? 3 : 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.15,
              children: [
                for (int i = 0; i < tiles.length; i++)
                  _TileWidget(tiles[i]).animate().fadeIn(delay: (80 * i).ms).slideY(begin: 0.08, end: 0),
              ],
            ),
            const SizedBox(height: 24),
            Card(
              child: ListTile(
                onTap: () => context.push('/chat'),
                leading: const CircleAvatar(
                  backgroundColor: AppColors.neonViolet,
                  child: Icon(Icons.auto_awesome, color: Colors.white),
                ),
                title: const Text('Ask the AI Security Assistant'),
                subtitle: const Text('Explains hacks, phishing, malware & ransomware'),
                trailing: const Icon(Icons.chevron_right_rounded),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tile {
  final String label;
  final IconData icon;
  final Color color;
  final String route;
  _Tile(this.label, this.icon, this.color, this.route);
}

class _TileWidget extends StatelessWidget {
  const _TileWidget(this.tile);
  final _Tile tile;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => context.push(tile.route),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(tile.icon, color: tile.color, size: 30),
              const SizedBox(height: 12),
              Text(tile.label, style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}
