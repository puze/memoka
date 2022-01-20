import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:memoka/data_manager.dart';

class Admob {
  static final Admob _instance = Admob._internal();

  final int maxFailedLoadAttempts = 3;
  static AdRequest request = const AdRequest(
      // keywords: <String>['foo', 'bar'],
      // contentUrl: 'http://foo.com/bar.html',
      // nonPersonalizedAds: true,
      );

  RewardedAd? _rewardedAd;
  int _numRewardedLoadAttempts = 0;

  final String testId = 'ca-app-pub-3940256099942544/5354046379';
  final String rewardId = 'ca-app-pub-7658460612630664/2348277849';

  factory Admob() {
    return _instance;
  }

  Admob._internal() {
    // 초기화
  }

  void initAdmob() {
    _createRewardedAd();
  }

  void _createRewardedAd() {
    RewardedAd.load(
        adUnitId: rewardId,
        request: request,
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {
            debugPrint('$ad loaded.');
            _rewardedAd = ad;
            _numRewardedLoadAttempts = 0;
          },
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('RewardedAd failed to load: $error');
            _rewardedAd = null;
            _numRewardedLoadAttempts += 1;
            if (_numRewardedLoadAttempts <= maxFailedLoadAttempts) {
              _createRewardedAd();
            }
          },
        ));
  }

  void showRewardedAd({State? state}) {
    if (_rewardedAd == null) {
      debugPrint('Warning: attempt to show rewarded before loaded.');
      return;
    }
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) =>
          debugPrint('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        debugPrint('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        debugPrint('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createRewardedAd();
      },
    );

    _rewardedAd!.setImmersiveMode(true);

    // 보상형 광고 실행
    _rewardedAd!.show(onUserEarnedReward: (RewardedAd ad, RewardItem reward) {
      debugPrint(
          '$ad with reward $RewardItem(${reward.amount}, ${reward.type}');
      int coin =
          int.parse(DataManager().memokaGroupList!.coin) + reward.amount as int;
      DataManager().memokaGroupList!.coin = coin.toString();
      debugPrint('coin : ' + DataManager().memokaGroupList!.coin);
      DataManager().saveData();
    });
    _rewardedAd = null;
    if (state != null) {
      state.setState(() {});
    }
  }

  void dispose() {
    _rewardedAd?.dispose();
  }
}
