import 'package:flutter/material.dart';
import 'dart:math';

typedef Matrix4 Transformer();

class Memoka extends StatefulWidget {
  final String front;
  final String back;
  final int page;
  final bool? isFront;

  const Memoka(
      {Key? key,
      required this.front,
      required this.back,
      required this.page,
      this.isFront})
      : super(key: key);

  @override
  MemokaState createState() => MemokaState();
}

class MemokaState extends State<Memoka> with TickerProviderStateMixin {
  final int _revolutionValue = 100;
  final int _revolutionTime = 100;
  final int _rotationTime = 200;
  double _horizontalDelta = 0;
  double _verticalDelat = 0;
  late Transformer _transformer;

  /// 시작시 원위치로
  late AnimationController _beginController;

  ///바깥으로 나가는 컨트롤러
  late AnimationController _exitController;

  /// 스스로 회전하는 컨트롤러
  late AnimationController _rotationController;

  late Widget frontWidget;
  late Widget backWidget;
  late Widget contents;

  @override
  void initState() {
    _transformer = _initTransform;
    frontWidget = Text(widget.front);
    backWidget = Text(widget.back);
    contents = frontWidget;
    initController();
    super.initState();
  }

  /// 애니메이션 컨트롤러 초기화
  void initController() {
    _beginController = AnimationController(
        vsync: this, duration: Duration(milliseconds: _revolutionTime))
      ..addListener(() {
        setState(() {
          if (_beginController.isCompleted) {}
        });
      });
    _exitController = AnimationController(
        vsync: this, duration: Duration(milliseconds: _revolutionTime))
      ..addListener(() {
        setState(() {
          if (_exitController.isCompleted) {
            // widget.nextMemokaCallback();
            // dispose();
          }
          // if (_exitController.value >= 0.5) {
          //   widget.nextMemokaCallback();
          // }
        });
      });
    _rotationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: _rotationTime))
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: _transformer(),
      // alignment: FractionalOffset(-1, 1),
      alignment: FractionalOffset.center,
      child: GestureDetector(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.width * 0.8 * 0.7,
          color: Colors.amberAccent,
          child: Stack(
            children: [
              // 중앙 컨텐츠
              Center(
                  child: Padding(
                padding: const EdgeInsets.all(20),
                child: contents,
              )),
              // 오른쪽 하단 페이지
              Positioned(
                child: Text(widget.page.toString()),
                right: 10,
                bottom: 10,
              ),
              // 첫페이지 표시
              Positioned(
                child: Visibility(
                  child: Container(
                    color: Colors.red,
                    width: 10,
                    height: 40,
                  ),
                  visible: isTopPage(),
                ),
                top: -20,
                right: 10,
              )
            ],
          ),
        ),
        // onHorizontalDragUpdate: (details) {
        //   _horizontalDelta += details.primaryDelta!;
        //   // debugPrint(horizontalDelta.toString());
        // },
        // onHorizontalDragEnd: (details) {
        //   if (_horizontalDelta <= -100) {
        //     _horizontalDelta = 0;
        //     _exitMemoka();
        //   }
        // },
        onTap: () {
          // 현재 트랜스포머 뒤짚기로 변경
          _rotationMemoka(widget);
        },
      ),
    );
  }

  Matrix4 _initTransform() {
    return Matrix4.identity()..setEntry(0, 3, 0);
    // return Matrix4.identity()..setEntry(0, 3, -2500);
  }

  Matrix4 _rotation() {
    // debugPrint(_controller.value.toString());
    if (_rotationController.value >= 0.5) {
      contents = backWidget;
      return Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateY((_rotationController.value - 1) * pi);
    } else {
      contents = frontWidget;
      return Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateY(_rotationController.value * pi);
    }
  }

  Matrix4 _rightCenter() {
    return Matrix4.identity()
      ..setEntry(0, 3, (1 - _beginController.value) * _revolutionValue);
  }

  Matrix4 _centerLeft() {
    // return Matrix4.identity()..rotateZ(-(_controller.value) * pi);
    return Matrix4.identity()
      ..setEntry(0, 3, -_exitController.value * _revolutionValue);
  }

  Matrix4 _leftCenter() {
    return Matrix4.identity()
      ..setEntry(0, 3, (-1 + _exitController.value) * _revolutionValue);
  }

  Matrix4 _cneterRight() {
    return Matrix4.identity()
      ..setEntry(0, 3, _exitController.value * _revolutionValue);
  }

  Matrix4 _initPosition() {
    return Matrix4.identity()..setEntry(0, 3, 0);
  }

  void resetPosition() {
    setState(() {
      _transformer = _initPosition;
    });
  }

  void _rotationMemoka(Widget widget) {
    _transformer = _rotation;
    setState(() {
      if (_rotationController.value == 0) {
        _rotationController.forward();
      } else {
        _rotationController.reverse();
      }
    });
  }

  void _exitMemoka() {
    // widget.nextMemokaCallback();
    _transformer = _centerLeft;
    setState(() {
      _exitController.reset();
      _exitController.forward();
    });
  }

  /// 가운데로 돌아오는 애니메이션
  void returnFromRight() {
    debugPrint('beginReturn');
    _transformer = _rightCenter;
    _beginController.reset();
    _beginController.forward();
    _rotationController.reset();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _exitController.dispose();
    _beginController.dispose();
    super.dispose();
  }

  bool isTopPage() {
    return widget.page == 0;
  }
}
