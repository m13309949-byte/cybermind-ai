import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Generated from Firebase console for project: cybermind-ai-5404b
/// iOS/web values still need to be added once those apps are registered.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError('DefaultFirebaseOptions are not supported for this platform.');
    }
  }

  static const web = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: '145167902711',
    projectId: 'cybermind-ai-5404b',
    authDomain: 'cybermind-ai-5404b.firebaseapp.com',
    storageBucket: 'cybermind-ai-5404b.firebasestorage.app',
  );

  static const android = FirebaseOptions(
    apiKey: 'AIzaSyDHpTfIZkvi1tsfQnQt2hExkOwHTZ-4MWo',
    appId: '1:145167902711:android:5d575c08d4ca009d1e70f2',
    messagingSenderId: '145167902711',
    projectId: 'cybermind-ai-5404b',
    storageBucket: 'cybermind-ai-5404b.firebasestorage.app',
  );

  static const ios = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: '145167902711',
    projectId: 'cybermind-ai-5404b',
    storageBucket: 'cybermind-ai-5404b.firebasestorage.app',
    iosBundleId: 'ai.cybermind.app',
  );
}

