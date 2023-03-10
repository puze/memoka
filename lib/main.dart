import 'dart:io';
import 'dart:ui';

// import 'package:admob_flutter/admob_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:memoka/data_manager.dart';
import 'package:memoka/dialog/add_memoca_dialog.dart';
import 'package:memoka/memoka/memoka_data.dart';
import 'package:memoka/settings.dart';
import 'package:memoka/tools/admob.dart';
import 'package:memoka/tools/dismiss_keyboard.dart';
import 'package:memoka/tutorials.dart';

import 'memoka/memoka_body.dart';
import 'memoka/memoka_cover.dart';
import 'tools/inapp_purchase.dart';
import 'tools/theme_colors.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();

// RewardedAd.load(
//   adUnitId: 'ca-app-pub-7658460612630664/2348277849',
//   request: AdRequest(),
//   rewardedAdLoadCallback: RewardedAdLoadCallback(
//     onAdLoaded: (RewardedAd ad) {
//       print('$ad loaded.');
//       // Keep a reference to the ad so you can show it later.
//       this._rewardedAd = ad;
//     },
//     onAdFailedToLoad: (LoadAdError error) {
//       print('RewardedAd failed to load: $error');
//     },
// );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DismissKeyboard(
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.grey,
        ),
        home: const MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? _currentFile;
  final List<GlobalKey<MemokaCoverState>> _memokaKeyList = [];
  bool _isMemokaRemoveIcon = false;
  bool _isTuotorial = false;
  Widget _removeMemokaIcon = Container();
  Widget _removeCancelArea = Container();
  final double entirePadding = 20;

  @override
  void initState() {
    super.initState();
    Admob().initAdmob();
    MyInappPurchase().setContext(context);
    MyInappPurchase().fetch();
    _init();
  }

  @override
  void dispose() {
    super.dispose();
    Admob().dispose();
    MyInappPurchase().dispose();
  }

  Future<MemokaGroupList> initData() async {
    if (DataManager().beenInit) return DataManager().memokaGroupList!;
    // ????????? ????????? ?????????
    MemokaGroupList? data = await DataManager().readData();
    _refreshKeyList();
    return data!;
  }

  void _init() async {
    await initData();
    welcomeRoutine(DataManager().memokaGroupList);
    _tutorial();
  }

  void welcomeRoutine(MemokaGroupList? data) {
    if (data!.welcome != 'true') {
      data.welcome = 'true';
      data.coin = '3';
      debugPrint('Wellcome to memoca');
    }

    debugPrint('coin : ' + data.coin);
  }

  void _tutorial() {
    if (!DataManager().isTutorial()) {
      setState(() {
        _isTuotorial = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.backgroundColor,
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            _memokaFutureBuilder(),
            Visibility(visible: _isMemokaRemoveIcon, child: _removeCancelArea),
            Visibility(visible: _isMemokaRemoveIcon, child: _removeMemokaIcon),
            _tutorialWidget(context),
          ],
        ),
      ),
      floatingActionButton: RawMaterialButton(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(
            builder: (context) {
              return const SettingsRoute();
            },
          ));
          _init();
          setState(() {});
        },
        child: SizedBox(
            width: 50,
            child: Image.asset('assets/moca_icon/setting_button.png')),
        constraints: const BoxConstraints(
            minWidth: 50, minHeight: 50, maxHeight: 70, maxWidth: 70),
      ),
    );
  }

  Visibility _tutorialWidget(BuildContext context) {
    return Visibility(
        visible: _isTuotorial,
        child: GestureDetector(
            onTap: () {
              setState(() {
                _isTuotorial = false;
              });
            },
            child: Tutorials.getMainTutorialOverlay(context)));
  }

  FutureBuilder<MemokaGroupList> _memokaFutureBuilder() {
    return FutureBuilder(
        future: initData(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData == false) {
            return const Center(child: CircularProgressIndicator());
          } else {
            var memokaData = DataManager().memokaGroupList;

            /*24 is for notification bar on Android*/
            // var size = MediaQuery.of(context).size;
            // final double itemHeight = (size.height - kToolbarHeight - 24) / 8;
            // final double itemWidth = size.width / 2;

            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: entirePadding,
                  mainAxisSpacing: entirePadding,
                  childAspectRatio: 264 / 193),
              padding: EdgeInsets.all(entirePadding),
              //+1??? ?????? ??????
              itemCount: memokaData!.memokaGroups.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _addMemokaIcon();
                } else {
                  int memokaIndex = index - 1;
                  String cover =
                      memokaData.memokaGroups[memokaIndex].memokaCover;
                  return GestureDetector(
                    child: MemokaCover(
                      key: _memokaKeyList[memokaIndex],
                      coverText: cover,
                      memokaGroup: memokaData.memokaGroups[memokaIndex],
                    ),
                    onLongPress: () {
                      // ?????? ?????? ??????
                      if (_isMemokaRemoveIcon) return;
                      _isMemokaRemoveIcon = true;
                      _memokaKeyList[memokaIndex]
                          .currentState!
                          .onLongPressMemokaCover();
                      _setRemoveMemokaIcon(window, context,
                          memokaData.memokaGroups[memokaIndex], memokaIndex);
                      _setRemoveCancelArea(
                          context, _memokaKeyList[memokaIndex].currentState!);
                    },
                  );
                }
              },
            );
          }
        });
  }

  void _refreshKeyList() {
    _memokaKeyList.clear();
    for (var _ in DataManager().memokaGroupList!.memokaGroups) {
      _memokaKeyList.add(GlobalKey<MemokaCoverState>());
    }
  }

  int calculateXPos(int index) {
    return index % 2 == 1 ? 5 : 1;
  }

  /// ????????? ?????? ?????????
  void _setRemoveMemokaIcon(SingletonFlutterWindow window, BuildContext context,
      MemokaGroup memokaGroup, int index) {
    // (?????? ???????????? -3*??????)/????????? ????????? ?????? /????????? ?????? ??????
    double iconSize =
        (MediaQuery.of(context).size.width - 3 * entirePadding) / 2 / 3;
    RenderBox? renderBox =
        _memokaKeyList[index].currentContext!.findRenderObject() as RenderBox;
    double xOffset =
        (MediaQuery.of(context).size.width - 3 * entirePadding) / 2;
    double yOffset = renderBox.size.height / 2;
    Offset offset = Offset(xOffset, yOffset);
    Offset position = renderBox.localToGlobal(Offset.zero);
    Size size = MediaQuery.of(context).size;
    setState(() {
      final double statusBarHeight = MediaQuery.of(context).viewPadding.top;
      final statusbarHeight2 = MediaQueryData.fromWindow(window).padding.top;
      _removeMemokaIcon = Positioned(
        // left: iconSize * calculateXPos(index),
        left: position.dx + (size.width - 3 * entirePadding) / 4 - iconSize / 2,
        top: position.dy -
            statusbarHeight2 +
            (size.width - 3 * entirePadding) / 2 * 193 / 264 / 2 -
            iconSize / 2,
        // position.dy - iconSize / 2,
        // position.dy - 8,
        // top: (MediaQuery.of(context).size.height - kToolbarHeight - 24) /
        //     8 *
        //     ((index / 2).floor() + 1 / 2),
        // top: position.dy - iconSize / 2,

        width: iconSize,
        height: iconSize,
        child: RawMaterialButton(
          onPressed: () {
            _refreshKeyList();
            setState(() {
              _isMemokaRemoveIcon = false;
              DataManager().removeMemokaGroup(memokaGroup);
            });
          },
          elevation: 2.0,
          child: Image.asset('assets/moca_icon/remove_memoca.png'),
        ),
      );
    });
  }

  void _setRemoveCancelArea(BuildContext context, MemokaCoverState state) {
    _removeCancelArea = Positioned(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: GestureDetector(
          onTap: () {
            setState(() {
              _isMemokaRemoveIcon = false;
              state.isRemoveButtonVisibility = false;
            });
          },
          child: Container(
            color: Colors.transparent,
          ),
        ));
  }

  Widget _addMemokaIcon() {
    return RawMaterialButton(
      onPressed: _addMemoka,
      child: Image.asset('assets/moca_icon/add_memoka.png'),
    );
  }

  void _addMemoka() {
    int coin = int.parse(DataManager().memokaGroupList!.coin);
    // ???????????? ????????? ?????????
    if (!DataManager().isRemoveAds()) {
      // ????????? ?????? ?????? ?????? ??????
      if (coin <= 0) {
        Admob().showRewardedAd();
        return;
      }
    }

    Navigator.push(
        context,
        AddMemocaDialog(
            addEmptyMemoca: _addEmptyMemoca, addExcelFile: _pickFile));
  }

  void _addEmptyMemoca() {
    DataManager().useCoin();
    setState(() {
      _refreshKeyList();
    });

    var memokaGroups = DataManager().memokaGroupList!.memokaGroups;

    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => Scaffold(
                  body: MemokaBody(
                memokaGroup: memokaGroups[memokaGroups.length - 1],
              ))),
    );
  }

  /// ???????????? ????????????
  Future<void> _pickFile() async {
    FilePickerResult? result;
    try {
      // setState(() {
      //   _isBusy = true;
      //   _currentFile = null;
      // });
      _isMemokaRemoveIcon = false;
      result = await FilePicker.platform
          .pickFiles(type: FileType.custom, allowedExtensions: ['xls', 'xlsx']);
    } on PlatformException catch (e) {
      debugPrint(e.message);
    } finally {
      if (result != null) {
        _currentFile = File(result.files.single.path!);
        var excelFile = DataManager().readExternalFile(_currentFile!);
        // addExcelData?????? ???????????????
        DataManager().useCoin();
        debugPrint('coin : ' + DataManager().memokaGroupList!.coin);
        await DataManager().addExcelData(excelFile);

        var memokaGroups = DataManager().memokaGroupList!.memokaGroups;

        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Scaffold(
                      body: MemokaBody(
                    memokaGroup: memokaGroups[memokaGroups.length - 1],
                  ))),
        );
      } else {
        // User canceled the picker
        _currentFile = null;
      }
      // _isBusy = false;
      setState(() {
        _refreshKeyList();
      });
    }
  }
}
