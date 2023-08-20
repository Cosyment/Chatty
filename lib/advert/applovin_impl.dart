import 'dart:io';

import 'package:applovin_max/applovin_max.dart';
import 'package:chatty/advert/advert_factory.dart';
import 'package:chatty/advert/advert_manager.dart';
import 'package:flutter/cupertino.dart';

import '../generated/l10n.dart';
import '../services/local_storage_service.dart';

class ApplovinImpl implements AbstractAdvertFactory {
  @override
  void initial() {
    AppLovinMAX.setTestDeviceAdvertisingIds([
      '9F91EBBD-ED71-499C-A65F-BC09CBD65FDA',
      'F0E7BA7B-53D4-4628-875B-D5B2E248B203',
      'D8494D06-0BA1-4269-9E7F-5FADFC48E17F',
      'B230F599-D17E-4091-A2E5-0632B530E3E3',
      '7bd6a4e6-8f28-4f96-9d0a-e48d5c1437ea'
    ]);
    // AppLovinMAX.setVerboseLogging(true);
    // AppLovinMAX.setCreativeDebuggerEnabled(true);
    // AppLovinMAX.showMediationDebugger();

    // Map? sdkConfiguration =
    AppLovinMAX.initialize('lKGMTntNyoxxAscPEXQMIIXSEc_RlU1709KxdWaVtKsCVg3g4z1kym2xbSKH5cQaaql5nrZivaXlt9rDVN4ItI');
    // sdkConfiguration.putIfAbsent('key', '');
  }

  @override
  void showSplash() {
    String unitId = Platform.isIOS ? '2ffbebf36a849c1a' : '390f5e69c1f6a585';
    AppLovinMAX.loadAppOpenAd(unitId);
    AppLovinMAX.setAppOpenAdListener(AppOpenAdListener(onAdLoadedCallback: (ad) async {
      debugPrint('showSplash onAdLoadedCallback $ad');
      if (await AppLovinMAX.isAppOpenAdReady(unitId) == true) {
        AppLovinMAX.showAppOpenAd(unitId);
      }
    }, onAdLoadFailedCallback: (ad, error) {
      debugPrint('showSplash onAdLoadFailedCallback $ad---$error');
    }, onAdDisplayedCallback: (ad) {
      debugPrint('showSplash onAdDisplayedCallback $ad');
    }, onAdDisplayFailedCallback: (ad, error) {
      debugPrint('showSplash onAdDisplayFailedCallback $ad---$error');
    }, onAdClickedCallback: (ad) {
      debugPrint('showSplash onAdClickedCallback $ad');
    }, onAdHiddenCallback: (ad) {
      debugPrint('showSplash onAdHiddenCallback $ad');
    }));
  }

  @override
  void showReward(Function(String? msg) callback) {
    String unitId = Platform.isIOS ? '59d15aa2ce9239aa' : '2aa9dc2e3dd7ff91';
    var retryAttempt = 0;
    AppLovinMAX.loadRewardedAd(unitId);
    AppLovinMAX.setRewardedAdListener(RewardedAdListener(onAdLoadedCallback: (ad) async {
      debugPrint('showReward onAdLoadedCallback $ad');
      if (await AppLovinMAX.isRewardedAdReady(unitId) == true) {
        callback.call(null);
        AppLovinMAX.showRewardedAd(unitId);
      }
    }, onAdLoadFailedCallback: (ad, error) {
      debugPrint('showReward onAdLoadFailedCallback retryAttempt $retryAttempt, $ad , $error');
      if (retryAttempt < 3) {
        Future.delayed(const Duration(milliseconds: 1000), () {
          AppLovinMAX.loadRewardedAd(unitId);
          retryAttempt += 1;
        });
      } else {
        callback.call(S.current.ad_load_failure);
      }
    }, onAdDisplayedCallback: (ad) {
      debugPrint('showReward onAdDisplayedCallback $ad');
      LocalStorageService().conversationLimit = AdvertManager.REWARD_CONVERSATION_COUNT;
    }, onAdDisplayFailedCallback: (ad, error) {
      debugPrint('showReward onAdDisplayFailedCallback $ad--$error');
      callback.call(S.current.ad_load_failure);
    }, onAdClickedCallback: (ad) {
      debugPrint('showReward onAdClickedCallback $ad');
    }, onAdHiddenCallback: (ad) {
      debugPrint('showReward onAdHiddenCallback $ad');
    }, onAdReceivedRewardCallback: (ad, reward) {
      debugPrint('showReward onAdReceivedRewardCallback $ad--$reward');
    }));
  }

  @override
  void showInterstitial(Function(String? msg) callback) {
    String unitId = Platform.isIOS ? 'de10fad7a72a138f' : '9881f5a2080dda28';
    var retryAttempt = 0;
    AppLovinMAX.loadInterstitial(unitId);
    AppLovinMAX.setInterstitialListener(InterstitialListener(onAdLoadedCallback: (ad) async {
      debugPrint('showInterstitial onAdLoadedCallback $ad');
      if (await AppLovinMAX.isInterstitialReady(unitId) == true) {
        callback.call(null);
        AppLovinMAX.showInterstitial(unitId);
      }
    }, onAdLoadFailedCallback: (ad, error) {
      debugPrint('showInterstitial onAdLoadFailedCallback retryAttempt $retryAttempt, $ad , $error');
      if (retryAttempt < 3) {
        Future.delayed(const Duration(milliseconds: 1000), () {
          AppLovinMAX.loadInterstitial(unitId);
          retryAttempt += 1;
        });
      } else {
        callback.call(S.current.ad_load_failure);
      }
    }, onAdDisplayedCallback: (ad) {
      debugPrint('showInterstitial onAdDisplayedCallback $ad');
      LocalStorageService().conversationLimit = AdvertManager.REWARD_CONVERSATION_COUNT;
    }, onAdDisplayFailedCallback: (ad, error) {
      debugPrint('showInterstitial onAdDisplayFailedCallback $ad--$error');
      callback.call(S.current.ad_load_failure);
    }, onAdClickedCallback: (ad) {
      debugPrint('showInterstitial onAdClickedCallback $ad');
    }, onAdHiddenCallback: (ad) {
      debugPrint('showInterstitial onAdHiddenCallback $ad');
    }));
  }
}
