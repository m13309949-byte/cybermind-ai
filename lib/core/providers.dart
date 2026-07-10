import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/services/ai_service.dart';
import '../data/services/password_checker_service.dart';
import '../data/services/link_heuristics_service.dart';
import '../data/services/scam_heuristics_service.dart';
import '../data/services/file_scanner_service.dart';
import '../data/repositories/auth_repository.dart';

final aiServiceProvider = Provider<AiService>((ref) => AiService());
final passwordCheckerProvider = Provider<PasswordCheckerService>((ref) => PasswordCheckerService());
final linkHeuristicsProvider = Provider<LinkHeuristicsService>((ref) => LinkHeuristicsService());
final scamHeuristicsProvider = Provider<ScamHeuristicsService>((ref) => ScamHeuristicsService());
final fileScannerProvider = Provider<FileScannerService>((ref) => FileScannerService());
final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository());

final authStateProvider = StreamProvider((ref) => ref.watch(authRepositoryProvider).authStateChanges);

/// Locale state ('en' or 'ar') drives both easy_localization and RTL layout.
final localeCodeProvider = StateProvider<String>((ref) => 'en');
