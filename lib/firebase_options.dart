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
    apiKey: 'AIzaSyCe_8-zkLGLJ0N4aObJ4FhoGef_24k5M8Y',
    appId: '1:299882572158:web:be4a15651c0f9f71e12b2f',
    messagingSenderId: '299882572158',
    projectId: 'agendamentovistoriad-664a1bf6',
    authDomain: 'agendamentovistoriad-664a1bf6.firebaseapp.com',
    storageBucket: 'agendamentovistoriad-664a1bf6.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB7iY52PwalhdmHi_3ANd2GLm83f4a5Pbo',
    appId: '1:299882572158:android:6526252f226c62aae12b2f',
    messagingSenderId: '299882572158',
    projectId: 'agendamentovistoriad-664a1bf6',
    storageBucket: 'agendamentovistoriad-664a1bf6.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC_mvUKL13r1UkURCMNdBbAhgY-A9svRtw',
    appId: '1:299882572158:ios:fceef01f342b52a7e12b2f',
    messagingSenderId: '299882572158',
    projectId: 'agendamentovistoriad-664a1bf6',
    storageBucket: 'agendamentovistoriad-664a1bf6.firebasestorage.app',
    iosBundleId: 'com.example.agendamentoItaplacas',
  );
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyC_mvUKL13r1UkURCMNdBbAhgY-A9svRtw',
    appId: '1:299882572158:ios:fceef01f342b52a7e12b2f',
    messagingSenderId: '299882572158',
    projectId: 'agendamentovistoriad-664a1bf6',
    storageBucket: 'agendamentovistoriad-664a1bf6.firebasestorage.app',
    iosBundleId: 'com.example.agendamentoItaplacas',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCe_8-zkLGLJ0N4aObJ4FhoGef_24k5M8Y',
    appId: '1:299882572158:web:c64a9aa89b275585e12b2f',
    messagingSenderId: '299882572158',
    projectId: 'agendamentovistoriad-664a1bf6',
    authDomain: 'agendamentovistoriad-664a1bf6.firebaseapp.com',
    storageBucket: 'agendamentovistoriad-664a1bf6.firebasestorage.app',
  );
}
