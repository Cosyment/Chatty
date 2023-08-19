import 'package:chatty/advert/admob_impl.dart';
import 'package:chatty/advert/advert_factory.dart';
import 'package:chatty/advert/applovin_impl.dart';

class AdsManager {
  static AdsManager? _instance;
  AbstractAdvertFactory? advertFactory;

  AdsManager._internal() {
    _instance = this;
    advertFactory = ApplovinImpl();
  }

  factory AdsManager() => _instance ?? AdsManager._internal();

  void initial() {
    advertFactory?.initial();
  }

  void showSplash() {
    advertFactory?.showSplash();
  }

  void showReward(Function callback) {
    advertFactory?.showReward(callback);
  }
}
