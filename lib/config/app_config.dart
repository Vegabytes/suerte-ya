class AppConfig {
  static const String appName = 'SuerteYa';
  static const String appVersion = '1.0.0';

  // Firebase Cloud Functions base URL (set after deployment)
  static const String apiBaseUrl = 'https://us-central1-YOUR_PROJECT.cloudfunctions.net/api';

  // AdMob IDs (replace with your own)
  static const String admobAppId = 'ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX';
  static const String bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111'; // Test ID
  static const String interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712'; // Test ID

  // Game categories
  static const int categorySelae = 1;
  static const int categoryOnce = 2;
  static const int categoryCatalunya = 3;
  static const int categoryExtraordinarios = 4;
}
