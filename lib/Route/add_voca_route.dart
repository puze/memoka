import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:memoka/tools/popup_dialog.dart';
import 'package:memoka/tools/theme_colors.dart';

class AddVocaRoute extends PopupRoute {
  TextEditingController frontTextController = TextEditingController();
  TextEditingController backTextController = TextEditingController();
  late BuildContext _context;

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
    _context = context;
    Size size = MediaQuery.of(context).size;
    double baseWidthPadding;
    double baseHeightPadding;
    if (size.width < size.height) {
      double widthRatio = 0.82;
      baseWidthPadding = size.width * (1 - widthRatio) / 2;
      double heightRatio = 729 / 907;
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
        padding: EdgeInsets.fromLTRB(baseWidthPadding, baseHeightPadding * 0.9,
            baseWidthPadding, baseHeightPadding * 1.1),
        child: Material(
          type: MaterialType.transparency,
          child: Card(
            elevation: 10,
            shape: RoundedRectangleBorder(
              //모서리를 둥글게 하기 위해 사용
              borderRadius: BorderRadius.circular(16.0),
            ),
            color: ThemeColors.darkGreen,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: 15,
                ),
                Text('단어 추가',
                    style: TextStyle(
                        color: ThemeColors.textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.w700)),
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 2, 20, 2),
                  child: TextField(
                    controller: frontTextController,
                    decoration: InputDecoration(
                        border: const UnderlineInputBorder(),
                        labelText: '단어',
                        labelStyle: TextStyle(color: Colors.grey[600])),
                    onSubmitted: (value) async {},
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 2, 20, 2),
                  child: TextField(
                    controller: backTextController,
                    decoration: InputDecoration(
                        border: const UnderlineInputBorder(),
                        labelText: '뜻',
                        labelStyle: TextStyle(color: Colors.grey[600])),
                    onSubmitted: (value) async {},
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      height: 52,
                      child: Column(
                        children: [
                          Container(
                            width: size.width,
                            height: 1,
                            color: Colors.lightGreen[100],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              RawMaterialButton(
                                  onPressed: _submit,
                                  child: Text(
                                    '확인',
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: ThemeColors.textColor),
                                  )),
                              Container(
                                width: 1,
                                height: 50,
                                color: Colors.lightGreen[100],
                              ),
                              RawMaterialButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    '취소',
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: ThemeColors.textColor),
                                  )),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (frontTextController.text == '' || backTextController.text == '') {
      Navigator.push(_context, PopupDialog(message: '내용을 입력해 주세요'));
      return;
    }

    Navigator.pop(
        _context,
        AddVocaData(
            front: frontTextController.text, back: backTextController.text));
  }

  @override
  Duration get transitionDuration => Duration(milliseconds: 150);

  @override
  void dispose() {
    frontTextController.dispose();
    backTextController.dispose();
    super.dispose();
  }
}

class AddVocaData {
  String front;
  String back;
  AddVocaData({required this.front, required this.back});
}
