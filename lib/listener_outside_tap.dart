import 'package:flutter/cupertino.dart';

class ListenerOutsideTap {
  static final ListenerOutsideTap _instance = ListenerOutsideTap._internal();

  List<VoidCallback> listenerList = [];

  factory ListenerOutsideTap() => _instance;

  ListenerOutsideTap._internal();

  void onClickOutsideTap() {
    for (var listener in listenerList) {
      listener();
    }
  }

  void addListener(VoidCallback listener) {
    listenerList.add(listener);
  }

  void removeListener(VoidCallback listener) {
    listenerList.remove(listener);
  }
}
