import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:memoka/data_manager.dart';
import 'package:memoka/dialog/popup_dialog.dart';
import 'package:memoka/tools/theme_colors.dart';

class AddMemocaDialog extends PopupRoute {
  VoidCallback addEmptyMemoca;
  VoidCallback addExcelFile;
  AddMemocaDialog({required this.addEmptyMemoca, required this.addExcelFile});
  double radius = 30;

  @override
  Color? get barrierColor => Color.fromARGB(70, 0, 0, 0);

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
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
        backgroundColor: ThemeColors.lightGreen,
        child: SizedBox(
          width: size.width * 0.7,
          height: size.width * 0.7 * 0.8,
          child: AddMemocaPage(
              addEmptyMemoca: addEmptyMemoca, addExcelFile: addExcelFile),
        ),
      ),
    );
  }

  @override
  Duration get transitionDuration => Duration(milliseconds: 350);
}

class AddMemocaPage extends StatefulWidget {
  VoidCallback addEmptyMemoca;
  VoidCallback addExcelFile;
  AddMemocaPage(
      {Key? key, required this.addEmptyMemoca, required this.addExcelFile})
      : super(key: key);

  @override
  _AddMemocaPageState createState() => _AddMemocaPageState();
}

class _AddMemocaPageState extends State<AddMemocaPage> {
  TextEditingController _memocaCoverController = TextEditingController();
  late Widget _contents;

  double radius = 30;

  @override
  void initState() {
    _contents = _choiceAddMemoca();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
              color: ThemeColors.backgroundColor,
              child: Center(
                child: Text(
                  '단어장 추가',
                  style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 18,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ),
        Expanded(
            flex: 9,
            child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: child,
                  );
                },
                child: _contents))
      ],
    );
  }

  Widget _textTheme(String string, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Center(
        child: Text(
          string,
          style: TextStyle(color: Colors.grey[700], fontSize: 18),
        ),
      ),
    );
  }

  Widget _choiceAddMemoca() {
    return Column(
      key: GlobalKey(),
      children: [
        Expanded(
            flex: 3,
            child: _textTheme('직접 추가', () {
              setState(() {
                _contents = _inputMemocaCover();
              });
            })),
        Container(
          height: 1,
          color: ThemeColors.backgroundColor,
        ),
        Expanded(flex: 3, child: _textTheme('엑셀 추가', widget.addExcelFile)),
        Container(
          height: 1,
          color: ThemeColors.backgroundColor,
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
                      color: Colors.grey[700],
                      fontSize: 18),
                ),
              ),
            ))
      ],
    );
  }

  Widget _inputMemocaCover() {
    return Column(
      key: GlobalKey(),
      children: [
        Expanded(
          flex: 6,
          child: Padding(
            padding: EdgeInsets.all(30),
            child: TextField(
              controller: _memocaCoverController,
              decoration: InputDecoration(
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: ThemeColors.textColor)),
                labelText: '단어장 제목',
                labelStyle: TextStyle(color: Colors.grey[600]),
              ),
              style: TextStyle(color: Colors.grey[700], height: 2),
            ),
          ),
        ),
        Container(
          height: 1,
          color: ThemeColors.backgroundColor,
        ),
        Expanded(
          flex: 3,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              RawMaterialButton(
                onPressed: () {
                  if (_memocaCoverController.text == '') {
                    Navigator.push(
                        context, PopupDialog(message: '단어장 제목을 입력해 주세요'));
                  } else {
                    DataManager()
                        .createEmptyMemoca(_memocaCoverController.text);
                    Navigator.pop(context);
                    widget.addEmptyMemoca();
                  }
                },
                child: Text(
                  '확인',
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Colors.grey[700],
                      fontSize: 18),
                ),
              ),
              Container(
                width: 1,
                color: ThemeColors.backgroundColor,
              ),
              RawMaterialButton(
                onPressed: () {
                  setState(() {
                    _contents = _choiceAddMemoca();
                  });
                },
                child: Text(
                  '취소',
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Colors.grey[700],
                      fontSize: 18),
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}
