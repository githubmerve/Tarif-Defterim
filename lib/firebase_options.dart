import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBVhrC5NkBU08XadcvYucNOTN679ERm3lA',
    appId: '1:1046426835962:web:4820c18ae98e3bbc472243',
    messagingSenderId: '1046426835962',
    projectId: 'tarif-defterim-2f75d',
    authDomain: 'tarif-defterim-2f75d.firebaseapp.com',
  );
}
