import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';
import 'firebase_options.dart';

/// Background message handler must be a top-level function.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle data-only background pushes (e.g. "new critical CVE") here.
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const ProviderScope(child: CyberMindApp()),
    ),
  );
}

class CyberMindApp extends StatelessWidget {
  const CyberMindApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'CyberMind AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      routerConfig: appRouter,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      builder: (context, child) {
        return Directionality(
          textDirection: context.locale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
