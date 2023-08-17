import 'dart:async';
import 'dart:io';

import 'package:chatty/services/local_storage_service.dart';
import 'package:chatty/util/platform_util.dart';
import 'package:chatty/widgets/common_appbar.dart';
import 'package:chatty/widgets/common_stateful_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../generated/l10n.dart';
import '../util/constants.dart';
import '../widgets/theme_color.dart';

class PremiumScreen extends CommonStatefulWidget {
  const PremiumScreen({super.key});

  @override
  String title() => S.current.premium;

  @override
  State<StatefulWidget> createState() => _PremiumScreen();
}

class _PremiumScreen extends State<CommonStatefulWidget> {
  final LinearGradient gradientColor = const LinearGradient(
      colors: [Color(0xFF2EC0FF), Color(0xFF5394FF), Color(0xFF7769FF), Color(0xFFB360EC), Color(0xFFEE56D9)],
      begin: Alignment.bottomLeft,
      end: Alignment.topRight);

  final List<String> _premiumFeatures = [
    S.current.premium_features1,
    S.current.premium_features2,
    S.current.premium_features3,
    S.current.premium_features4,
    S.current.premium_features5,
    S.current.premium_features6
  ];
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late bool isAvailable = false;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  final List<String> _identifiers = ['membership_weekly', 'membership_monthly', 'membership_quarterly', 'membership_yearly'];
  List<ProductDetails> _products = <ProductDetails>[];
  var _checkedIndex = 0;

  void initStoreInfo() async {
    isAvailable = await _inAppPurchase.isAvailable();
    if (!isAvailable) {
      return;
    }
    _inAppPurchase.restorePurchases();

    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
          _inAppPurchase.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      await iosPlatformAddition.setDelegate(PaymentQueueDelegate());
    }

    getProducts();

    finishTransaction();
  }

  void getProducts() async {
    ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(_identifiers.toSet());
    setState(() {
      _products = response.productDetails;
      _products.sort((a, b) => a.rawPrice.compareTo(b.rawPrice));
      int index = _identifiers.indexOf(LocalStorageService().getCurrentMembershipProductId(), 0);
      _checkedIndex = index < 0 ? 0 : index;
    });
    subscription();
  }

  void subscription() {
    final Stream<List<PurchaseDetails>> purchaseUpdated = _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen((List<PurchaseDetails> purchaseDetailsList) {
      listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      debugPrint('purchase done');
      _subscription.cancel();
    }, onError: (Object error) {
      // handle error here.
      debugPrint('purchase error $error');
    });
  }

  void finishTransaction() async {
    if (Platform.isIOS) {
      var paymentWrapper = SKPaymentQueueWrapper();
      var transactions = await paymentWrapper.transactions();
      transactions.forEach((transaction) async {
        await paymentWrapper.finishTransaction(transaction);
      });
    }
  }

  Future<void> listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) async {
    debugPrint('listenToPurchaseUpdated purchaseDetailsList.length ${purchaseDetailsList.length}');

    //未订阅过
    if (purchaseDetailsList.isEmpty) {
      if (context.mounted && Navigator.canPop(context)) {
        showToast(S.current.nothing_to_restore);
        Navigator.pop(context);
        return;
      }
    }
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        debugPrint('purchase pending... productId: ${purchaseDetails.productID}, purchaseId: ${purchaseDetails.purchaseID}');
        showLottieDialog(context, 'assets/loading.json');
      } else {
        if (context.mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
        }

        if (purchaseDetails.status == PurchaseStatus.error) {
          debugPrint('purchase error ${purchaseDetails.status}');
          showToast(S.current.purchase_failure);
          finishTransaction();
        } else if (purchaseDetails.status == PurchaseStatus.purchased || purchaseDetails.status == PurchaseStatus.restored) {
          debugPrint(
              'purchase status ${purchaseDetails.status}, productId: ${purchaseDetails.productID}, purchaseId: ${purchaseDetails.purchaseID} , transactionDate: ${purchaseDetails.transactionDate}');

          if (context.mounted) {
            if (purchaseDetails.status == PurchaseStatus.purchased) {
              showLottieDialog(context, 'assets/animation_ll82qc8x.json');
              Future.delayed(const Duration(milliseconds: 2500), () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
                showToast(S.current.purchase_success);
              });
              setState(() {
                LocalStorageService().currentMembershipProductId = purchaseDetails.productID;
              });
            } else {
              // todo handle restored
            }
          }
        }

        if (purchaseDetails.pendingCompletePurchase) {
          debugPrint('purchase pendingCompletePurchase ${purchaseDetails.status}');
          purchaseDetails.pendingCompletePurchase = true;
          await _inAppPurchase.completePurchase(purchaseDetails);
          finishTransaction();
          if (purchaseDetails.status == PurchaseStatus.canceled) {
            showToast(S.current.purchase_cancel);
          }
        }
      }
    }
  }

  Future<void> showLottieDialog(BuildContext context, String name) => showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      builder: (BuildContext context) {
        return Center(child: Lottie.asset(name, repeat: true));
      });

  void showToast(String message) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
        backgroundColor: ThemeColor.primaryColor.shade300,
        // action: SnackBarAction(
        //   label: S.current.resend,
        //   onPressed: () {},
        // ),
      ),
    );
  }

  @override
  void initState() {
    initStoreInfo();
    super.initState();
  }

  @override
  void dispose() {
    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
          _inAppPurchase.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      iosPlatformAddition.setDelegate(null);
      finishTransaction();
    }
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
        key: scaffoldMessengerKey,
        child: Scaffold(
          appBar: CommonAppBar(S.current.premium),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                width: PlatformUtil.isMobile ? 180 : 110,
                height: PlatformUtil.isMobile ? 180 : 110,
                child: Lottie.asset('assets/animation_ll82pe8f.json', repeat: true),
              ),
              const SizedBox(height: 10),
              Text(
                '${S.current.appName} ${S.current.premium_plus_explain}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: _generateFeatureItems(),
              ),
              SizedBox(height: PlatformUtil.isMobile ? 20 : 10),
              if (_products.isEmpty)
                Shimmer.fromColors(
                  baseColor: ThemeColor.backgroundColor,
                  highlightColor: Colors.white12,
                  enabled: true,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _membershipPlaceholder(),
                      _membershipPlaceholder(),
                      _membershipPlaceholder(),
                    ],
                  ),
                ),
              if (_products.isNotEmpty)
                SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                        height: PlatformUtil.isMobile ? 130 : 115,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: _membershipOptions(),
                        ))),
              const SizedBox(height: 24),
              Container(
                  width: 250,
                  height: 50,
                  decoration: BoxDecoration(
                      gradient: gradientColor, borderRadius: const BorderRadiusDirectional.all(Radius.circular(50))),
                  child: ElevatedButton(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        if (isAvailable) {
                          finishTransaction();
                          final PurchaseParam purchaseParam = PurchaseParam(productDetails: _products[_checkedIndex]);
                          // clearCache();
                          _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
                        } else {
                          showToast(S.current.purchase_error);
                        }
                      },
                      style: ButtonStyle(
                        shadowColor: MaterialStateProperty.all<Color>(Colors.transparent),
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
                        elevation: MaterialStateProperty.all(5.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                        child: Text(
                          S.current.subscribe,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ))),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _agreementWidget(S.current.terms_use, () async {
                    await launchUrl(Uri.parse(Urls.termsUrl), mode: LaunchMode.inAppWebView);
                  }),
                  const SizedBox(
                    width: 10,
                  ),
                  _agreementWidget(S.current.privacy_policy, () async {
                    await launchUrl(Uri.parse(Urls.privacyUrl), mode: LaunchMode.inAppWebView);
                  }),
                  const SizedBox(
                    width: 10,
                  ),
                  _agreementWidget(S.current.restore, () {
                    showLottieDialog(context, 'assets/loading.json');
                    _inAppPurchase.restorePurchases();
                  })
                ],
              )
            ],
          ),
        ));
  }

  List<Widget> _generateFeatureItems() {
    List<Widget> widgets = <Widget>[];
    for (var element in _premiumFeatures) {
      widgets.add(Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(
          Icons.task_alt_outlined,
          color: Colors.green,
          size: 16,
        ),
        const SizedBox(
          width: 5,
        ),
        Text(
          element,
          textAlign: TextAlign.start,
          style: const TextStyle(fontSize: 15, color: Colors.grey, fontWeight: FontWeight.bold),
        )
      ]));
    }
    return widgets;
  }

  Widget _membershipPlaceholder() {
    return const Card(margin: EdgeInsets.all(10), child: SizedBox(width: 100, height: 110));
  }

  List<Widget> _membershipOptions() {
    List<Widget> widgets = <Widget>[];
    for (var index = 0; index < _products.length; index++) {
      ProductDetails productDetails = _products[index];
      widgets.add(GestureDetector(
        child: Card(
          elevation: 5,
          shadowColor: index == _checkedIndex ? gradientColor.colors[0] : ThemeColor.backgroundColor,
          margin: const EdgeInsets.all(10),
          child: Container(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
            alignment: AlignmentDirectional.center,
            decoration: BoxDecoration(
                gradient: _checkedIndex == index ? gradientColor : null,
                borderRadius: const BorderRadiusDirectional.all(Radius.circular(10))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Text(
                      productDetails.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w600,
                        color: _checkedIndex == index ? Colors.grey[200] : Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      productDetails.price,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _checkedIndex == index ? Colors.grey[100] : Colors.grey[400],
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      productDetails.description,
                      style: TextStyle(
                        fontSize: 10,
                        color: _checkedIndex == index ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    if (productDetails.id == LocalStorageService().getCurrentMembershipProductId())
                      Text(
                        S.current.current_level,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                  ],
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
        onTap: () {
          HapticFeedback.mediumImpact();
          setState(() {
            _checkedIndex = index;
          });
        },
      ));
    }
    return widgets;
  }

  Widget _agreementWidget(String title, Function pressed) {
    return TextButton(
        onPressed: () {
          pressed();
        },
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            decoration: TextDecoration.underline,
            decorationColor: ThemeColor.textColor,
          ),
        ));
  }
}

class PaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(SKPaymentTransactionWrapper transaction, SKStorefrontWrapper storefront) {
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    return false;
  }
}
