// lib/firebase_options.dart - EXEMPLO COM CHAVES REAIS
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError('Windows não configurado');
      case TargetPlatform.linux:
        throw UnsupportedError('Linux não configurado');
      default:
        throw UnsupportedError('Plataforma não suportada');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBStDZdz2-Qaf_eWw95hnLfHf1y4IdnhMU',
    appId: '1:908723429144:android:5435de68d4b7f0d340486d',
    messagingSenderId: '908723429144',
    projectId: 'shopnav-8dd72',
    storageBucket: 'shopnav-8dd72.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBStDZdz2-Qaf_eWw95hnLfHf1y4IdnhMU',
    appId: '1:908723429144:android:5435de68d4b7f0d340486d',
    messagingSenderId: '908723429144',
    projectId: 'shopnav-8dd72',
    storageBucket: 'shopnav-8dd72.firebasestorage.app',
    iosBundleId: 'com.example.shopnav',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBStDZdz2-Qaf_eWw95hnLfHf1y4IdnhMU',
    appId: '1:908723429144:android:5435de68d4b7f0d340486d',
    messagingSenderId: '908723429144',
    projectId: 'shopnav-8dd72',
    storageBucket: 'shopnav-8dd72.firebasestorage.app',
    iosBundleId: 'com.example.shopnav',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBStDZdz2-Qaf_eWw95hnLfHf1y4IdnhMU',
    appId: '1:908723429144:android:5435de68d4b7f0d340486d',
    messagingSenderId: '908723429144',
    projectId: 'shopnav-8dd72',
    authDomain: 'shopnav-8dd72.firebasestorage.app',
    storageBucket: 'shopnav-8dd72.firebasestorage.app',
  );
}