import 'package:flutter/foundation.dart';

class AdMobService {
  static const String _rewardedAdUnitFromEnv = String.fromEnvironment(
    'ADMOB_REWARDED_AD_UNIT_ID',
  );
  static const String _bannerAdUnitFromEnv = String.fromEnvironment(
    'ADMOB_BANNER_AD_UNIT_ID',
  );
  static const String _interstitialAdUnitFromEnv = String.fromEnvironment(
    'ADMOB_INTERSTITIAL_AD_UNIT_ID',
  );

  static bool get isSupportedPlatform {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  static String get rewardedAdUnitId {
    if (_rewardedAdUnitFromEnv.isNotEmpty &&
        _rewardedAdUnitFromEnv.contains('/')) {
      return _rewardedAdUnitFromEnv;
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'ca-app-pub-3940256099942544/5224354917';
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'ca-app-pub-3940256099942544/1712485313';
    }

    return '';
  }

  static String get bannerAdUnitId {
    if (_bannerAdUnitFromEnv.isNotEmpty && _bannerAdUnitFromEnv.contains('/')) {
      return _bannerAdUnitFromEnv;
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'ca-app-pub-3940256099942544/6300978111';
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'ca-app-pub-3940256099942544/2934735716';
    }

    return '';
  }

  static String get interstitialAdUnitId {
    if (_interstitialAdUnitFromEnv.isNotEmpty &&
        _interstitialAdUnitFromEnv.contains('/')) {
      return _interstitialAdUnitFromEnv;
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'ca-app-pub-3940256099942544/1033173712';
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'ca-app-pub-3940256099942544/4411468910';
    }

    return '';
  }
}
