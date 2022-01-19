import 'package:flutter/cupertino.dart';

class WorldPosition {
  static Offset offsetMemocaCover(BuildContext context) {
    Size fullSize = MediaQuery.of(context).size;
    double width = (fullSize.width - 60) / 2;
    double height = width * 193 / 264;
    return Offset(width, height);
  }
}
