import 'package:flutter/material.dart';

class ThemeColors {
  static final ThemeColors _instance = ThemeColors._internal();
  Color backgroundColor = const Color.fromARGB(255, 186, 205, 174);

  factory ThemeColors() {
    return _instance;
  }

  ThemeColors._internal() {
    // 초기화
  }
}
