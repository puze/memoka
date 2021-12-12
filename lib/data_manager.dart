import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';

import 'dart:async' show Future;
import 'package:flutter/services.dart' show ByteData, rootBundle;

class DataManager {
  static final DataManager _instance = DataManager._internal();

  factory DataManager() {
    return _instance;
  }

  DataManager._internal() {
    // 초기화
  }

  Future<Excel> readFile() async {
    ByteData data = await rootBundle.load("assets/Question.xlsx");
    var bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    return Excel.decodeBytes(bytes);

    // final excel = Excel.decodeBytes(bytes);
    // for (var table in excel.tables.keys) {
    //   print(table); //sheet Name
    //   print(excel.tables[table]?.maxCols);
    //   print(excel.tables[table]?.maxRows);
    //   for (var row in excel.tables[table]!.rows) {
    //     print("$row");
    //   }
    // }
  }
}
