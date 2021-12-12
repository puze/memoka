import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:memoka/data_manager.dart';
import 'package:memoka/memoka.dart';
import 'package:memoka/memoka_data.dart';

/// 메모카 카드 컨트롤
class MemokaBody extends StatefulWidget {
  const MemokaBody({Key? key}) : super(key: key);

  @override
  _MemokaBodyState createState() => _MemokaBodyState();
}

class _MemokaBodyState extends State<MemokaBody> {
  final GlobalKey _memokaKey = GlobalKey();

  late MemokaData _memokaData;
  late Memoka _memoka;
  late Excel memokaExcel;

  bool goNext = false;
  bool goPrevious = false;

  Offset onDragOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    initMemokaBody();
  }

  Future<Excel> readFile() async {
    // TODO 데이터 널 체크
    return await DataManager().readFile();
  }

  void initMemokaBody() async {
    // TODO 데이터 널 체크
    Excel memokaExcel = await readFile();
    _memokaData = MemokaData(memokaExcel);
    _memoka = instanceMemoka(MemokaStatus.init);

    /// 인스턴스화한 순간은 key의 state가 null임
    /// 해결하기위해 1frame을 skip하고 빌드를 다시함
    // Future.delayed(const Duration(milliseconds: 16), () {
    //   // 첫 애니메이션 실행
    //   WidgetsBinding.instance?.addPostFrameCallback(
    //       (_) => {_memokaKey.currentState?.resetPosition()});
    // });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: readFile(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData == false) {
            return const CircularProgressIndicator();
          } else {
            return Center(child: _memoka);
          }
        });
  }

  void nextCallback() {
    _memokaData.nextMemoka();
    setState(() {
      _memoka = instanceMemoka(MemokaStatus.next);
    });
  }

  void _previousCallback() {
    _memokaData.previousMemoka();
    setState(() {
      _memoka = instanceMemoka(MemokaStatus.previous);
    });
  }

  Memoka instanceMemoka(MemokaStatus memokaStatus) {
    return Memoka(
      key: GlobalKey(),
      front: _memokaData.getFrontValue(),
      back: _memokaData.getBackValue(),
      page: _memokaData.getPage(),
      status: memokaStatus,
      nextCallback: nextCallback,
      previousCallback: _previousCallback,
    );
  }
}
