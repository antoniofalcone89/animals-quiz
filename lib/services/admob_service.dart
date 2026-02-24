import 'package:flutter/foundation.dart';

class AdMobService {
  static const String _rewardedAdUnitFromEnv = String.fromEnvironment(
    'ADMOB_REWARDED_AD_UNIT_ID',
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
}
