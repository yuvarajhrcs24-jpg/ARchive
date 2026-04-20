import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

/// Platform-specific Firebase options
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // Return Android first, you'll need to add iOS as well
    return android;
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_ANDROID_API_KEY',
    appId: '1:YOUR_PROJECT_NUMBER:android:YOUR_PACKAGE_NAME',
    messagingSenderId: 'YOUR_PROJECT_NUMBER',
    projectId: 'your-project-id',
    databaseURL: 'https://your-project-id.firebaseio.com',
    storageBucket: 'your-project-id.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: '1:YOUR_PROJECT_NUMBER:ios:YOUR_BUNDLE_ID',
    messagingSenderId: 'YOUR_PROJECT_NUMBER',
    projectId: 'your-project-id',
    databaseURL: 'https://your-project-id.firebaseio.com',
    storageBucket: 'your-project-id.appspot.com',
    iosBundleId: 'com.example.archive',
  );
}
