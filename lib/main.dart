import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:memoka/data_manager.dart';
import 'package:memoka/license_route.dart';
import 'package:memoka/listener_outside_tap.dart';
import 'package:memoka/memoka/memoka_data.dart';

import 'memoka/memoka_cover.dart';

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
  MemokaCoverState? previousMemokaState;

  @override
  void initState() {
    super.initState();
  }

  Future<MemokaGroupList> initData() async {
    // 데이터메니저 초기화
    var data = await DataManager().readData();
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ListenerOutsideTap().onClickOutsideTap,
      child: Scaffold(
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
          child: Center(
            child: FutureBuilder(
                future: initData(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData == false) {
                    return const CircularProgressIndicator();
                  } else {
                    var memokaData = DataManager().memokaGroupList;
                    return GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: memokaData.memokaGroups.length,
                      itemBuilder: (context, index) {
                        String cover =
                            memokaData.memokaGroups[index].memokaCover;
                        return MemokaCover(
                          key: GlobalKey(),
                          coverText: cover,
                          memokaGroup: memokaData.memokaGroups[index],
                          onLognPressCallback: clearRemoveButton,
                          removeMemokaCallback: removeMemoka,
                        );
                      },
                    );
                  }
                }),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _pickFile,
          child: const Icon(Icons.add),
        ),
      ),
    );
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
      previousMemokaState = null;
      setState(() {});
    }
  }

  void clearRemoveButton(MemokaCoverState? memokaCoverState) {
    if (previousMemokaState != null) {
      previousMemokaState!.listenerOutSideTap();
    }
    previousMemokaState = memokaCoverState;
  }

  void removeMemoka() {
    setState(() {
      previousMemokaState = null;
    });
  }
}
