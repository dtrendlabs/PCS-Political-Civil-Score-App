// ┌──────────────────────────────────────────────────────────────────┐
// │  📄 TEMPLATE — Copy this file to app_secrets.dart and fill in  │
// │  your real API keys. This template IS safe to commit.           │
// └──────────────────────────────────────────────────────────────────┘
//
// Steps:
//   1. Copy this file:  app_secrets.template.dart → app_secrets.dart
//   2. Replace all 'YOUR_*' placeholders with real values
//   3. The actual app_secrets.dart is in .gitignore — it won't be pushed

class AppSecrets {
  AppSecrets._();

  // ─── Firebase ──────────────────────────────────────────────────
  static const String firebaseApiKey = 'YOUR_FIREBASE_API_KEY';
  static const String firebaseAppId = 'YOUR_FIREBASE_APP_ID';
  static const String firebaseMessagingSenderId = 'YOUR_SENDER_ID';
  static const String firebaseProjectId = 'YOUR_PROJECT_ID';
  static const String firebaseStorageBucket = 'YOUR_STORAGE_BUCKET';

  // ─── Google Maps / Places ──────────────────────────────────────
  static const String googleMapsApiKey = 'YOUR_GOOGLE_MAPS_API_KEY';

  // ─── Google Gemini AI ──────────────────────────────────────────
  static const String googleGeminiApiKey = 'YOUR_GEMINI_API_KEY';

  // ─── Backend API ───────────────────────────────────────────────
  static const String apiBaseUrl = 'https://your-api-url.com';
  static const String apiToken = 'YOUR_API_TOKEN';

  // ─── Third-Party Services ──────────────────────────────────────
  static const String sentryDsn = 'YOUR_SENTRY_DSN';
  static const String analyticsKey = 'YOUR_ANALYTICS_KEY';

  // ─── Add your own keys below ───────────────────────────────────
}
