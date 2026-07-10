import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../shared/risk_gauge.dart';
import 'link_scanner_viewmodel.dart';

class LinkScannerScreen extends ConsumerStatefulWidget {
  const LinkScannerScreen({super.key});
  @override
  ConsumerState<LinkScannerScreen> createState() => _LinkScannerScreenState();
}

class _LinkScannerScreenState extends ConsumerState<LinkScannerScreen> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(linkScanViewModelProvider);
    final vm = ref.read(linkScanViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Link Scanner')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.link_rounded, size: 48, color: AppColors.neonCyan)
                  .animate()
                  .fadeIn()
                  .scale(begin: const Offset(0.8, 0.8)),
              const SizedBox(height: 16),
              TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'Paste a URL to analyze, e.g. https://...',
                  prefixIcon: Icon(Icons.paste_rounded),
                ),
                onSubmitted: vm.scan,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: state.isLoading ? null : () => vm.scan(_controller.text),
                child: state.isLoading
                    ? const SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                      )
                    : const Text('Analyze Link'),
              ),
              const SizedBox(height: 32),
              if (state.heuristicResult != null) ...[
                Center(child: RiskGauge(score: state.heuristicResult!.score)).animate().fadeIn(),
                const SizedBox(height: 12),
                Center(child: VerdictBadge(verdict: state.heuristicResult!.verdict)),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Why', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                        const SizedBox(height: 8),
                        ...state.heuristicResult!.reasons.map(
                          (r) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.circle, size: 6, color: AppColors.neonCyan),
                                const SizedBox(width: 10),
                                Expanded(child: Text(r, style: const TextStyle(color: AppColors.textSecondary))),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              if (state.isLoading && state.aiExplanation == null) ...[
                const SizedBox(height: 20),
                const Center(child: Text('Getting AI deep-dive explanation...', style: TextStyle(color: AppColors.textSecondary))),
              ],
              if (state.aiExplanation != null) ...[
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: const [
                          Icon(Icons.auto_awesome, size: 18, color: AppColors.neonViolet),
                          SizedBox(width: 8),
                          Text('AI Deep Dive', style: TextStyle(fontWeight: FontWeight.w700)),
                        ]),
                        const SizedBox(height: 8),
                        Text(state.aiExplanation!, style: const TextStyle(color: AppColors.textSecondary, height: 1.5)),
                      ],
                    ),
                  ),
                ).animate().fadeIn(),
              ],
              if (state.error != null) ...[
                const SizedBox(height: 16),
                Text(state.error!, style: const TextStyle(color: AppColors.danger)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
