import 'dart:math';

enum PasswordStrength { veryWeak, weak, fair, strong, veryStrong }

class PasswordAnalysis {
  final PasswordStrength strength;
  final int score; // 0-100
  final double estimatedCrackTimeSeconds;
  final List<String> issues;
  final List<String> suggestions;

  PasswordAnalysis({
    required this.strength,
    required this.score,
    required this.estimatedCrackTimeSeconds,
    required this.issues,
    required this.suggestions,
  });

  String get crackTimeHuman {
    final s = estimatedCrackTimeSeconds;
    if (s < 1) return '< 1 second';
    if (s < 60) return '${s.toStringAsFixed(0)} seconds';
    if (s < 3600) return '${(s / 60).toStringAsFixed(0)} minutes';
    if (s < 86400) return '${(s / 3600).toStringAsFixed(0)} hours';
    if (s < 31536000) return '${(s / 86400).toStringAsFixed(0)} days';
    final years = s / 31536000;
    if (years > 1e6) return 'millions of years';
    return '${years.toStringAsFixed(0)} years';
  }
}

/// 100% on-device password strength estimation. No network calls.
/// Approximates entropy-based estimation (similar spirit to zxcvbn) using
/// character-class diversity, length, common patterns, and dictionary checks
/// against a small embedded common-password list.
class PasswordCheckerService {
  static const List<String> _commonPasswords = [
    'password', '123456', '123456789', 'qwerty', 'abc123', 'letmein',
    'monkey', 'football', 'iloveyou', 'admin', 'welcome', 'password1',
    '111111', '123123', 'dragon', 'master', 'login', 'princess',
  ];

  PasswordAnalysis analyze(String password) {
    final issues = <String>[];
    final suggestions = <String>[];

    if (password.isEmpty) {
      return PasswordAnalysis(
        strength: PasswordStrength.veryWeak,
        score: 0,
        estimatedCrackTimeSeconds: 0,
        issues: ['Password is empty'],
        suggestions: ['Enter a password to analyze'],
      );
    }

    final lower = password.toLowerCase();
    final length = password.length;

    final hasLower = RegExp(r'[a-z]').hasMatch(password);
    final hasUpper = RegExp(r'[A-Z]').hasMatch(password);
    final hasDigit = RegExp(r'[0-9]').hasMatch(password);
    final hasSymbol = RegExp(r'[^a-zA-Z0-9]').hasMatch(password);

    int poolSize = 0;
    if (hasLower) poolSize += 26;
    if (hasUpper) poolSize += 26;
    if (hasDigit) poolSize += 10;
    if (hasSymbol) poolSize += 32;
    poolSize = poolSize == 0 ? 1 : poolSize;

    // Shannon-style entropy estimate
    double entropy = length * (log(poolSize) / log(2));

    // Penalize common passwords / dictionary words heavily
    final isCommon = _commonPasswords.any((c) => lower.contains(c));
    if (isCommon) {
      entropy *= 0.15;
      issues.add('Contains a very common password pattern');
      suggestions.add('Avoid common words/passwords like "password" or "123456"');
    }

    // Penalize repeated characters (aaaa, 1111)
    if (RegExp(r'(.)\1{2,}').hasMatch(password)) {
      entropy *= 0.7;
      issues.add('Contains repeated characters');
      suggestions.add('Avoid repeating the same character multiple times');
    }

    // Penalize sequential patterns (abcd, 1234, qwerty row)
    if (_hasSequentialPattern(lower)) {
      entropy *= 0.7;
      issues.add('Contains a sequential pattern (e.g. 1234, abcd)');
      suggestions.add('Avoid keyboard or numeric sequences');
    }

    if (length < 8) {
      issues.add('Too short (fewer than 8 characters)');
      suggestions.add('Use at least 12–16 characters');
    }
    if (!hasUpper) suggestions.add('Add uppercase letters');
    if (!hasLower) suggestions.add('Add lowercase letters');
    if (!hasDigit) suggestions.add('Add numbers');
    if (!hasSymbol) suggestions.add('Add symbols (e.g. ! @ # \$ %)');

    // Map entropy bits -> 0..100 score (rough calibration)
    final score = entropy.clamp(0, 128) / 128 * 100;

    final strength = _strengthFromScore(score);
    final crackSeconds = _estimateCrackSeconds(entropy);

    if (suggestions.isEmpty) {
      suggestions.add('Great password! Consider a unique password per account via a password manager.');
    }

    return PasswordAnalysis(
      strength: strength,
      score: score.round(),
      estimatedCrackTimeSeconds: crackSeconds,
      issues: issues,
      suggestions: suggestions,
    );
  }

  bool _hasSequentialPattern(String s) {
    const sequences = ['0123456789', 'abcdefghijklmnopqrstuvwxyz', 'qwertyuiop', 'asdfghjkl', 'zxcvbnm'];
    for (final seq in sequences) {
      for (int i = 0; i <= seq.length - 4; i++) {
        final chunk = seq.substring(i, i + 4);
        if (s.contains(chunk)) return true;
      }
    }
    return false;
  }

  PasswordStrength _strengthFromScore(double score) {
    if (score < 20) return PasswordStrength.veryWeak;
    if (score < 40) return PasswordStrength.weak;
    if (score < 60) return PasswordStrength.fair;
    if (score < 80) return PasswordStrength.strong;
    return PasswordStrength.veryStrong;
  }

  double _estimateCrackSeconds(double entropyBits) {
    // Assume 10 billion guesses/sec (offline GPU attack, hashed but weakly).
    const guessesPerSecond = 1e10;
    final combinations = pow(2, entropyBits);
    return combinations / guessesPerSecond;
  }

  /// Generates a strong random passphrase locally (device CSPRNG).
  String generateStrongPassword({int length = 16}) {
    const upper = 'ABCDEFGHJKLMNPQRSTUVWXYZ';
    const lower = 'abcdefghijkmnpqrstuvwxyz';
    const digits = '23456789';
    const symbols = '!@#\$%^&*()-_=+?';
    const all = upper + lower + digits + symbols;
    final rand = Random.secure();

    final chars = <String>[
      upper[rand.nextInt(upper.length)],
      lower[rand.nextInt(lower.length)],
      digits[rand.nextInt(digits.length)],
      symbols[rand.nextInt(symbols.length)],
    ];
    for (int i = chars.length; i < length; i++) {
      chars.add(all[rand.nextInt(all.length)]);
    }
    chars.shuffle(rand);
    return chars.join();
  }
}
