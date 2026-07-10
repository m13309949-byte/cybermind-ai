/// App-wide constants.
///
/// SECURITY NOTE:
/// - Never hard-code API keys in source. This app reads secrets via
///   `--dart-define` at build time (see README) and/or a backend proxy.
/// - The OpenAI key should NOT ship inside the mobile binary for production;
///   route AI calls through a Firebase Cloud Function / Cloud Run proxy that
///   holds the real key server-side. `AppConfig.openAiProxyUrl` models that.
class AppConfig {
  AppConfig._();

  static const String appName = 'CyberMind AI';

  /// Preferred: call your own backend proxy (Cloud Function) which injects
  /// the OpenAI key server-side. Set via --dart-define=OPENAI_PROXY_URL=...
  static const String openAiProxyUrl = String.fromEnvironment(
    'OPENAI_PROXY_URL',
    defaultValue: 'https://us-central1-cybermind-ai.cloudfunctions.net/aiProxy',
  );

  /// Fallback direct key ONLY for local dev/testing on a trusted machine.
  /// Do not ship builds with this populated to public app stores.
  static const String openAiApiKeyDevOnly = String.fromEnvironment(
    'OPENAI_API_KEY',
    defaultValue: '',
  );

  static const String privacyPolicyUrl = 'https://cybermind.ai/privacy';
  static const String termsUrl = 'https://cybermind.ai/terms';

  // Feature limits for free tier (enforced client-side for UX + server-side
  // via Firestore security rules / Cloud Functions for real enforcement).
  static const int freeDailyAiChatMessages = 10;
  static const int freeDailyLinkScans = 5;
  static const int freeDailyScamChecks = 5;
  static const int freeDailyFileScans = 2;
}

class FirestoreCollections {
  FirestoreCollections._();
  static const users = 'users';
  static const chatSessions = 'chat_sessions';
  static const scanHistory = 'scan_history';
  static const newsFeed = 'security_news';
  static const lessons = 'lessons';
  static const quizResults = 'quiz_results';
  static const certificates = 'certificates';
  static const subscriptions = 'subscriptions';
}
