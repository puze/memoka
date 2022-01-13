import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';

import 'dart:async' show Future;
import 'package:flutter/services.dart' show ByteData, rootBundle;

import 'memoka/memoka_data.dart';

class DataManager {
  static final DataManager _instance = DataManager._internal();
  MemokaGroupList? memokaGroupList;
  bool beenInit = false;

  late Excel excelData;

  factory DataManager() {
    return _instance;
  }

  DataManager._internal() {
    // 초기화
  }

  Future<Excel> readAssetFile() async {
    ByteData data = await rootBundle.load("assets/Question.xlsx");
    var bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    excelData = Excel.decodeBytes(bytes);
    return excelData;
  }

  Excel readExternalFile(File file) {
    var bytes = file.readAsBytesSync();
    return Excel.decodeBytes(bytes);
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/data.json');
  }

  Future<void> saveData() async {
    final file = await _localFile;

    file.writeAsString(jsonEncode(memokaGroupList));
  }

  Future<MemokaGroupList?> readData() async {
    try {
      final file = await _localFile;

      if (!file.existsSync()) {
        debugPrint('did not exist file');
        await initData();
      }

      // 파일 읽기.
      String contents = await file.readAsString();
      var jsonData = jsonDecode(contents);
      memokaGroupList = MemokaGroupList.fromJson(jsonData);
      beenInit = true;
      return memokaGroupList;
    } catch (e) {
      debugPrint(e.toString());
      return memokaGroupList;
    }
  }

  Future<void> addExcelData(Excel excel) async {
    // table : sheet name
    for (var table in excel.tables.keys) {
      var memokaGroup = MemokaGroup(memokaCover: table, memokaData: []);
      memokaGroupList!.memokaGroups.add(memokaGroup);
      debugPrint('sheet name : $table'); //sheet Name
      // print(excel.tables[table]?.maxCols);
      // print(excel.tables[table]?.maxRows);
      int index = 0;
      for (var row in excel.tables[table]!.rows) {
        index++;
        MemokaData memokaData =
            MemokaData(front: row[0]?.value, back: row[1]?.value, index: index);
        memokaGroup.memokaData.add(memokaData);
        // debugPrint("$row");
      }
    }
    await saveData();
  }

  Future<void> initData() async {
    final file = await _localFile;
    file.create();
    var assetData = await readAssetFile();
    memokaGroupList =
        MemokaGroupList(coin: '5', welcome: 'false', memokaGroups: []);
    await addExcelData(assetData);
  }

  Future<void> removeMemokaGroup(MemokaGroup memokaGroup) async {
    memokaGroupList!.memokaGroups.remove(memokaGroup);
    await saveData();
  }
}
