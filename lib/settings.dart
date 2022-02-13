import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:memoka/Route/credits_route.dart';
import 'package:memoka/data_manager.dart';
import 'package:memoka/tools/admob.dart';
import 'package:memoka/tools/inapp_purchase.dart';
import 'package:memoka/dialog/popup_dialog.dart';
import 'package:memoka/tools/theme_colors.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:collection/collection.dart';

import 'Route/license_route.dart';

class SettingsRoute extends StatefulWidget {
  const SettingsRoute({Key? key}) : super(key: key);

  @override
  State<SettingsRoute> createState() => _SettingsRouteState();
}

class _SettingsRouteState extends State<SettingsRoute> {
  Widget versionWidget = Text('');
  String coinValue = 'Coin : 0';
  @override
  void initState() {
    _loadVersionWidget();
    _refreashCoinValue();
    super.initState();
  }

  void _refreashCoinValue() {
    if (DataManager().isRemoveAds()) {
      coinValue = '광고가 제거 되었습니다.';
    } else {
      coinValue = 'Coin : ' + DataManager().memokaGroupList!.coin;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 3,
        backgroundColor: ThemeColors.backgroundColor,
        // elevation: 0,
        leading: MaterialButton(
            onPressed: () => Navigator.pop(context),
            child: SizedBox(
                height: 23, child: Image.asset('assets/moca_icon/back.png'))),
        title: Text(
          'Setting',
          style: TextStyle(color: ThemeColors.textColor, fontSize: 23),
        ),
        centerTitle: true,
      ),
      backgroundColor: ThemeColors.backgroundColor,
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Expanded(
                      flex: 1,
                      child: Center(
                        child: Text(
                          coinValue,
                          style: TextStyle(
                              fontSize: 23,
                              color: ThemeColors.textColor,
                              fontWeight: FontWeight.bold),
                        ),
                      )),
                  Container(
                      height: 1,
                      color: const Color.fromARGB(100, 111, 118, 103)),
                  Expanded(
                    flex: 9,
                    child: ListView(
                      padding: const EdgeInsets.all(15),
                      children: [
                        _purchaseAddMemoka(),
                        _watchAd(),
                        _helpItem(),
                        _licnesItem(),
                        _creditItem(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(bottom: 30, child: versionWidget)
          ],
        ),
      ),
    );
  }

  // Widget _appBar() {
  //   return Material(
  //     elevation: 10,
  //     child: Container(height: 56),
  //   );
  // }

  Widget _licnesItem() {
    return _listItem(
      () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const LicenseRoute()));
      },
      '라이센스',
    );
  }

  Widget _watchAd() {
    return _listItem(() {
      Admob().showRewardedAd(state: this);
    }, '광고 보고 코인 얻기');
  }

  Widget _purchaseAddMemoka() {
    return _listItem(() async {
      var productDetails = MyInappPurchase().productDetails;
      ProductDetails? product = productDetails
          .firstWhereOrNull((element) => element.id == 'add_memoka_ad_remove');
      if (product != null) {
        final PurchaseParam purchaseParam =
            PurchaseParam(productDetails: product);
        await InAppPurchase.instance
            .buyNonConsumable(purchaseParam: purchaseParam);
      } else {
        Navigator.push(
            context,
            PopupDialog(
                message: '구매 중 오류가 발생 하였습니다.\n잠시 후 다시 시도해 주세요.\ncode:3'));
      }
    }, '메모카 광고 제거');
  }

  Widget _testWidget() {
    return _listItem(() {
      Navigator.push(context, PopupDialog(message: 'test page'));
    }, 'test item');
  }

  Widget _creditItem() {
    return _listItem(() {
      Navigator.push(context, MaterialPageRoute(
        builder: (context) {
          return const CreditsRoute();
        },
      ));
    }, '만든이');
  }

  Widget _helpItem() {
    return _listItem(() {
      Navigator.push(context, PopupDialog(message: '도움말 다시 보기가 활성화 되었습니다.'));
      DataManager().setTutorial(false);
    }, '도움말 다시 보기');
  }

  Widget _listItem(VoidCallback onClick, String itemName) {
    return GestureDetector(
      onTap: onClick,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 50,
        child: Row(
          children: [
            Expanded(
              flex: 9,
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(itemName,
                      style: TextStyle(
                          fontSize: 20, color: ThemeColors.textColor))),
            ),
            Expanded(
                flex: 1,
                child: SizedBox(
                    height: 22,
                    child: Image.asset('assets/moca_icon/next_button.png')))
          ],
        ),
      ),
    );
  }

  Future<void> _loadVersionWidget() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String appName = packageInfo.appName;
    String packageName = packageInfo.packageName;
    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;
    setState(() {
      versionWidget = Column(
        children: [
          settingStyleText('version : $version'),
          if (kDebugMode) settingStyleText('build Number : $buildNumber')
        ],
      );
    });
  }

  Widget settingStyleText(String text) {
    return Text(
      text,
      style: TextStyle(color: ThemeColors.textColor),
    );
  }
}
