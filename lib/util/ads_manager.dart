import 'dart:io' show Platform;

import 'package:chatty/services/local_storage_service.dart';
import 'package:chatty/util/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdsManager {
  static DateTime? _appOpenLoadTime;
  static AppOpenAd? _appOpenAd;
  static final Duration maxCacheDuration = const Duration(hours: 4);
  static RewardedAd? _rewardedAd;
  static int _numRewardedLoadAttempts = 0;
  static int maxFailedLoadAttempts = 5;
  static bool _isShowingAd = false;
  static bool _isShowingRewardAd = false;

  static init() {
    MobileAds.instance.initialize();
  }

  static void loadAd() {
    var testDeviceIds = [
      "db6d97fbbf93e6cb24cda596b1546ebf",
      "d1494e297478756e6d210ac3cf443bd4",
      "33DB042BB30F53894E04020C0ADB3785"
    ];
    var configuration = RequestConfiguration(testDeviceIds: testDeviceIds);
    MobileAds.instance.updateRequestConfiguration(configuration);

    AppOpenAd.load(
      adUnitId: Platform.isAndroid ? 'ca-app-pub-6237326926737313/8348034044' : 'ca-app-pub-6237326926737313/3671827400',
      orientation: AppOpenAd.orientationPortrait,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          print('$ad loaded');
          _appOpenLoadTime = DateTime.now();
          _appOpenAd = ad;
          _showAd();
        },
        onAdFailedToLoad: (error) {
          print('AppOpenAd failed to load: $error');
        },
      ),
    );

    // RewardedAd.load(Platform.isAndroid ? 'ca-app-pub-6237326926737313/9902726663' : 'ca-app-pub-6237326926737313/3865330721', request: request, rewardedAdLoadCallback: rewardedAdLoadCallback)
  }

  static bool get isAdAvailable {
    return _appOpenAd != null;
  }

  static void _showAd() {
    if (!isAdAvailable) {
      print('Tried to show ad before available.');
      loadAd();
      return;
    }
    if (_isShowingAd) {
      print('Tried to show ad while already showing an ad.');
      return;
    }
    // if (DateTime.now().subtract(maxCacheDuration).isAfter(_appOpenLoadTime!)) {
    //   print('Maximum cache duration exceeded. Loading another ad.');
    //   _appOpenAd!.dispose();
    //   _appOpenAd = null;
    //   loadAd();
    //   return;
    // }
    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isShowingAd = true;
        print('$ad onAdShowedFullScreenContent');
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
      },
      onAdDismissedFullScreenContent: (ad) {
        print('$ad onAdDismissedFullScreenContent');
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
        // loadAd();
      },
    );
    _appOpenAd!.show();
  }

  static void loadRewardAd({Function? callback}) {
    RewardedAd.load(
        adUnitId: Platform.isAndroid ? 'ca-app-pub-6237326926737313/9902726663' : 'ca-app-pub-6237326926737313/3865330721',
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {
            print('$ad loaded.');
            _rewardedAd = ad;
            _numRewardedLoadAttempts = 0;
            _showRewardAd(callback: callback);
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('RewardedAd failed to load: $error');
            _rewardedAd = null;
            _numRewardedLoadAttempts += 1;
            if (_numRewardedLoadAttempts < maxFailedLoadAttempts) {
              loadRewardAd(callback: callback);
            } else {
              callback?.call();
            }
          },
        ));
  }

  static void _showRewardAd({Function? callback}) {
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
