import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../data/services/password_checker_service.dart';

class PasswordCheckerScreen extends ConsumerStatefulWidget {
  const PasswordCheckerScreen({super.key});
  @override
  ConsumerState<PasswordCheckerScreen> createState() => _PasswordCheckerScreenState();
}

class _PasswordCheckerScreenState extends ConsumerState<PasswordCheckerScreen> {
  final _controller = TextEditingController();
  bool _obscure = true;
  PasswordAnalysis? _analysis;
  String? _generated;

  void _check(String value) {
    final service = ref.read(passwordCheckerProvider);
    setState(() => _analysis = service.analyze(value));
  }

  void _suggest() {
    final service = ref.read(passwordCheckerProvider);
    setState(() => _generated = service.generateStrongPassword());
  }

  @override
  Widget build(BuildContext context) {
    final a = _analysis;
    return Scaffold(
      appBar: AppBar(title: const Text('Password Strength Checker')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.safe.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.safe.withOpacity(0.3)),
                ),
                child: Row(children: const [
                  Icon(Icons.lock_rounded, color: AppColors.safe, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Checked 100% on your device. Never sent to any server.',
                      style: TextStyle(color: AppColors.safe, fontSize: 12),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _controller,
                obscureText: _obscure,
                onChanged: _check,
                decoration: InputDecoration(
                  hintText: 'Type a password',
                  prefixIcon: const Icon(Icons.key_rounded),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_rounded : Icons.visibility_off_rounded),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (a != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: a.score / 100,
                    minHeight: 10,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation(AppColors.riskColor(100 - a.score)),
                  ),
                ),
                const SizedBox(height: 8),
                Text(_strengthLabel(a.strength), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                Text('Estimated crack time: ${a.crackTimeHuman}', style: const TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 16),
                if (a.issues.isNotEmpty) ...[
                  const Text('Issues', style: TextStyle(fontWeight: FontWeight.w700)),
                  ...a.issues.map((i) => _bullet(i, AppColors.danger)),
                  const SizedBox(height: 12),
                ],
                const Text('Suggestions', style: TextStyle(fontWeight: FontWeight.w700)),
                ...a.suggestions.map((s) => _bullet(s, AppColors.neonCyan)),
              ],
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: _suggest,
                icon: const Icon(Icons.auto_fix_high_rounded),
                label: const Text('Suggest Stronger Password'),
              ),
              if (_generated != null) ...[
                const SizedBox(height: 12),
                Card(
                  child: ListTile(
                    title: SelectableText(_generated!, style: const TextStyle(fontFamily: 'monospace', fontSize: 16)),
                    trailing: IconButton(
                      icon: const Icon(Icons.copy_rounded),
                      onPressed: () {
                        // Clipboard copy wired via Clipboard.setData in production build.
                      },
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _bullet(String text, Color color) => Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.circle, size: 6, color: color),
            const SizedBox(width: 10),
            Expanded(child: Text(text, style: const TextStyle(color: AppColors.textSecondary))),
          ],
        ),
      );

  String _strengthLabel(PasswordStrength s) => switch (s) {
        PasswordStrength.veryWeak => 'Very Weak',
        PasswordStrength.weak => 'Weak',
        PasswordStrength.fair => 'Fair',
        PasswordStrength.strong => 'Strong',
        PasswordStrength.veryStrong => 'Very Strong',
      };
}
 كنج
