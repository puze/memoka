import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:memoka/data_manager.dart';
import 'package:memoka/memoka/memoka.dart';
import 'package:memoka/memoka/memoka_data.dart';
import 'package:memoka/memoka/memoka_group_data.dart';
import 'package:memoka/tools/theme_colors.dart';

/// 메모카 카드 컨트롤
class MemokaBody extends StatefulWidget {
  final MemokaGroup memokaGroup;
  const MemokaBody({Key? key, required this.memokaGroup}) : super(key: key);

  @override
  _MemokaBodyState createState() => _MemokaBodyState();
}

class _MemokaBodyState extends State<MemokaBody> {
  final GlobalKey _memokaKey = GlobalKey();

  late MemokaGroupData _memokaData;
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

  void initMemokaBody() async {
    _memokaData = MemokaGroupData(widget.memokaGroup);
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
    return Scaffold(
        backgroundColor: ThemeColors().backgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              _topBar(),
              Expanded(child: _memoka),
            ],
          ),
        ));
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

  Widget _topBar() {
    return Container(
      height: 56,
      child: Row(
        children: [
          Expanded(child: SizedBox(height: 40, child: _backIcon())),
          Expanded(child: SizedBox(height: 40, child: _starigtIcon())),
          Expanded(child: SizedBox(height: 40, child: _shuffleIcon()))
        ],
      ),
    );
  }

  Widget _backIcon() {
    return IconButton(
      icon: Image.asset('assets/moca_icon/back.png'),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
  }

  Widget _starigtIcon() {
    return IconButton(
      icon: Image.asset('assets/moca_icon/straight.png'),
      onPressed: () {},
    );
  }

  Widget _shuffleIcon() {
    return IconButton(
      icon: Image.asset('assets/moca_icon/shuffle.png'),
      onPressed: () {},
    );
  }
}
