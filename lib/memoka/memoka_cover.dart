import 'package:flutter/material.dart';
import 'package:memoka/data_manager.dart';
import 'package:memoka/listener_outside_tap.dart';
import 'package:memoka/main.dart';
import 'package:memoka/memoka/memoka_data.dart';
import 'package:memoka/memoka_home.dart';

import 'memoka_body.dart';

class MemokaCover extends StatefulWidget {
  final String coverText;
  final MemokaGroup memokaGroup;

  const MemokaCover(
      {Key? key, required this.coverText, required this.memokaGroup})
      : super(key: key);

  @override
  State<MemokaCover> createState() => _MemokaCoverState();
}

class _MemokaCoverState extends State<MemokaCover> {
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
            Image.asset(
              'assets/memoka.png',
            ),
            Positioned(child: Text(widget.coverText)),
            Positioned(
                right: 0,
                top: 0,
                child: Visibility(
                    visible: isRemoveButtonVisibility,
                    child: removeMemokaIcon()))
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
              isRemoveButtonVisibility = true;
            });
          },
        ));
  }

  Widget removeMemokaIcon() {
    return GestureDetector(
      onTap: () {},
      child: RawMaterialButton(
        onPressed: () {
          // 부모의 state 갱신
          MemokaHomeState parent =
              context.findAncestorStateOfType<MemokaHomeState>()!;
          parent.setState(() {
            DataManager().removeMemokaGroup(widget.memokaGroup);
          });
        },
        elevation: 2.0,
        fillColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.remove),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    ListenerOutsideTap().removeListener(listenerOutSideTap);
  }

  void listenerOutSideTap() {
    setState(() {
      isRemoveButtonVisibility = false;
    });
  }
}
