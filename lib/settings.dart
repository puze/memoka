import 'package:flutter/material.dart';
import 'package:memoka/data_manager.dart';
import 'package:memoka/tools/admob.dart';
import 'package:memoka/tools/theme_colors.dart';

import 'license_route.dart';

class SettingsRoute extends StatelessWidget {
  const SettingsRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: ThemeColors().backgroundColor,
          // elevation: 0,
          leading: MaterialButton(
            onPressed: () => Navigator.pop(context),
            child: const Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
          )),
      backgroundColor: ThemeColors().backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Expanded(
                  flex: 1,
                  child: Center(
                    child: Text(
                      'Coin : ' + DataManager().memokaGroupList!.coin,
                      style: const TextStyle(fontSize: 20),
                    ),
                  )),
              Container(
                height: 1,
                color: Colors.grey,
              ),
              Expanded(
                flex: 9,
                child: ListView(
                  children: [
                    _purchaseAddMemoka(),
                    _watchAd(),
                    _licnesItem(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _licnesItem(BuildContext context) {
    return _listItem(
      () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const LicenseRoute()));
      },
      'License',
    );
  }

  Widget _watchAd() {
    return _listItem(() {
      Admob().showRewardedAd();
    }, 'Watch Ad');
  }

  Widget _purchaseAddMemoka() {
    return _listItem(() {}, '추가 메모카 광고 제거');
  }

  Widget _listItem(VoidCallback onClick, String itemName) {
    return SizedBox(
      height: 50,
      child: InkWell(
        onTap: onClick,
        child: Align(
            alignment: Alignment.centerLeft,
            child: Text(itemName, style: const TextStyle(fontSize: 25))),
      ),
    );
  }
}
