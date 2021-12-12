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

class _MemokaBodyState extends State<MemokaBody>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Alignment> _animation;
  Alignment _dragAlignment = Alignment.center;

  // 드래그 임계치
  final double threshold = 50;
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<Excel> readFile() async {
    // TODO 데이터 널 체크
    return await DataManager().readFile();
  }

  void initMemokaBody() async {
    // TODO 데이터 널 체크
    Excel memokaExcel = await readFile();
    _memokaData = MemokaData(memokaExcel);
    _memoka = instanceMemoka();

    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _controller.addListener(() {
      setState(() {
        _dragAlignment = _animation.value;
      });
    });

    /// 인스턴스화한 순간은 key의 state가 null임
    /// 해결하기위해 1frame을 skip하고 빌드를 다시함
    // Future.delayed(const Duration(milliseconds: 16), () {
    //   // 첫 애니메이션 실행
    //   WidgetsBinding.instance?.addPostFrameCallback(
    //       (_) => {_memokaKey.currentState?.resetPosition()});
    // });
  }

  double _dx = 0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return FutureBuilder(
        future: readFile(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData == false) {
            return const CircularProgressIndicator();
          } else {
            return Center(
              child: GestureDetector(
                  onPanDown: (details) {
                    _dx = 0;
                    _controller.stop();
                  },
                  onPanUpdate: (details) {
                    setState(() {
                      _dragAlignment += Alignment(
                        details.delta.dx / (size.width / 8),
                        details.delta.dy / (size.height / 2),
                      );
                    });
                    _dx += details.delta.dx;
                  },
                  onPanEnd: (details) {
                    debugPrint('dx : ' + _dx.toString());
                    if (_dx < -threshold) {
                      _runNextAnimation();
                    } else if (_dx > threshold) {
                      _runPreviousAnimation();
                    } else {
                      _runReturnAnimation();
                    }
                  },
                  child: Align(alignment: _dragAlignment, child: _memoka)),
            );
          }
        });
  }

  Memoka instanceMemoka() {
    return Memoka(
      key: GlobalKey(),
      front: _memokaData.getFrontValue(),
      back: _memokaData.getBackValue(),
      page: _memokaData.getPage(),
    );
  }

  void _runReturnAnimation() {
    _animation = _controller.drive(
      AlignmentTween(
        begin: _dragAlignment,
        end: Alignment.center,
      ),
    );
    _controller.reset();
    _controller.forward();
  }

  void _runNextAnimation() {
    _animation = _controller.drive(
      AlignmentTween(
        begin: _dragAlignment,
        end: Alignment(-10, 0),
      ),
    );
    _controller.reset();
    _controller.forward();
  }

  void _runPreviousAnimation() {
    _animation = _controller.drive(
      AlignmentTween(
        begin: _dragAlignment,
        end: Alignment(10, 0),
      ),
    );
    _controller.reset();
    _controller.forward();
  }
}
