import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';
import '../shared/risk_gauge.dart';
import '../../data/services/file_scanner_service.dart';

class FileScannerScreen extends ConsumerStatefulWidget {
  const FileScannerScreen({super.key});
  @override
  ConsumerState<FileScannerScreen> createState() => _FileScannerScreenState();
}

class _FileScannerScreenState extends ConsumerState<FileScannerScreen> {
  FileScanResult? _result;
  String? _fileName;
  bool _loading = false;

  Future<void> _pickAndScan() async {
    final picked = await FilePicker.platform.pickFiles(withData: true);
    if (picked == null || picked.files.isEmpty) return;
    final file = picked.files.first;
    setState(() {
      _loading = true;
      _fileName = file.name;
    });

    final Uint8List bytes = file.bytes ?? Uint8List(0);
    final header = bytes.length > 512 ? bytes.sublist(0, 512) : bytes;

    final result = await ref.read(fileScannerProvider).analyze(
          fileName: file.name,
          fileSizeBytes: file.size,
          headerBytes: header,
        );

    setState(() {
      _result = result;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final r = _result;
    return Scaffold(
      appBar: AppBar(title: const Text('File Scanner')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Text(
                  'Files are analyzed by characteristics (extension, size, header signature) locally. '
                  'Only a SHA-256 hash may be checked against threat intel — never your raw file content.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loading ? null : _pickAndScan,
                icon: const Icon(Icons.upload_file_rounded),
                label: const Text('Choose File to Scan'),
              ),
              const SizedBox(height: 28),
              if (_loading) const Center(child: CircularProgressIndicator()),
              if (r != null) ...[
                Text(_fileName ?? '', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                Center(child: RiskGauge(score: r.riskScore)),
                const SizedBox(height: 12),
                Center(child: VerdictBadge(verdict: r.verdict)),
                const SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Safety Report', style: TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        ...r.findings.map((f) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text('• $f', style: const TextStyle(color: AppColors.textSecondary)),
                            )),
                        const SizedBox(height: 12),
                        SelectableText('SHA-256: ${r.sha256}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      ],
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
}
