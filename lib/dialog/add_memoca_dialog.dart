import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:memoka/tools/theme_colors.dart';

class AddMemocaDialog extends PopupRoute {
  VoidCallback addEmptyMemoca;
  VoidCallback addExcelFile;

  AddMemocaDialog({required this.addEmptyMemoca, required this.addExcelFile});

  @override
  Color? get barrierColor => Color.fromARGB(68, 0, 0, 0);

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => 'AddMemocaDialog';

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    Size size = MediaQuery.of(context).size;
    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(animation),
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: ThemeColors.darkGreen,
        child: SizedBox(
          width: size.width * 0.8,
          height: size.width * 0.8 * 0.8,
          child: _contents(),
        ),
      ),
    );
  }

  Widget _contents() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          flex: 3,
          child: Center(
            child: Text(
              '단어장 추가하기',
              style: TextStyle(color: Colors.grey[800], fontSize: 22),
            ),
          ),
        ),
        Expanded(flex: 1, child: Divider(thickness: 3)),
        Expanded(flex: 3, child: _textTheme('빈 단어장 추가하기', addEmptyMemoca)),
        Expanded(
            flex: 1,
            child: Divider(
              thickness: 2,
            )),
        Expanded(flex: 3, child: _textTheme('엑셀로 단어장 추가하기', addExcelFile))
      ],
    );
  }

  Widget _textTheme(String string, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Center(
        child: Text(
          string,
          style: TextStyle(color: ThemeColors.textColor, fontSize: 18),
        ),
      ),
    );
  }

  @override
  Duration get transitionDuration => Duration(milliseconds: 350);
}
