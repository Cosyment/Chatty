import 'dart:io';

import 'package:chatty/advert/advert_factory.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../services/local_storage_service.dart';
import '../util/constants.dart';

class AdmobImpl implements AbstractAdvertFactory {
  static AppOpenAd? _appOpenAd;
  static const Duration maxCacheDuration = Duration(hours: 4);
  static RewardedAd? _rewardedAd;
  static int _numRewardedLoadAttempts = 0;
  static int maxFailedLoadAttempts = 5;
  static bool _isShowingAd = false;

  @override
  void initial() {
    MobileAds.instance.initialize();
    var testDeviceIds = [
      "db6d97fbbf93e6cb24cda596b1546ebf",
      "d1494e297478756e6d210ac3cf443bd4",
      "33DB042BB30F53894E04020C0ADB3785"
          "a1d54f1dec3987aebc62373a4c95fa2e"
    ];
    var configuration = RequestConfiguration(testDeviceIds: testDeviceIds);
    MobileAds.instance.updateRequestConfiguration(configuration);
  }

  @override
  void showSplash() {
    AppOpenAd.load(
      adUnitId: Platform.isAndroid ? 'ca-app-pub-6237326926737313/8348034044' : 'ca-app-pub-6237326926737313/3671827400',
      orientation: AppOpenAd.orientationPortrait,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('$ad loaded');
          _appOpenAd = ad;
          _showSplashAd();
        },
        onAdFailedToLoad: (error) {
          debugPrint('AppOpenAd failed to load: $error');
        },
      ),
    );
  }

  void _showSplashAd() {
    if (_isShowingAd) {
      debugPrint('Tried to show ad while already showing an ad.');
      return;
    }

    _appOpenAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isShowingAd = true;
        debugPrint('$ad onAdShowedFullScreenContent');
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('$ad onAdFailedToShowFullScreenContent: $error');
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('$ad onAdDismissedFullScreenContent');
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
      },
    );
    _appOpenAd!.show();
  }

  @override
  void showReward(Function callback) {
    RewardedAd.load(
        adUnitId: Platform.isAndroid ? 'ca-app-pub-6237326926737313/9902726663' : 'ca-app-pub-6237326926737313/3865330721',
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {
            debugPrint('$ad loaded.');
            _rewardedAd = ad;
            _numRewardedLoadAttempts = 0;
            _showRewardAd(callback);
          },
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('RewardedAd failed to load: $error');
            _rewardedAd = null;
            _numRewardedLoadAttempts += 1;
            if (_numRewardedLoadAttempts < maxFailedLoadAttempts) {
              _showRewardAd(callback);
            } else {
              callback.call();
            }
          },
        ));
  }

  void _showRewardAd(Function? callback) {
    callback?.call();
    if (_rewardedAd == null) return;

    _rewardedAd?.fullScreenContentCallback = FullScreenContentCallback(onAdShowedFullScreenContent: (ad) {
      debugPrint('_showRewardAd onAdShowedFullScreenContent ${ad}');
    }, onAdClicked: (ad) {
      debugPrint('_showRewardAd onAdClicked ${ad}');
    }, onAdImpression: (ad) {
      debugPrint('_showRewardAd onAdImpression ${ad}');
    }, onAdWillDismissFullScreenContent: (ad) {
      debugPrint('_showRewardAd onAdWillDismissFullScreenContent ${ad}');
    }, onAdFailedToShowFullScreenContent: (ad, error) {
      _rewardedAd == null;
      debugPrint('_showRewardAd onAdFailedToShowFullScreenContent ${ad}');
    }, onAdDismissedFullScreenContent: (ad) {
      _rewardedAd = null;
      debugPrint('_showRewardAd onAdDismissedFullScreenContent ${ad}');
    });
    _rewardedAd?.show(onUserEarnedReward: (_, rewardItem) {
      LocalStorageService().conversationLimit = Constants.REWARD_CONVERSATION_COUNT;
      debugPrint('_showRewardAd show ${rewardItem.amount}---${rewardItem.type}');
    });
  }
}
