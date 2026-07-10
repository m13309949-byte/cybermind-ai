import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';
import '../shared/risk_gauge.dart';
import '../../data/services/scam_heuristics_service.dart';

class ScamDetectorScreen extends ConsumerStatefulWidget {
  const ScamDetectorScreen({super.key});
  @override
  ConsumerState<ScamDetectorScreen> createState() => _ScamDetectorScreenState();
}

class _ScamDetectorScreenState extends ConsumerState<ScamDetectorScreen> {
  final _controller = TextEditingController();
  ScamAnalysisResult? _result;
  String? _aiExplanation;
  bool _loading = false;

  Future<void> _analyze() async {
    final text = _controller.text;
    if (text.trim().isEmpty) return;
    final heuristics = ref.read(scamHeuristicsProvider).analyze(text);
    setState(() {
      _result = heuristics;
      _loading = true;
      _aiExplanation = null;
    });
    try {
      final auth = ref.read(authRepositoryProvider);
      final token = await auth.getIdToken();
      if (token != null) {
        final explanation = await ref.read(aiServiceProvider).analyzeScamMessage(message: text, userIdToken: token);
        setState(() => _aiExplanation = explanation);
      }
    } catch (_) {
      // Local heuristic result still stands even if AI enrichment fails.
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = _result;
    return Scaffold(
      appBar: AppBar(title: const Text('Scam Message Detector')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _controller,
                maxLines: 6,
                decoration: const InputDecoration(
                  hintText: 'Paste the message (SMS, WhatsApp, Email, Telegram)...',
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loading ? null : _analyze,
                child: const Text('Analyze Message'),
              ),
              const SizedBox(height: 28),
              if (r != null) ...[
                Center(child: RiskGauge(score: r.score)),
                const SizedBox(height: 12),
                Center(child: VerdictBadge(verdict: r.verdict)),
                const SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Warning Signs', style: TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        ...r.warningSigns.map((w) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.warning_amber_rounded, size: 16, color: AppColors.warning),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(w, style: const TextStyle(color: AppColors.textSecondary))),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
              ],
              if (_aiExplanation != null) ...[
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(_aiExplanation!, style: const TextStyle(color: AppColors.textSecondary, height: 1.5)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
