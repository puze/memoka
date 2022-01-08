import 'package:flutter/material.dart';
import 'dart:math';

typedef Transformer = Matrix4 Function();

enum MemokaStatus { init, next, previous }

class Memoka extends StatefulWidget {
  final String front;
  final String back;
  final int page;
  final MemokaStatus status;
  final VoidCallback nextCallback;
  final VoidCallback previousCallback;

  const Memoka({
    Key? key,
    required this.front,
    required this.back,
    required this.page,
    required this.status,
    required this.nextCallback,
    required this.previousCallback,
  }) : super(key: key);

  @override
  MemokaState createState() => MemokaState();
}

class MemokaState extends State<Memoka> with TickerProviderStateMixin {
  final int _rotationTime = 200;
  final int _alignTime = 100;
  // 드래그 임계치
  final double threshold = 30;

  late Transformer _transformer;

  /// 스스로 회전하는 컨트롤러
  late AnimationController _rotationController;

  /// 위치 컨트롤러
  late AnimationController _alignController;
  late Animation<Alignment> _animation;
  late AnimationController _nextAlignController;
  late Animation<Alignment> _nextAlignAnimation;

  /// 되돌아오는 컨트롤러
  late AnimationController _returnController;
  late Animation<Alignment> _returnAnimation;

  late Widget frontWidget;
  late Widget backWidget;
  late Widget contents;

  Alignment _dragAlignment = Alignment.center;
  final Alignment _rightAlign = const Alignment(10, 0);
  final Alignment _leftAlign = const Alignment(-10, 0);

  double _dx = 0;

  @override
  void initState() {
    _transformer = _initTransform;
    frontWidget = Text(
      widget.front,
      style: textStyle(),
    );
    backWidget = Text(
      widget.back,
      style: textStyle(),
    );
    contents = frontWidget;
    _initController();
    _initAlignment();
    super.initState();
  }

  TextStyle textStyle() {
    return const TextStyle(fontSize: 20);
  }

  /// 애니메이션 컨트롤러 초기화
  void _initController() {
    _rotationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: _rotationTime))
      ..addListener(() {
        setState(() {});
      });

    _nextAlignController = AnimationController(
        vsync: this, duration: Duration(milliseconds: _alignTime));
    _nextAlignController.addListener(() {
      setState(() {
        _dragAlignment = _nextAlignAnimation.value;
        if (_nextAlignAnimation.isCompleted) {
          debugPrint('next animation end');
          widget.nextCallback();
        }
      });
    });

    _alignController = AnimationController(
        vsync: this, duration: Duration(milliseconds: _alignTime));
    _alignController.addListener(() {
      setState(() {
        _dragAlignment = _animation.value;
        if (_animation.isCompleted) {
          widget.previousCallback();
        }
      });
    });

    _returnController = AnimationController(
        vsync: this, duration: Duration(milliseconds: _alignTime));
    _returnController.addListener(() {
      setState(() {
        _dragAlignment = _returnAnimation.value;
      });
    });
  }

  void _initAlignment() {
    switch (widget.status) {
      case MemokaStatus.init:
        _dragAlignment = Alignment.center;
        break;
      case MemokaStatus.next:
        _dragAlignment = _rightAlign;
        _runReturnAnimation();
        break;
      case MemokaStatus.previous:
        _dragAlignment = _leftAlign;
        _runReturnAnimation();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Transform(
      transform: _transformer(),
      // alignment: FractionalOffset(-1, 1),
      alignment: FractionalOffset.center,
      child: GestureDetector(
        child: Align(
          alignment: _dragAlignment,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.width * 0.8 * 1.4,
            child: Stack(
              children: [
                Image.asset('assets/moca_icon/memoka.png'),
                // 중앙 컨텐츠
                Center(
                    child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: contents,
                )),
                // 오른쪽 하단 페이지 넘버
                Positioned(
                  child: Text(widget.page.toString()),
                  right: 30,
                  bottom: 30,
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
        ),
        onPanDown: (details) {
          _dx = 0;
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

  void _runReturnAnimation() {
    _returnAnimation = _returnController.drive(
      AlignmentTween(
        begin: _dragAlignment,
        end: Alignment.center,
      ),
    );
    _returnController.reset();
    _returnController.forward();
  }

  void _runNextAnimation() {
    _nextAlignAnimation = _nextAlignController.drive(
      AlignmentTween(
        begin: _dragAlignment,
        end: _leftAlign,
      ),
    );
    _nextAlignController.reset();
    _nextAlignController.forward();
  }

  void _runPreviousAnimation() {
    _animation = _alignController.drive(
      AlignmentTween(
        begin: _dragAlignment,
        end: _rightAlign,
      ),
    );
    _alignController.reset();
    _alignController.forward();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _returnController.dispose();
    _alignController.dispose();
    super.dispose();
  }

  bool isTopPage() {
    return widget.page == 0;
  }
}
