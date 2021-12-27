import 'dart:convert';
import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:memoka/data_manager.dart';
import 'package:memoka/memoka_home.dart';
import 'package:memoka/memoka/memoka.dart';
import 'package:memoka/memoka/memoka_body.dart';
import 'package:memoka/memoka/memoka_data.dart';
import 'package:memoka/memoka/memoka_group_data.dart';

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
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: FutureBuilder(
              future: initData(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData == false) {
                  return const CircularProgressIndicator();
                } else {
                  return Center(child: MemokaHome());
                }
              }),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickFile,
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> _pickFile() async {
    String? result;
    try {
      setState(() {
        _isBusy = true;
        _currentFile = null;
      });
      final params = OpenFileDialogParams(
        dialogType: OpenFileDialogType.document,
        sourceType: SourceType.photoLibrary,
      );
      result = await FlutterFileDialog.pickFile(params: params);
      print(result);
    } on PlatformException catch (e) {
      print(e);
    } finally {
      setState(() {
        _pickedFilePath = result;
        if (result != null) {
          _currentFile = File(result);
          var excelFile = DataManager().readExternalFile(_currentFile!);
          DataManager().addExcelData(excelFile);
        } else {
          _currentFile = null;
        }
        _isBusy = false;
      });
    }
  }
}
