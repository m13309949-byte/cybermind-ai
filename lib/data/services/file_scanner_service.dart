import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

class FileScanResult {
  final int riskScore;
  final List<String> findings;
  final String sha256;
  final String verdict;

  FileScanResult({
    required this.riskScore,
    required this.findings,
    required this.sha256,
    required this.verdict,
  });
}

/// Analyzes file characteristics locally: extension tricks, macro-enabled
/// Office formats, executable signatures, double extensions, and size
/// anomalies. Computes a SHA-256 hash (safe to send to a threat-intel API
/// like VirusTotal's hash-lookup endpoint — never the raw file — if you
/// wire that into the backend proxy).
class FileScannerService {
  static const _dangerousExtensions = [
    '.exe', '.scr', '.bat', '.cmd', '.msi', '.com', '.pif', '.vbs', '.js',
    '.jar', '.apk', '.ps1',
  ];
  static const _macroExtensions = ['.docm', '.xlsm', '.pptm'];

  Future<FileScanResult> analyze({
    required String fileName,
    required int fileSizeBytes,
    required Uint8List headerBytes, // first ~512 bytes for signature check
  }) async {
    final findings = <String>[];
    int score = 5;

    final lowerName = fileName.toLowerCase();
    final parts = lowerName.split('.');
    final ext = parts.length > 1 ? '.${parts.last}' : '';

    if (_dangerousExtensions.contains(ext)) {
      score += 40;
      findings.add('Executable/script file type ($ext) — high risk if from an unknown sender');
    }
    if (_macroExtensions.contains(ext)) {
      score += 25;
      findings.add('Macro-enabled Office file — macros can run malicious code');
    }

    // Double extension trick: invoice.pdf.exe
    if (parts.length > 2) {
      final secondToLast = '.${parts[parts.length - 2]}';
      const commonSafe = ['.pdf', '.doc', '.jpg', '.png', '.txt', '.xlsx'];
      if (commonSafe.contains(secondToLast) && _dangerousExtensions.contains(ext)) {
        score += 30;
        findings.add('Disguised double extension detected ("$secondToLast$ext") — classic malware trick');
      }
    }

    // Magic-byte signature checks (very small allow-list, extend as needed)
    final signature = _detectSignatureMismatch(ext, headerBytes);
    if (signature != null) {
      score += 20;
      findings.add(signature);
    }

    // Size anomaly: tiny "document" files can be droppers
    if (fileSizeBytes < 1024 && (ext == '.docx' || ext == '.pdf')) {
      score += 10;
      findings.add('Unusually small file size for its type');
    }

    final hash = sha256.convert(headerBytes).toString();

    score = score.clamp(0, 100);
    final verdict = score >= 70 ? 'dangerous' : (score >= 40 ? 'suspicious' : 'safe');
    if (findings.isEmpty) findings.add('No suspicious characteristics found in local analysis');

    return FileScanResult(riskScore: score, findings: findings, sha256: hash, verdict: verdict);
  }

  String? _detectSignatureMismatch(String ext, Uint8List header) {
    if (header.length < 4) return null;
    final isPE = header[0] == 0x4D && header[1] == 0x5A; // 'MZ' Windows exe header
    const textLikeExt = ['.txt', '.csv', '.json', '.pdf', '.docx', '.jpg', '.png'];
    if (isPE && textLikeExt.contains(ext)) {
      return 'File header signature indicates an executable disguised as a "$ext" file';
    }
    return null;
  }
}
