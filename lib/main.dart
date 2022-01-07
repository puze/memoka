import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:memoka/data_manager.dart';
import 'package:memoka/license_route.dart';
import 'package:memoka/listener_outside_tap.dart';
import 'package:memoka/memoka/memoka_data.dart';

import 'memoka/memoka_cover.dart';
import 'tools/theme_colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
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
  bool _isBusy = false;
  File? _currentFile;
  String? _pickedFilePath;
  List<GlobalKey<MemokaCoverState>> _memokaKeyList = [];
  bool _isMemokaRemoveIcon = false;
  Widget _removeMemokaIcon = Container();
  Widget _removeCancelArea = Container();
  final double entirePadding = 20;

  @override
  void initState() {
    super.initState();
  }

  Future<MemokaGroupList> initData() async {
    if (DataManager().beenInit) return DataManager().memokaGroupList;
    // 데이터메니저 초기화
    var data = await DataManager().readData();
    _refreshKeyList();
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors().backgroundColor,
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LicenseRoute()));
              },
              icon: const Icon(Icons.settings))
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(entirePadding, 0, entirePadding, 0),
          child: Stack(
            children: [
              _memokaFutureBuilder(),
              Visibility(
                  visible: _isMemokaRemoveIcon, child: _removeCancelArea),
              Visibility(visible: _isMemokaRemoveIcon, child: _removeMemokaIcon)
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickFile,
        child: const Icon(Icons.add),
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
            var size = MediaQuery.of(context).size;
            final double itemHeight = (size.height - kToolbarHeight - 24) / 8;
            final double itemWidth = size.width / 2;

            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: entirePadding,
                  mainAxisSpacing: entirePadding,
                  childAspectRatio: 1.2),
              itemCount: memokaData.memokaGroups.length,
              itemBuilder: (context, index) {
                String cover = memokaData.memokaGroups[index].memokaCover;
                return GestureDetector(
                  child: MemokaCover(
                    key: _memokaKeyList[index],
                    coverText: cover,
                    memokaGroup: memokaData.memokaGroups[index],
                  ),
                  onLongPress: () {
                    _isMemokaRemoveIcon = true;
                    _memokaKeyList[index]
                        .currentState!
                        .onLongPressMemokaCover();
                    _setRemoveMemokaIcon(
                        context, memokaData.memokaGroups[index], index);
                    _setRemoveCancelArea(
                        context, _memokaKeyList[index].currentState!);
                  },
                );
              },
            );
          }
        });
  }

  void _refreshKeyList() {
    _memokaKeyList.clear();
    for (var _ in DataManager().memokaGroupList.memokaGroups) {
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

    setState(() {
      _removeMemokaIcon = Positioned(
        left: iconSize * calculateXPos(index),
        top: (MediaQuery.of(context).size.height - kToolbarHeight - 24) /
            8 *
            ((index / 2).floor() + 1 / 2),
        child: RawMaterialButton(
          onPressed: () {
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
            color: Color.fromARGB(95, 255, 55, 55),
          ),
        ));
  }

  // 외부파일 불러오기
  Future<void> _pickFile() async {
    FilePickerResult? result;
    try {
      // setState(() {
      //   _isBusy = true;
      //   _currentFile = null;
      // });
      result = await FilePicker.platform
          .pickFiles(type: FileType.custom, allowedExtensions: ['xls', 'xlsx']);
      print(result);
    } on PlatformException catch (e) {
      print(e);
    } finally {
      if (result != null) {
        _currentFile = File(result.files.single.path!);
        var excelFile = DataManager().readExternalFile(_currentFile!);
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
}
