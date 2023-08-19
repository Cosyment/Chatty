import 'package:chatty/advert/admob_impl.dart';
import 'package:chatty/advert/advert_factory.dart';
import 'package:chatty/advert/applovin_impl.dart';
import 'package:chatty/util/platform_util.dart';

class AdvertManager {
  static AdvertManager? _instance;
  AbstractAdvertFactory? advertFactory;

  AdvertManager._internal() {
    _instance = this;
    advertFactory = ApplovinImpl();
    // advertFactory = AdmobImpl();
  }

  factory AdvertManager() => _instance ?? AdvertManager._internal();

  void initial() {
    if (PlatformUtil.isMobile) {
      advertFactory?.initial();
    }
  }

  void showSplash() {
    if (PlatformUtil.isMobile) {
      advertFactory?.showSplash();
    }
  }

  void showReward(Function(String?) callback) {
    if (PlatformUtil.isMobile) {
      advertFactory?.showReward(callback);
    }
  }

  void showInterstitial(Function(String?) callback){
    if (PlatformUtil.isMobile) {
      advertFactory?.showInterstitial(callback);
    }
  }
}
