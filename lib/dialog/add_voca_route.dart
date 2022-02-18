import 'package:flutter/material.dart';
import 'package:memoka/dialog/popup_dialog.dart';
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
      //TODO pad size
      double widthRatio = 0.82;
      baseWidthPadding = size.width * (1 - widthRatio) / 2;
      double heightRatio = 729 / 907;
      baseHeightPadding =
          (size.height - size.width * widthRatio * heightRatio) / 2;
    }
    MediaQuery.of(context).size.height * baseWidthPadding;
    return Dialog(
      shape: RoundedRectangleBorder(
        //모서리를 둥글게 하기 위해 사용
        borderRadius: BorderRadius.circular(33.0),
      ),
      elevation: 10,
      backgroundColor: ThemeColors.darkGreen,
      child: SizedBox(
        width: size.width * 0.8,
        height: size.width * 0.8 * 0.8,
        child: FadeTransition(
          opacity: Tween<double>(begin: 0, end: 1).animate(animation),
          child: Material(
            type: MaterialType.transparency,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  flex: 3,
                  child: Center(
                    child: Text('단어 추가',
                        style: TextStyle(
                            color: ThemeColors.textColor,
                            fontSize: 20,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
                Expanded(
                    flex: 6,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          TextField(
                            controller: frontTextController,
                            decoration: InputDecoration(
                              border: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: ThemeColors.underLineColor)),
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: ThemeColors.underLineColor)),
                              isDense: true,
                              contentPadding: const EdgeInsets.all(0),
                              labelText: '단어',
                              labelStyle: TextStyle(color: Colors.grey[600]),
                            ),
                            style: TextStyle(color: Colors.grey[700]),
                            // style: TextStyle(
                            //   color: Colors.grey[700],
                            // ),
                            onSubmitted: (value) async {},
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          TextField(
                            controller: backTextController,
                            decoration: InputDecoration(
                                border: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: ThemeColors.underLineColor)),
                                focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: ThemeColors.underLineColor)),
                                isDense: true,
                                contentPadding: const EdgeInsets.all(0),
                                labelText: '뜻',
                                labelStyle: TextStyle(color: Colors.grey[600])),
                            style: TextStyle(color: Colors.grey[700]),
                            onSubmitted: (value) async {},
                          ),
                        ],
                      ),
                    )),
                Container(
                  height: 1,
                  color: ThemeColors.lightGreen,
                ),
                Expanded(
                  flex: 3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      RawMaterialButton(
                          onPressed: _submit,
                          child: Text(
                            '확인',
                            style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Colors.grey[700],
                                fontSize: 18),
                          )),
                      Container(
                        width: 1,
                        color: ThemeColors.lightGreen,
                      ),
                      RawMaterialButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            '취소',
                            style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Colors.grey[700],
                                fontSize: 18),
                          )),
                    ],
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
