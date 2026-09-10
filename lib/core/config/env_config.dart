import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static Future<void> init() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {
      // Caso o .env não esteja presente ou ocorra erro no bundle, segue com fallbacks
    }
  }

  static String _get(String key, {String fallback = ''}) {
    if (!dotenv.isInitialized) return fallback;
    return dotenv.maybeGet(key) ?? fallback;
  }

  static String get initialAdminEmail =>
      _get('INITIAL_ADMIN_EMAIL', fallback: 'nando.djx@gmail.com').trim().toLowerCase();

  static String get inviteBaseUrl {
    final explicit = _get('INVITE_BASE_URL', fallback: '').trim();
    if (explicit.isNotEmpty) return explicit;
    final projectId = firebaseProjectId;
    if (projectId.isNotEmpty) {
      return 'https://$projectId.web.app/convite';
    }
    return 'https://app.misericordiamaterna.org/convite';
  }

  // Firebase env values com fallbacks do projeto misericordia-materna-sec
  static String get firebaseApiKey =>
      _get('FIREBASE_API_KEY', fallback: 'AIzaSyDQQIGhLOpsKBy0V2E6Q9bRzNqQ5Ak0Fxo');
  static String get firebaseAppId =>
      _get('FIREBASE_APP_ID', fallback: '1:766981626039:web:6f4fda2e967394a44b9532');
  static String get firebaseMessagingSenderId =>
      _get('FIREBASE_MESSAGING_SENDER_ID', fallback: '766981626039');
  static String get firebaseProjectId =>
      _get('FIREBASE_PROJECT_ID', fallback: 'misericordia-materna-sec');
  static String get firebaseAuthDomain =>
      _get('FIREBASE_AUTH_DOMAIN', fallback: 'misericordia-materna-sec.firebaseapp.com');
  static String get firebaseStorageBucket =>
      _get('FIREBASE_STORAGE_BUCKET', fallback: 'misericordia-materna-sec.firebasestorage.app');
  static String get firebaseMeasurementId =>
      _get('FIREBASE_MEASUREMENT_ID', fallback: 'G-4ST06Q2XR6');
}
