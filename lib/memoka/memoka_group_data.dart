import 'package:excel/excel.dart';
import 'package:memoka/memoka/memoka_data.dart';

class MemokaGroupData {
  late MemokaGroup _memokaData;
  int _currentIndex = 0;
  static const int front = 0;
  static const int back = 1;

  MemokaGroupData(MemokaGroup memokaGroup) {
    //excelData.
    _memokaData = memokaGroup;
  }

  bool isFirstMemoka() {
    return _currentIndex == 0;
  }

  void setIndexMemoka(int index) {
    _currentIndex = index;
  }

  void nextMemoka() {
    if (_currentIndex + 1 < _memokaData.memokaData.length) {
      _currentIndex++;
    } else {
      _currentIndex = 0;
    }
  }

  void previousMemoka() {
    if (_currentIndex - 1 >= 0) {
      _currentIndex--;
    } else {
      _currentIndex = _memokaData.memokaData.length - 1;
    }
  }

  void shuffleMemoka() {
    _memokaData.memokaData.shuffle();
  }

  void straightMemoka() {}

  String getFrontValue() {
    return _memokaData.memokaData[_currentIndex].front;
  }

  String getBackValue() {
    return _memokaData.memokaData[_currentIndex].back;
  }

  int getPage() {
    return _currentIndex;
  }
}
