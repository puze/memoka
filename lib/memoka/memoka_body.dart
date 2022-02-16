import 'dart:ui';

import 'package:dotted_border/dotted_border.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:memoka/dialog/add_voca_route.dart';
import 'package:memoka/data_manager.dart';
import 'package:memoka/memoka/memoka.dart';
import 'package:memoka/memoka/memoka_data.dart';
import 'package:memoka/memoka/memoka_group_data.dart';
import 'package:memoka/tools/theme_colors.dart';
import 'package:memoka/tutorials.dart';

/// 메모카 카드 컨트롤
class MemokaBody extends StatefulWidget {
  final MemokaGroup memokaGroup;
  const MemokaBody({Key? key, required this.memokaGroup}) : super(key: key);

  @override
  _MemokaBodyState createState() => _MemokaBodyState();
}

class _MemokaBodyState extends State<MemokaBody> {
  GlobalKey<MemokaState> _memokaKey = GlobalKey();
  GlobalKey<MemokaState>? _previousMemokaKey;

  late MemokaGroupData _memokaData;
  late Memoka _memoka;
  bool _isTutorial = false;
  Memoka? _previousMemoka;
  late Excel memokaExcel;

  bool goNext = false;
  bool goPrevious = false;
  bool _isShuffleBusy = false;

  Offset onDragOffset = Offset.zero;

// 셔플 시 복수 메모카 컨트롤
  final List<Widget> _memokaArray = [];

  @override
  void initState() {
    super.initState();
    initMemokaBody();
    _tutorial();
  }

  void initMemokaBody() async {
    _memokaData = MemokaGroupData(widget.memokaGroup);
    _memokaData.setLastPage();
    if (_memokaData.isEmpty) {
      Future.delayed(const Duration(milliseconds: 16), () {
        WidgetsBinding.instance?.addPostFrameCallback((_) {
          _setEmptymoeka();
          setState(() {});
        });
      });
    } else {
      _memoka = instanceMemoka(MemokaStatus.init);
      _memokaArray.add(_memoka);
    }

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
      resizeToAvoidBottomInset: false,
      backgroundColor: ThemeColors.backgroundColor,
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: SafeArea(
            child: Stack(
          children: [
            _bodyWidget(),
            _tutorialWidget(),
          ],
        )),
      ),
      floatingActionButton: RawMaterialButton(
        onPressed: _openAddPopup,
        child:
            SizedBox(width: 60, child: Image.asset('assets/moca_icon/add.png')),
        constraints: const BoxConstraints(
            minWidth: 50, minHeight: 50, maxHeight: 70, maxWidth: 70),
      ),
    );
  }

  void _openAddPopup() async {
    var addData = await Navigator.push(context, AddVocaRoute());
    if (addData == null) {
      return;
    }
    AddVocaData addVocaData = addData;

    // 메모카가 비어있다면 추가 후 추가 메모카 표시
    bool isEmpty = false;
    if (_memokaData.isEmpty) {
      isEmpty = true;
    }
    _memokaData.addData(addVocaData.front, addVocaData.back);

    if (isEmpty) {
      setState(() {
        _memokaArray.clear();
        _memoka = instanceMemoka(MemokaStatus.next);
        _memokaArray.add(_memoka);
      });
    }

    debugPrint(addData.toString());
  }

  Widget _bodyWidget() {
    var size = MediaQuery.of(context).size;
    if (size.width < size.height) {
      return Column(
        children: [
          SizedBox(
            height: 56,
            child: Row(
              children: [
                Expanded(child: SizedBox(height: 40, child: _backIcon())),
                Expanded(child: SizedBox(height: 40, child: _straigtIcon())),
                Expanded(child: SizedBox(height: 40, child: _shuffleIcon()))
              ],
            ),
          ),
          SizedBox(
              height: size.height -
                  56 -
                  10 -
                  MediaQueryData.fromWindow(window).padding.top,
              child: Stack(
                alignment: Alignment.center,
                children: _memokaArray,
              )),
          const SizedBox(
            height: 10,
          )
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(
              child: Stack(
            alignment: Alignment.center,
            children: _memokaArray,
          )),
          SizedBox(
            width: 56,
            child: Column(children: [
              Expanded(
                  child: SizedBox(
                child: _backIcon(),
              )),
              Expanded(
                  child: SizedBox(
                child: _straigtIcon(),
              )),
              Expanded(
                  child: SizedBox(
                child: _shuffleIcon(),
              ))
            ]),
          )
        ],
      );
    }
  }

  void nextCallback() {
    _memokaData.nextMemoka();
    setState(() {
      _memokaArray.clear();
      _memokaKey = GlobalKey();
      _memoka = instanceMemoka(MemokaStatus.next);
      _memokaArray.add(_memoka);
    });
  }

  void _previousCallback() {
    _memokaData.previousMemoka();
    setState(() {
      _memokaArray.clear();
      _memokaKey = GlobalKey();
      _memoka = instanceMemoka(MemokaStatus.previous);
      _memokaArray.add(_memoka);
    });
  }

  void _removeCallback() {
    _memokaData.removeMemoka();
    setState(() {
      _memokaArray.clear();
      _memokaKey = GlobalKey();
      if (_memokaData.isEmpty) {
        _setEmptymoeka();
      } else {
        _memoka = instanceMemoka(MemokaStatus.next);
        _memokaArray.add(_memoka);
      }
    });
  }

  void _shuffleMiddleCallback() {
    setState(() {
      _memokaArray.remove(_previousMemoka);
      _memokaArray.insert(0, _previousMemoka!);
    });
  }

  void _shuffleEndCallback() {
    _isShuffleBusy = false;
    setState(() {
      _memokaArray.remove(_previousMemoka);
    });
  }

  void _shuffle() async {
    _isShuffleBusy = true;
    _previousMemoka = _memoka;
    _previousMemokaKey = _memokaKey;
    _memokaKey = GlobalKey();
    _memokaData.shuffleMemoka();
    _memokaData.setIndexMemoka(0);
    _memoka = instanceMemoka(MemokaStatus.init);
    _memokaArray.insert(0, _memoka);

    /// 해결하기위해 1frame을 skip하고 빌드를 다시함
    Future.delayed(const Duration(milliseconds: 16), () {
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        _previousMemokaKey!.currentState!.shuffleFront();
        _memokaKey.currentState!.shuffleBack();
      });
    });

    setState(() {});
  }

  void _straight() async {
    _isShuffleBusy = true;
    _previousMemoka = _memoka;
    _previousMemokaKey = _memokaKey;
    _memokaKey = GlobalKey();
    _memokaData.straightMemoka();
    _memokaData.setIndexMemoka(0);
    _memoka = instanceMemoka(MemokaStatus.init);
    _memokaArray.insert(0, _memoka);

    /// 해결하기위해 1frame을 skip하고 빌드를 다시함
    Future.delayed(const Duration(milliseconds: 16), () {
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        _previousMemokaKey!.currentState!.shuffleFront();
        _memokaKey.currentState!.shuffleBack();
      });
    });

    setState(() {});
  }

  Memoka instanceMemoka(MemokaStatus memokaStatus) {
    return Memoka(
      key: _memokaKey,
      front: _memokaData.getFrontValue(),
      back: _memokaData.getBackValue(),
      page: _memokaData.getPage(),
      status: memokaStatus,
      isTopPage: _memokaData.isFirstMemoka(),
      nextCallback: nextCallback,
      previousCallback: _previousCallback,
      removeCallback: _removeCallback,
      shuffleMiddleCallback: _shuffleMiddleCallback,
      shuffleEndCallback: _shuffleEndCallback,
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

  Widget _straigtIcon() {
    return IconButton(
      icon: Image.asset('assets/moca_icon/straight.png'),
      onPressed: () {
        if (!_isShuffleBusy) _straight();
      },
    );
  }

  Widget _shuffleIcon() {
    return IconButton(
      icon: Image.asset('assets/moca_icon/shuffle.png'),
      onPressed: () {
        if (!_isShuffleBusy) _shuffle();
      },
    );
  }

  Widget _tutorialWidget() {
    return GestureDetector(
      onTap: () {
        DataManager().setTutorial(true);
        DataManager().saveData();
        setState(() {
          _isTutorial = false;
        });
      },
      child: Visibility(
          visible: _isTutorial,
          child: Tutorials.getMemocaTutorialOverlay(context)),
    );
  }

  void _tutorial() {
    if (!DataManager().isTutorial()) {
      setState(() {
        _isTutorial = true;
      });
    }
  }

  /// 메모카가 비어있을 때의 세팅
  void _setEmptymoeka() {
    Offset memokaOffset;
    Size size = MediaQuery.of(context).size;

    if (size.width < size.height) {
      memokaOffset = Offset(size.width * 0.8, size.width * 0.8 * 1.4);
    } else {
      memokaOffset = Offset(size.height * 0.8 / 1.4, size.height * 0.8);
    }
    _memokaArray.clear();
    double CardRadius = 20;
    _memokaArray.add(DottedBorder(
      color: Color.fromARGB(255, 155, 171, 144),
      strokeWidth: 3,
      radius: Radius.circular(CardRadius),
      dashPattern: [25, 20],
      customPath: (size) {
        return Path()
          ..moveTo(CardRadius, 0)
          ..lineTo(size.width - CardRadius, 0)
          ..arcToPoint(Offset(size.width, CardRadius),
              radius: Radius.circular(CardRadius))
          ..lineTo(size.width, size.height - CardRadius)
          ..arcToPoint(Offset(size.width - CardRadius, size.height),
              radius: Radius.circular(CardRadius))
          ..lineTo(CardRadius, size.height)
          ..arcToPoint(Offset(0, size.height - CardRadius),
              radius: Radius.circular(CardRadius))
          ..lineTo(0, CardRadius)
          ..arcToPoint(Offset(CardRadius, 0),
              radius: Radius.circular(CardRadius));
      },
      child: SizedBox(
        width: memokaOffset.dx,
        height: memokaOffset.dy,
        child: Center(
            child: Text(
          '오른쪽 하단의\n+ 버튼을 이용하여\n단어를 추가해 주세요.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 25, color: ThemeColors.textColor),
        )),
      ),
    ));
  }
}
