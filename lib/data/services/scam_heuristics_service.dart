class ScamAnalysisResult {
  final int score; // 0-100 likelihood of scam
  final List<String> warningSigns;
  final String verdict;

  ScamAnalysisResult({required this.score, required this.warningSigns, required this.verdict});
}

/// On-device pattern matching for common scam/phishing tactics. Combined
/// with AiService.analyzeScamMessage for a natural-language explanation.
class ScamHeuristicsService {
  static const _urgencyPhrases = [
    'act now', 'urgent', 'immediately', 'account suspended', 'verify your account',
    'within 24 hours', 'limited time', 'act fast', 'final notice',
  ];
  static const _moneyPhrases = [
    'gift card', 'wire transfer', 'send money', 'bitcoin', 'crypto payment',
    'processing fee', 'claim your prize', 'you have won', 'lottery',
  ];
  static const _credentialPhrases = [
    'confirm your password', 'enter your pin', 'ssn', 'social security number',
    'verify your identity', 'update your billing', 'click the link below',
  ];
  static const _authorityImpersonation = [
    'irs', 'tax refund', 'bank security', 'apple support', 'microsoft support',
    'amazon security', 'government grant', 'court notice', 'arrest warrant',
  ];

  ScamAnalysisResult analyze(String message) {
    final lower = message.toLowerCase();
    final warnings = <String>[];
    int score = 5;

    void checkGroup(List<String> phrases, String label, int weight) {
      final hits = phrases.where((p) => lower.contains(p)).toList();
      if (hits.isNotEmpty) {
        score += weight;
        warnings.add('$label detected (e.g. "${hits.first}")');
      }
    }

    checkGroup(_urgencyPhrases, 'Urgency / pressure tactic', 20);
    checkGroup(_moneyPhrases, 'Suspicious payment or prize request', 25);
    checkGroup(_credentialPhrases, 'Credential harvesting request', 25);
    checkGroup(_authorityImpersonation, 'Authority impersonation', 20);

    // Suspicious links
    final urlMatches = RegExp(r'https?://[^\s]+').allMatches(message);
    if (urlMatches.isNotEmpty) {
      score += 10;
      warnings.add('Contains a link — verify the destination before clicking');
    }

    // Generic greeting instead of a name (mass phishing indicator)
    if (RegExp(r'\b(dear customer|dear user|dear client|valued customer)\b').hasMatch(lower)) {
      score += 10;
      warnings.add('Generic greeting instead of your real name');
    }

    // Poor grammar heuristic: excessive punctuation/caps
    if (RegExp(r'[A-Z]{6,}').hasMatch(message) || '!!!'.allMatches(message).isNotEmpty) {
      score += 5;
      warnings.add('Excessive capitalization or exclamation marks');
    }

    score = score.clamp(0, 100);
    final verdict = score >= 70 ? 'dangerous' : (score >= 40 ? 'suspicious' : 'safe');
    if (warnings.isEmpty) warnings.add('No common scam patterns detected — still verify the sender.');

    return ScamAnalysisResult(score: score, warningSigns: warnings, verdict: verdict);
  }
}
