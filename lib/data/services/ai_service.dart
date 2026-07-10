import 'package:dio/dio.dart';
import '../../core/constants/app_config.dart';

enum AiTaskType { chat, linkScan, scamDetect, fileScan }

class AiServiceException implements Exception {
  final String message;
  AiServiceException(this.message);
  @override
  String toString() => message;
}

/// All AI calls go through [AppConfig.openAiProxyUrl] — a Cloud Function
/// you deploy that holds the OpenAI key server-side and enforces per-user
/// rate limits (free vs premium) using Firebase Auth ID tokens.
///
/// This keeps the OpenAI key OUT of the compiled app (critical for
/// App Store / Play Store review and for preventing key theft via
/// APK/IPA decompilation).
class AiService {
  AiService({Dio? dio}) : _dio = dio ?? Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 40),
        ));

  final Dio _dio;

  Future<String> _callProxy({
    required AiTaskType task,
    required String input,
    required String userIdToken,
    String locale = 'en',
  }) async {
    try {
      final response = await _dio.post(
        AppConfig.openAiProxyUrl,
        options: Options(headers: {
          'Authorization': 'Bearer $userIdToken',
          'Content-Type': 'application/json',
        }),
        data: {
          'task': task.name,
          'input': input,
          'locale': locale,
        },
      );
      final data = response.data;
      if (data is Map && data['output'] is String) {
        return data['output'] as String;
      }
      throw AiServiceException('Unexpected response from AI proxy.');
    } on DioException catch (e) {
      if (e.response?.statusCode == 429) {
        throw AiServiceException('Daily free limit reached. Upgrade to Premium for unlimited scans.');
      }
      throw AiServiceException('AI request failed: ${e.message}');
    }
  }

  /// Cybersecurity assistant chat turn.
  Future<String> chat({
    required String message,
    required String userIdToken,
    String locale = 'en',
    List<Map<String, String>> history = const [],
  }) {
    return _callProxy(
      task: AiTaskType.chat,
      input: message,
      userIdToken: userIdToken,
      locale: locale,
    );
  }

  /// Ask the model to reason about a URL's risk in addition to local
  /// heuristics (see [LinkHeuristicsService]) — used for the "explain why"
  /// narrative shown to the user.
  Future<String> explainLinkRisk({
    required String url,
    required String userIdToken,
    String locale = 'en',
  }) {
    return _callProxy(task: AiTaskType.linkScan, input: url, userIdToken: userIdToken, locale: locale);
  }

  Future<String> analyzeScamMessage({
    required String message,
    required String userIdToken,
    String locale = 'en',
  }) {
    return _callProxy(task: AiTaskType.scamDetect, input: message, userIdToken: userIdToken, locale: locale);
  }

  Future<String> analyzeFileMetadata({
    required String metadataSummary,
    required String userIdToken,
    String locale = 'en',
  }) {
    return _callProxy(task: AiTaskType.fileScan, input: metadataSummary, userIdToken: userIdToken, locale: locale);
  }
}
