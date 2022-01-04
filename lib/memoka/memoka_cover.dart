import 'package:flutter/material.dart';
import 'package:memoka/data_manager.dart';
import 'package:memoka/listener_outside_tap.dart';
import 'package:memoka/memoka/memoka_data.dart';
import 'package:vibration/vibration.dart';

import 'memoka_body.dart';

typedef OnLongPressCallback = void Function(MemokaCoverState? memokaCoverState);

class MemokaCover extends StatefulWidget {
  final String coverText;
  final MemokaGroup memokaGroup;
  final OnLongPressCallback? onLognPressCallback;
  final VoidCallback removeMemokaCallback;

  const MemokaCover(
      {Key? key,
      required this.coverText,
      required this.memokaGroup,
      required this.onLognPressCallback,
      required this.removeMemokaCallback})
      : super(key: key);

  @override
  State<MemokaCover> createState() => MemokaCoverState();
}

class MemokaCoverState extends State<MemokaCover> {
  bool isRemoveButtonVisibility = false;

  @override
  void initState() {
    super.initState();
    ListenerOutsideTap().addListener(listenerOutSideTap);
  }

  @override
  Widget build(BuildContext context) {
    return FocusScope(
        debugLabel: 'Scope',
        autofocus: true,
        child: GestureDetector(
          child: Stack(alignment: Alignment.center, children: [
            // 메모카 삭제버튼 활성시 메모카 커버 어둡게함
            ColorFiltered(
              colorFilter: isRemoveButtonVisibility
                  ? const ColorFilter.mode(
                      Color.fromARGB(255, 100, 100, 100), BlendMode.modulate)
                  : const ColorFilter.mode(
                      Color.fromARGB(0, 0, 0, 0), BlendMode.dst),
              child: Image.asset(
                'assets/memoka.png',
              ),
            ),
            Positioned(child: Text(widget.coverText)),
            Positioned(
                child: Visibility(
                    visible: isRemoveButtonVisibility,
                    child: _removeMemokaIcon()))
          ]),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Scaffold(
                          body: MemokaBody(
                        memokaGroup: widget.memokaGroup,
                      ))),
            );
          },
          onLongPress: () {
            setState(() {
              widget.onLognPressCallback!(this);
              isRemoveButtonVisibility = true;
              Vibration.vibrate(duration: 30, amplitude: 64);
            });
          },
        ));
  }

  Widget _removeMemokaIcon() {
    return GestureDetector(
      onTap: () {},
      child: RawMaterialButton(
        onPressed: () {
          // 부모의 state 갱신
          // MemokaHomeState parent =
          //     context.findAncestorStateOfType<MemokaHomeState>()!;
          // parent.setState(() {
          //   DataManager().removeMemokaGroup(widget.memokaGroup);
          // });

          DataManager().removeMemokaGroup(widget.memokaGroup);
          widget.removeMemokaCallback();
        },
        elevation: 2.0,
        fillColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.remove),
        constraints: const BoxConstraints(minWidth: 70, minHeight: 70),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    ListenerOutsideTap().removeListener(listenerOutSideTap);
  }

  void listenerOutSideTap() {
    if (!isRemoveButtonVisibility) return;

    setState(() {
      isRemoveButtonVisibility = false;
    });
  }
}
