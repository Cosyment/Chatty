abstract class AbstractAdvertFactory {
  void initial();

  void showSplash();

  void showReward(Function(String? msg) callback);

  void showInterstitial(Function(String? msg) callback);

  void showBanner();
}
