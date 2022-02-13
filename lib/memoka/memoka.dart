import 'package:flutter/material.dart';
import 'dart:math';

import 'package:memoka/tools/theme_colors.dart';

typedef Transformer = Matrix4 Function();

enum MemokaStatus { init, next, previous }

class Memoka extends StatefulWidget {
  final String front;
  final String back;
  final int page;
  final bool isTopPage;
  final MemokaStatus status;
  final VoidCallback nextCallback;
  final VoidCallback previousCallback;
  final VoidCallback removeCallback;
  final VoidCallback shuffleMiddleCallback;
  final VoidCallback shuffleEndCallback;

  const Memoka({
    Key? key,
    required this.front,
    required this.back,
    required this.page,
    required this.status,
    required this.nextCallback,
    required this.previousCallback,
    required this.removeCallback,
    required this.shuffleMiddleCallback,
    required this.shuffleEndCallback,
    required this.isTopPage,
  }) : super(key: key);

  @override
  MemokaState createState() => MemokaState();
}

class MemokaState extends State<Memoka> with TickerProviderStateMixin {
  final int _rotationTime = 200;
  final int _alignTime = 100;
  final int _shuffleTime = 350;
  final double _translateFactor = 150;
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

  /// 셔플 컨트롤러
  late AnimationController _shuffleFrontController;
  late Animation<double> _shuffleFrontAnimation;
  late AnimationController _shuffleBackController;
  late Animation<double> _shuffleBackAnimation;
  bool isShuffleMidle = false;

  // 삭제 컨트롤러
  late AnimationController _removeController;
  late Animation<Alignment> _removeAnimation;

  late Widget frontWidget;
  late Widget backWidget;
  late Widget contents;

  Alignment _dragAlignment = Alignment.center;
  final Alignment _rightAlign = const Alignment(5, 0);
  final Alignment _leftAlign = const Alignment(-5, 0);
  final Alignment _upAlign = const Alignment(0, -5);

  double _dx = 0;
  double _dy = 0;
  int _blackFiltter = 255;

  @override
  void initState() {
    _transformer = _initTransform;
    frontWidget = Text(
      widget.front,
      style: textStyle(FontWeight.w700),
    );
    backWidget = Text(
      widget.back,
      style: textStyle(FontWeight.w400),
    );
    contents = frontWidget;
    _initController();
    _initAlignment();
    super.initState();
  }

  TextStyle textStyle(FontWeight wegit) {
    return TextStyle(
        fontSize: 20, color: ThemeColors.textColor, fontWeight: wegit);
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

    _removeController = AnimationController(
        vsync: this, duration: Duration(milliseconds: _alignTime));
    _removeController.addListener(() {
      setState(() {
        _dragAlignment = _removeAnimation.value;
        if (_removeAnimation.isCompleted) {
          widget.removeCallback();
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

    _shuffleFrontController = AnimationController(
        vsync: this, duration: Duration(milliseconds: _shuffleTime));
    _shuffleFrontAnimation =
        CurvedAnimation(curve: Curves.easeIn, parent: _shuffleFrontController);
    _shuffleFrontAnimation.addListener(() {
      // debugPrint(_shuffleFrontAnimation.value.toString());
      setState(() {
        if (_shuffleFrontAnimation.value >= 0.6 && !isShuffleMidle) {
          isShuffleMidle = true;
          widget.shuffleMiddleCallback();
        }
        if (_shuffleFrontAnimation.isCompleted) {
          widget.shuffleEndCallback();
        }
      });
    });
    _shuffleBackController = AnimationController(
        vsync: this, duration: Duration(milliseconds: _shuffleTime));
    _shuffleBackAnimation =
        CurvedAnimation(curve: Curves.easeIn, parent: _shuffleBackController);
    _shuffleBackAnimation.addListener(() {
      setState(() {});
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
    Offset memokaOffset;
    if (size.width < size.height) {
      memokaOffset = Offset(size.width * 0.8, size.width * 0.8 * 1.4);
    } else {
      memokaOffset = Offset(size.height * 0.8 / 1.4, size.height * 0.8);
    }
    return Transform(
      transform: _transformer(),
      // alignment: FractionalOffset(-1, 1),
      alignment: FractionalOffset.center,
      child: GestureDetector(
        child: Align(
          alignment: _dragAlignment,
          child: SizedBox(
            width: memokaOffset.dx,
            height: memokaOffset.dy,
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                  Color.fromARGB(
                      255, _blackFiltter, _blackFiltter, _blackFiltter),
                  BlendMode.modulate),
              child: Stack(
                children: [
                  if (isTopPage())
                    Image.asset('assets/moca_icon/memoka_first.png')
                  else
                    Image.asset('assets/moca_icon/memoka.png'),
                  // 중앙 컨텐츠
                  Center(
                      child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: contents,
                  )),
                  // 오른쪽 하단 페이지 넘버
                  Positioned(
                    child: Text(
                      (widget.page + 1).toString(),
                      style: TextStyle(color: ThemeColors.textColor),
                    ),
                    right: 30,
                    bottom: 30,
                  ),
                ],
              ),
            ),
          ),
        ),
        onPanDown: (details) {
          _dx = 0;
          _dy = 0;
        },
        onPanUpdate: (details) {
          setState(() {
            _dragAlignment += Alignment(
              details.delta.dx / (size.width / 8),
              details.delta.dy / (size.height / 4),
            );
          });
          _dx += details.delta.dx;
          _dy += details.delta.dy;
        },
        onPanEnd: (details) {
          debugPrint('dx : ' + _dx.toString());
          debugPrint('dy : ' + _dy.toString());
          double dyOffset = 0.5; // 좌우 이동에 가중치
          if (_dx < -threshold && _dx < _dy * dyOffset) {
            _runNextAnimation();
          } else if (_dx > threshold && _dx > -_dy * dyOffset) {
            _runPreviousAnimation();
          } else if (_dy < -threshold) {
            _runRemoveMemokaAnimation();
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
    debugPrint(_rotationController.value.toString());
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

  final int _blackValue = 30;
  Matrix4 _shuffleFrontMatrix() {
    // debugPrint(_shuffleFrontController.value.toString());
    double maxScaleFactor = -0.2;
    Matrix4 matrix = Matrix4.identity();

    // 사이즈 조절
    double criticalSizeValue = 0.2;
    if (_shuffleFrontAnimation.value <= criticalSizeValue) {
      double scaleFactor =
          _shuffleFrontAnimation.value / criticalSizeValue * maxScaleFactor + 1;
      matrix
        ..setEntry(0, 0, scaleFactor)
        ..setEntry(1, 1, scaleFactor);
      _blackFiltter = 255 -
          (_shuffleFrontAnimation.value / criticalSizeValue * _blackValue)
              .toInt();
    }
    //위치 조종
    else if (_shuffleFrontAnimation.value <= 0.6) {
      double scaleFactor = maxScaleFactor + 1;
      matrix
        ..setEntry(0, 0, scaleFactor)
        ..setEntry(1, 1, scaleFactor)
        ..setEntry(0, 3,
            (_shuffleFrontAnimation.value - 0.2) / (0.4) * -_translateFactor);
      _blackFiltter = 255 - _blackValue;
    } else {
      double scaleFactor = maxScaleFactor + 1;
      matrix
        ..setEntry(0, 0, scaleFactor)
        ..setEntry(1, 1, scaleFactor)
        ..setEntry(
            0,
            3,
            (1 - (_shuffleFrontAnimation.value - 0.6) / (0.4)) *
                -_translateFactor);
      _blackFiltter = 255 - _blackValue;
    }

    return matrix;
  }

  Matrix4 _shuffleBackMatrix() {
    // debugPrint(_shuffleFrontController.value.toString());
    double maxScaleFactor = -0.2;
    Matrix4 matrix = Matrix4.identity();

    // 사이즈 조절
    double criticalSizeValue = 0.2;
    if (_shuffleBackAnimation.value <= criticalSizeValue) {
      double scaleFactor =
          _shuffleBackAnimation.value / criticalSizeValue * maxScaleFactor + 1;
      matrix
        ..setEntry(0, 0, scaleFactor)
        ..setEntry(1, 1, scaleFactor);
      // 뒤로갈때 어두운 필터
      _blackFiltter = 255 -
          (_shuffleBackAnimation.value / criticalSizeValue * _blackValue)
              .toInt();
    } else {
      double scaleFactor = (_shuffleBackAnimation.value - criticalSizeValue) /
              (1 - criticalSizeValue) *
              0.2 +
          0.8;
      matrix
        ..setEntry(0, 0, scaleFactor)
        ..setEntry(1, 1, scaleFactor);
      _blackFiltter = 255 -
          (-(_shuffleBackAnimation.value - criticalSizeValue) /
                      (1 - criticalSizeValue) *
                      _blackValue +
                  _blackValue)
              .toInt();
      debugPrint('balck filtter : $_blackFiltter');
    }

    // 위치 조종
    if (_shuffleBackAnimation.value <= criticalSizeValue) {
    } else if (_shuffleBackAnimation.value <= 0.6) {
      matrix.setEntry(
          0, 3, (_shuffleBackAnimation.value - 0.2) / (0.4) * _translateFactor);
    } else {
      matrix.setEntry(0, 3,
          (1 - (_shuffleBackAnimation.value - 0.6) / (0.4)) * _translateFactor);
    }
    return matrix;
  }

  void shuffleFront() {
    _transformer = _shuffleFrontMatrix;
    if (_shuffleFrontController.value != 0) {
      _shuffleFrontController.reset();
    }
    _shuffleFrontController.forward();
  }

  void shuffleBack() {
    _transformer = _shuffleBackMatrix;
    if (_shuffleBackController.value != 0) {
      _shuffleBackController.reset();
    }
    _shuffleBackController.forward();
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

  void _runRemoveMemokaAnimation() {
    _removeAnimation = _removeController
        .drive(AlignmentTween(begin: _dragAlignment, end: _upAlign));
    _removeController.reset();
    _removeController.forward();
  }

  void _runSwitchAnimation() {}

  @override
  void dispose() {
    _rotationController.dispose();
    _returnController.dispose();
    _alignController.dispose();
    _shuffleFrontController.dispose();
    _shuffleBackController.dispose();
    super.dispose();
  }

  bool isTopPage() {
    return widget.isTopPage;
  }
}
