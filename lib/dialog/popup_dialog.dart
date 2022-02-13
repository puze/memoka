import 'package:flutter/material.dart';
import 'package:memoka/tools/theme_colors.dart';

class PopupDialog extends PopupRoute {
  String message;
  PopupDialog({required this.message});

  @override
  Color? get barrierColor => null;

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => false;

  @override
  String? get barrierLabel => null;

  bool _isBusyAutoClose = false;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    _autoClose(context);
    Size size = MediaQuery.of(context).size;
    double baseWidthPadding;
    double baseHeightPadding;
    if (size.width < size.height) {
      baseWidthPadding = size.width * 0.1;
      baseHeightPadding = size.height * 0.36;
    } else {
      baseWidthPadding = size.width * 0.1;
      baseHeightPadding = size.height * 0.1;
    }
    MediaQuery.of(context).size.height * baseWidthPadding;
    return WillPopScope(
      onWillPop: () {
        // 백버튼 방지
        return Future(() => false);
      },
      child: FadeTransition(
        opacity: Tween<double>(begin: 0, end: 1).animate(animation),
        child: Padding(
          padding: EdgeInsets.fromLTRB(baseWidthPadding, baseHeightPadding,
              baseWidthPadding, baseHeightPadding),
          child: Material(
            type: MaterialType.transparency,
            child: Stack(
              alignment: Alignment.center,
              fit: StackFit.expand,
              children: [
                Image.asset('assets/moca_icon/cover.png', fit: BoxFit.fill),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                      child: Text(
                    message,
                    style: TextStyle(
                        fontSize: 17,
                        height: 1.6,
                        color: ThemeColors.textColor),
                    textAlign: TextAlign.center,
                  )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _autoClose(BuildContext context) async {
    if (!_isBusyAutoClose) {
      _isBusyAutoClose = true;
    } else {
      return;
    }

    await Future.delayed(const Duration(milliseconds: 1300));

    Navigator.pop(context);
  }

  @override
  Duration get transitionDuration => Duration(milliseconds: 150);
}

class TransparentRoute extends PageRoute<void> {
  TransparentRoute({
    required this.builder,
  });

  final WidgetBuilder builder;

  @override
  bool get opaque => false;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => Duration(milliseconds: 350);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    final result = builder(context);
    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(animation),
      child: Semantics(
        scopesRoute: true,
        explicitChildNodes: true,
        child: result,
      ),
    );
  }
}
