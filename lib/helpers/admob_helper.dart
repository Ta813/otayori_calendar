import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobHelper {
  /// テスト用の広告ユニットID（本番では自分のIDに差し替える）
  static const String rewardedAdUnitId =
      "ca-app-pub-2333753292729105/4389391821";

  /// リワード広告を読み込む静的メソッド
  ///
  /// [onAdLoaded] - 広告の読み込みが成功したときに呼ばれるコールバック
  /// [onAdFailedToLoad] - 広告の読み込みが失敗したときに呼ばれるコールバック
  static void loadRewardedAd({
    required Function(RewardedAd ad) onAdLoaded,
    required Function(LoadAdError error) onAdFailedToLoad,
  }) {
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: onAdFailedToLoad,
      ),
    );
  }
}
