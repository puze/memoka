import 'package:flutter/material.dart';
import 'package:memoka/tools/theme_colors.dart';

class AddVocaRoute extends PopupRoute {
  AddVocaRoute();

  @override
  Color? get barrierColor => null;

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => null;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    Size size = MediaQuery.of(context).size;
    double baseWidthPadding;
    double baseHeightPadding;
    if (size.width < size.height) {
      double widthRatio = 0.7;
      baseWidthPadding = size.width * (1 - widthRatio) / 2;
      double heightRatio = 1.3;
      baseHeightPadding =
          (size.height - size.width * widthRatio * heightRatio) / 2;
    } else {
      baseWidthPadding = size.width * 0.1;
      baseHeightPadding = size.height * 0.1;
    }
    MediaQuery.of(context).size.height * baseWidthPadding;
    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(animation),
      child: Padding(
        padding: EdgeInsets.fromLTRB(baseWidthPadding, baseHeightPadding,
            baseWidthPadding, baseHeightPadding),
        child: Material(
          type: MaterialType.transparency,
          child: Card(
            elevation: 10,
            shape: RoundedRectangleBorder(
              //모서리를 둥글게 하기 위해 사용
              borderRadius: BorderRadius.circular(16.0),
            ),
            color: Colors.green[300],
            child: Padding(
              padding: const EdgeInsets.all(22.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: '단어',
                    ),
                    onSubmitted: (value) async {},
                  ),
                  TextField(
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: '뜻',
                    ),
                    onSubmitted: (value) async {},
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Duration get transitionDuration => Duration(milliseconds: 150);
}
