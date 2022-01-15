import 'dart:io';

// import 'package:admob_flutter/admob_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:memoka/data_manager.dart';
import 'package:memoka/memoka/memoka_data.dart';
import 'package:memoka/settings.dart';
import 'package:memoka/tools/admob.dart';

import 'memoka/memoka_cover.dart';
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
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  Widget _removeMemokaIcon = Container();
  Widget _removeCancelArea = Container();
  final double entirePadding = 20;

  @override
  void initState() {
    super.initState();
    Admob().initAdmob();
    welcomeRoutine(DataManager().memokaGroupList);
  }

  @override
  void dispose() {
    super.dispose();
    Admob().dispose();
  }

  Future<MemokaGroupList> initData() async {
    if (DataManager().beenInit) return DataManager().memokaGroupList!;
    // 데이터 매니저 초기화
    MemokaGroupList? data = await DataManager().readData();
    _refreshKeyList();
    return data!;
  }

  Stream<void> welcomeRoutine(MemokaGroupList? data) async* {
    // 초기화 대기
    while (!DataManager().beenInit) {
      yield 0;
    }

    if (data!.welcome != 'true') {
      data.welcome = 'true';
      data.coin = '3';
      debugPrint('Wellcome to memoca');
    }

    debugPrint('coin : ' + data.coin);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors().backgroundColor,
      // appBar: AppBar(
      //   actions: [
      //     IconButton(
      //         onPressed: () {
      //           Navigator.push(
      //               context,
      //               MaterialPageRoute(
      //                   builder: (context) => const LicenseRoute()));
      //         },
      //         icon: const Icon(Icons.settings))
      //   ],
      // ),
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            _memokaFutureBuilder(),
            Visibility(visible: _isMemokaRemoveIcon, child: _removeCancelArea),
            Visibility(visible: _isMemokaRemoveIcon, child: _removeMemokaIcon)
          ],
        ),
      ),
      floatingActionButton: RawMaterialButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) {
              return const SettingsRoute();
            },
          ));
        },
        child: const Icon(Icons.settings),
        constraints: const BoxConstraints(
            minWidth: 50, minHeight: 50, maxHeight: 70, maxWidth: 70),
      ),
    );
  }

  FutureBuilder<MemokaGroupList> _memokaFutureBuilder() {
    return FutureBuilder(
        future: initData(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData == false) {
            return const CircularProgressIndicator();
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
              //+1은 추가 버튼
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
                      _isMemokaRemoveIcon = true;
                      _memokaKeyList[memokaIndex]
                          .currentState!
                          .onLongPressMemokaCover();
                      _setRemoveMemokaIcon(context,
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

  /// 메모카 삭제 아이콘
  void _setRemoveMemokaIcon(
      BuildContext context, MemokaGroup memokaGroup, int index) {
    // (가로 전체길이 -3*패딩)/한줄의 아이템 개수 /아이템 대비 비율
    double iconSize =
        (MediaQuery.of(context).size.width - 3 * entirePadding) / 2 / 3;
    RenderBox? renderBox =
        _memokaKeyList[index].currentContext!.findRenderObject() as RenderBox;
    Offset position = renderBox.localToGlobal(Offset.zero);
    setState(() {
      _removeMemokaIcon = Positioned(
        // left: iconSize * calculateXPos(index),
        left: position.dx + 2 * entirePadding,
        // top: (MediaQuery.of(context).size.height - kToolbarHeight - 24) /
        //     8 *
        //     ((index / 2).floor() + 1 / 2),
        top: position.dy,
        child: RawMaterialButton(
          onPressed: () {
            _refreshKeyList();
            setState(() {
              _isMemokaRemoveIcon = false;
              DataManager().removeMemokaGroup(memokaGroup);
            });
          },
          elevation: 2.0,
          fillColor: Colors.white,
          shape: const CircleBorder(),
          child: const Icon(Icons.remove),
          constraints: BoxConstraints(minWidth: iconSize, minHeight: iconSize),
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

  /// 외부파일 불러오기
  Future<void> _pickFile() async {
    // 코인이 없을 경우 광고 시청
    int coin = int.parse(DataManager().memokaGroupList!.coin);
    if (coin <= 0) {
      Admob().showRewardedAd();
      return;
    }

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
        // addExcelData에서 데이터저장
        DataManager().memokaGroupList!.coin = (coin - 1).toString();
        debugPrint('coin : ' + DataManager().memokaGroupList!.coin);
        await DataManager().addExcelData(excelFile);
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

  Widget _addMemokaIcon() {
    return RawMaterialButton(
      onPressed: _pickFile,
      child: Image.asset('assets/moca_icon/add_memoka.png'),
    );
  }
}
