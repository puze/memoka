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
                  Text('단어 추가'),
                  TextField(
                    controller: frontTextController,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: '단어',
                    ),
                    onSubmitted: (value) async {},
                  ),
                  TextField(
                    controller: backTextController,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: '뜻',
                    ),
                    onSubmitted: (value) async {},
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RawMaterialButton(
                          onPressed: _submit, child: const Text('확인')),
                      RawMaterialButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('취소')),
                    ],
                  )
                ],
              ),
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
