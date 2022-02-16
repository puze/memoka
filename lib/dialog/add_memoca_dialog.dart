import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:memoka/tools/theme_colors.dart';

class AddMemocaDialog extends PopupRoute {
  VoidCallback addEmptyMemoca;
  VoidCallback addExcelFile;

  AddMemocaDialog({required this.addEmptyMemoca, required this.addExcelFile});

  @override
  Color? get barrierColor => Color.fromARGB(60, 0, 0, 0);

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => 'AddMemocaDialog';

  double radius = 30;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    Size size = MediaQuery.of(context).size;
    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(animation),
      child: Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
        backgroundColor: ThemeColors.darkGreen,
        child: SizedBox(
          width: size.width * 0.8,
          height: size.width * 0.8 * 0.8,
          child: _contents(context),
        ),
      ),
    );
  }

  Widget _contents(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          flex: 3,
          child: ClipRRect(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(radius),
                topRight: Radius.circular(radius)),
            child: Container(
              color: Color.fromARGB(255, 146, 168, 139),
              child: Center(
                child: Text(
                  '단어장 추가하기',
                  style: TextStyle(color: Colors.grey[800], fontSize: 22),
                ),
              ),
            ),
          ),
        ),
        Expanded(flex: 3, child: _textTheme('빈 단어장 추가하기', addEmptyMemoca)),
        Container(
          height: 1,
          color: Colors.grey,
        ),
        Expanded(flex: 3, child: _textTheme('엑셀로 단어장 추가하기', addExcelFile)),
        Container(
          height: 1,
          color: Colors.grey,
        ),
        Expanded(
            flex: 3,
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Center(
                child: Text(
                  '취소',
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: ThemeColors.textColor,
                      fontSize: 20),
                ),
              ),
            ))
      ],
    );
  }

  Widget _textTheme(String string, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Center(
        child: Text(
          string,
          style: TextStyle(color: ThemeColors.textColor, fontSize: 20),
        ),
      ),
    );
  }

  @override
  Duration get transitionDuration => Duration(milliseconds: 350);
}
