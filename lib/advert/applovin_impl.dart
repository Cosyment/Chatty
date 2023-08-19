import 'dart:io';

import 'package:applovin_max/applovin_max.dart';
import 'package:chatty/advert/advert_factory.dart';

class ApplovinImpl implements AbstractAdvertFactory {
  @override
  void initial() async {
    AppLovinMAX.setTestDeviceAdvertisingIds(
        ['9F91EBBD-ED71-499C-A65F-BC09CBD65FDA', 'F0E7BA7B-53D4-4628-875B-D5B2E248B203', '7bd6a4e6-8f28-4f96-9d0a-e48d5c1437ea']);
    Map? sdkConfiguration =
        await AppLovinMAX.initialize('lKGMTntNyoxxAscPEXQMIIXSEc_RlU1709KxdWaVtKsCVg3g4z1kym2xbSKH5cQaaql5nrZivaXlt9rDVN4ItI');
    // sdkConfiguration.putIfAbsent('key', '');
    AppLovinMAX.setRewardedAdListener(RewardedAdListener(onAdLoadedCallback: (ad) {
      print('------------->>>>onAdLoadedCallback ${ad}');
    }, onAdLoadFailedCallback: (ad, error) {
      print('------------->>>>onAdLoadFailedCallback ${ad}---${error}');
      // AppLovinMAX.loadRewardedAd('59d15aa2ce9239aa');
    }, onAdDisplayedCallback: (ad) {
      print('------------->>>>onAdDisplayedCallback ${ad}');
    }, onAdDisplayFailedCallback: (ad, error) {
      print('------------->>>>onAdDisplayFailedCallback ${ad}--${error}');
    }, onAdClickedCallback: (ad) {
      print('------------->>>>onAdClickedCallback ${ad}');
    }, onAdHiddenCallback: (ad) {
      print('------------->>>>onAdHiddenCallback ${ad}');
    }, onAdReceivedRewardCallback: (ad, reward) {
      print('------------->>>>onAdReceivedRewardCallback ${ad}--${reward}');
    }));
    AppLovinMAX.setVerboseLogging(true);
  }

  @override
  void showSplash() {}

  @override
  Future<void> showReward(Function callback) async {
    String unitId = Platform.isIOS ? '59d15aa2ce9239aa' : '2aa9dc2e3dd7ff91';
    bool? isReady = await AppLovinMAX.isRewardedAdReady(unitId);
    if (isReady == true) {
      AppLovinMAX.showRewardedAd(unitId);
    } else {
      AppLovinMAX.loadRewardedAd(unitId);
    }
  }
}
