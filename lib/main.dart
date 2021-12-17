import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:memoka/data_manager.dart';
import 'package:memoka/home.dart';
import 'package:memoka/memoka/memoka.dart';
import 'package:memoka/memoka/memoka_body.dart';

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
  @override
  void initState() {
    super.initState();
    initData();
  }

  Future<Excel> initData() async {
    // 데이터메니저 초기화
    return await DataManager().readFile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: initData(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData == false) {
              return const CircularProgressIndicator();
            } else {
              return Center(child: MemokaHome());
            }
          }),
    );
  }
}
