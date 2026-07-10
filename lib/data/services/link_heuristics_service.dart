class LinkRiskResult {
  final int score; // 0-100, higher = more dangerous
  final List<String> reasons;
  final String verdict; // safe / suspicious / dangerous

  LinkRiskResult({required this.score, required this.reasons, required this.verdict});
}

/// Fast, fully on-device heuristic pre-screen for URLs. This runs instantly
/// (no network) and is combined with the AI proxy's natural-language
/// explanation (see AiService.explainLinkRisk) for the full report.
///
/// NOTE: This is a heuristic signal, not a guarantee — always combine with
/// live threat-intel (e.g. Google Safe Browsing API via a server-side call)
/// in production. Hook that into the Cloud Function proxy alongside OpenAI.
class LinkHeuristicsService {
  static const _suspiciousTlds = ['.zip', '.mov', '.xyz', '.top', '.click', '.gq', '.tk', '.ml'];
  static const _shorteners = ['bit.ly', 'tinyurl.com', 't.co', 'goo.gl', 'is.gd', 'cutt.ly'];
  static const _brandKeywords = [
    'paypal', 'apple', 'google', 'microsoft', 'amazon', 'netflix', 'bank',
    'facebook', 'instagram', 'whatsapp', 'irs', 'gov',
  ];

  LinkRiskResult analyze(String rawUrl) {
    final reasons = <String>[];
    int score = 5; // baseline

    Uri? uri;
    try {
      uri = Uri.parse(rawUrl.trim());
    } catch (_) {
      return LinkRiskResult(score: 80, reasons: ['URL could not be parsed'], verdict: 'dangerous');
    }

    final host = uri.host.toLowerCase();
    if (host.isEmpty) {
      return LinkRiskResult(score: 70, reasons: ['No valid domain found'], verdict: 'dangerous');
    }

    if (uri.scheme == 'http') {
      score += 15;
      reasons.add('Uses unencrypted HTTP instead of HTTPS');
    }

    if (_shorteners.any((s) => host.contains(s))) {
      score += 20;
      reasons.add('Uses a URL shortener that hides the real destination');
    }

    if (_suspiciousTlds.any((tld) => host.endsWith(tld))) {
      score += 20;
      reasons.add('Uses a top-level domain frequently abused for scams');
    }

    // IP address as host instead of a domain name
    if (RegExp(r'^\d{1,3}(\.\d{1,3}){3}$').hasMatch(host)) {
      score += 25;
      reasons.add('Uses a raw IP address instead of a domain name');
    }

    // Excessive subdomains (common obfuscation: paypal.com.verify-login.xyz)
    final labels = host.split('.');
    if (labels.length > 4) {
      score += 15;
      reasons.add('Unusually many subdomains — possible obfuscation');
    }

    // Brand keyword present but domain isn't the real brand domain
    for (final brand in _brandKeywords) {
      if (host.contains(brand) && !_isOfficialDomain(host, brand)) {
        score += 25;
        reasons.add('Mentions "$brand" but is not the official domain (possible impersonation)');
        break;
      }
    }

    // Hyphen-heavy domains (typosquatting pattern)
    if ('-'.allMatches(host).length >= 2) {
      score += 10;
      reasons.add('Domain contains multiple hyphens, a common typosquatting pattern');
    }

    // Suspicious keywords in path/query
    final fullLower = rawUrl.toLowerCase();
    for (final kw in ['login', 'verify', 'update-payment', 'reset-password', 'confirm-account']) {
      if (fullLower.contains(kw)) {
        score += 5;
        reasons.add('URL path suggests a credential-harvesting page ("$kw")');
        break;
      }
    }

    score = score.clamp(0, 100);
    final verdict = score >= 70 ? 'dangerous' : (score >= 40 ? 'suspicious' : 'safe');
    if (reasons.isEmpty) reasons.add('No obvious red flags found in structural analysis');

    return LinkRiskResult(score: score, reasons: reasons, verdict: verdict);
  }

  bool _isOfficialDomain(String host, String brand) {
    final officialMap = {
      'paypal': 'paypal.com',
      'apple': 'apple.com',
      'google': 'google.com',
      'microsoft': 'microsoft.com',
      'amazon': 'amazon.com',
      'netflix': 'netflix.com',
      'facebook': 'facebook.com',
      'instagram': 'instagram.com',
      'whatsapp': 'whatsapp.com',
    };
    final official = officialMap[brand];
    if (official == null) return true; // e.g. 'bank', 'gov' — too generic to flag alone
    return host == official || host.endsWith('.$official');
  }
}
