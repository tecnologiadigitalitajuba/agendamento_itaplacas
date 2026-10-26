import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Configurações padrão do Firebase para a aplicação Itaplacas.
/// 
/// DICA: Se você já tem um projeto criado no Console do Firebase (console.firebase.google.com),
/// substitua as chaves abaixo pelas do seu projeto do Firebase.
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
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions não configurado para Linux.',
        );
      default:
        throw UnsupportedError(
          'Plataforma não suportada para DefaultFirebaseOptions.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA_SUA_API_KEY_AQUI',
    appId: '1:1234567890:web:abcdef123456',
    messagingSenderId: '1234567890',
    projectId: 'agendamento-itaplacas',
    authDomain: 'agendamento-itaplacas.firebaseapp.com',
    storageBucket: 'agendamento-itaplacas.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA_SUA_API_KEY_AQUI',
    appId: '1:1234567890:android:abcdef123456',
    messagingSenderId: '1234567890',
    projectId: 'agendamento-itaplacas',
    storageBucket: 'agendamento-itaplacas.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA_SUA_API_KEY_AQUI',
    appId: '1:1234567890:ios:abcdef123456',
    messagingSenderId: '1234567890',
    projectId: 'agendamento-itaplacas',
    storageBucket: 'agendamento-itaplacas.appspot.com',
    iosBundleId: 'com.example.agendamentoItaplacas',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA_SUA_API_KEY_AQUI',
    appId: '1:1234567890:ios:abcdef123456',
    messagingSenderId: '1234567890',
    projectId: 'agendamento-itaplacas',
    storageBucket: 'agendamento-itaplacas.appspot.com',
    iosBundleId: 'com.example.agendamentoItaplacas',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyA_SUA_API_KEY_AQUI',
    appId: '1:1234567890:web:abcdef123456',
    messagingSenderId: '1234567890',
    projectId: 'agendamento-itaplacas',
    authDomain: 'agendamento-itaplacas.firebaseapp.com',
    storageBucket: 'agendamento-itaplacas.appspot.com',
  );
}
