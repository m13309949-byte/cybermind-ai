import 'package:go_router/go_router.dart';
import '../../features/shared/root_shell.dart';
import '../../features/shared/home_screen.dart';
import '../../features/chat/chat_screen.dart';
import '../../features/link_scanner/link_scanner_screen.dart';
import '../../features/scam_detector/scam_detector_screen.dart';
import '../../features/password_checker/password_checker_screen.dart';
import '../../features/qr_scanner/qr_scanner_screen.dart';
import '../../features/file_scanner/file_scanner_screen.dart';
import '../../features/news/news_screen.dart';
import '../../features/learning/learning_center_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/premium/premium_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => RootShell(child: child),
      routes: [
        GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
        GoRoute(path: '/chat', builder: (context, state) => const ChatScreen()),
        GoRoute(path: '/learn', builder: (context, state) => const LearningCenterScreen()),
        GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
      ],
    ),
    GoRoute(path: '/link-scanner', builder: (context, state) => const LinkScannerScreen()),
    GoRoute(path: '/scam-detector', builder: (context, state) => const ScamDetectorScreen()),
    GoRoute(path: '/password-checker', builder: (context, state) => const PasswordCheckerScreen()),
    GoRoute(path: '/qr-scanner', builder: (context, state) => const QrScannerScreen()),
    GoRoute(path: '/file-scanner', builder: (context, state) => const FileScannerScreen()),
    GoRoute(path: '/news', builder: (context, state) => const NewsScreen()),
    GoRoute(path: '/premium', builder: (context, state) => const PremiumScreen()),
  ],
);
