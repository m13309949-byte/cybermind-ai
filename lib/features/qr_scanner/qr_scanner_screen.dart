import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';
import '../shared/risk_gauge.dart';
import '../../data/services/link_heuristics_service.dart';

class QrScannerScreen extends ConsumerStatefulWidget {
  const QrScannerScreen({super.key});
  @override
  ConsumerState<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends ConsumerState<QrScannerScreen> {
  final _cameraController = MobileScannerController();
  LinkRiskResult? _result;
  String? _lastCode;
  bool _paused = false;

  void _onDetect(BarcodeCapture capture) {
    if (_paused) return;
    final code = capture.barcodes.firstOrNull?.rawValue;
    if (code == null || code == _lastCode) return;
    setState(() {
      _lastCode = code;
      _paused = true;
      _result = ref.read(linkHeuristicsProvider).analyze(code);
    });
  }

  void _reset() {
    setState(() {
      _result = null;
      _lastCode = null;
      _paused = false;
    });
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR Scanner')),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              fit: StackFit.expand,
              children: [
                MobileScanner(controller: _cameraController, onDetect: _onDetect),
                Center(
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.neonCyan, width: 2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _result == null
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 24),
                        child: Text('Point your camera at a QR code', style: TextStyle(color: AppColors.textSecondary)),
                      ),
                    )
                  : Column(
                      children: [
                        SelectableText(_lastCode ?? '', textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary)),
                        const SizedBox(height: 16),
                        RiskGauge(score: _result!.score, size: 110),
                        const SizedBox(height: 12),
                        VerdictBadge(verdict: _result!.verdict),
                        const SizedBox(height: 16),
                        ..._result!.reasons.map((r) => Text('• $r', style: const TextStyle(color: AppColors.textSecondary))),
                        const SizedBox(height: 16),
                        OutlinedButton(onPressed: _reset, child: const Text('Scan Another')),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

extension _FirstOrNull<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
