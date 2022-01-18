import 'package:flutter/material.dart';
import 'package:memoka/memoka/memoka_data.dart';
import 'package:vibration/vibration.dart';

import 'memoka_body.dart';

class MemokaCover extends StatefulWidget {
  final String coverText;
  final MemokaGroup memokaGroup;

  const MemokaCover({
    Key? key,
    required this.coverText,
    required this.memokaGroup,
  }) : super(key: key);

  @override
  State<MemokaCover> createState() => MemokaCoverState();
}

class MemokaCoverState extends State<MemokaCover> {
  bool isRemoveButtonVisibility = false;

  @override
  Widget build(BuildContext context) {
    return FocusScope(
        debugLabel: 'Scope',
        autofocus: true,
        child: GestureDetector(
          child: Stack(alignment: Alignment.center, children: [
            // 메모카 삭제버튼 활성시 메모카 커버 어둡게함
            Positioned.fill(
              child: ColorFiltered(
                colorFilter: isRemoveButtonVisibility
                    ? const ColorFilter.mode(
                        Color.fromARGB(255, 180, 180, 180), BlendMode.modulate)
                    : const ColorFilter.mode(
                        Color.fromARGB(0, 0, 0, 0), BlendMode.dst),
                child:
                    // Container(
                    //   color: Colors.pink,
                    // )
                    Image.asset(
                  'assets/moca_icon/cover.png',
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
            Text(widget.coverText),
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
        ));
  }

  void onLongPressMemokaCover() {
    setState(() {
      isRemoveButtonVisibility = true;
      Vibration.vibrate(duration: 30, amplitude: 64);
    });
  }
}
