import 'package:memoka/data_manager.dart';
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
    _memokaData.lastPage = _currentIndex.toString();
    DataManager().saveData();
  }

  void nextMemoka() {
    if (_currentIndex + 1 < _memokaData.memokaData.length) {
      _currentIndex++;
    } else {
      _currentIndex = 0;
    }
    _memokaData.lastPage = _currentIndex.toString();
    DataManager().saveData();
  }

  void previousMemoka() {
    if (_currentIndex - 1 >= 0) {
      _currentIndex--;
    } else {
      _currentIndex = _memokaData.memokaData.length - 1;
    }
    _memokaData.lastPage = _currentIndex.toString();
    DataManager().saveData();
  }

  void shuffleMemoka() {
    _memokaData.memokaData.shuffle();
    _memokaData.lastPage = _currentIndex.toString();
    DataManager().saveData();
  }

  void straightMemoka() {
    _memokaData.memokaData.sort((a, b) => a.index.compareTo(b.index));
    _memokaData.lastPage = _currentIndex.toString();
    DataManager().saveData();
  }

  String getFrontValue() {
    return _memokaData.memokaData[_currentIndex].front;
  }

  String getBackValue() {
    return _memokaData.memokaData[_currentIndex].back;
  }

  int getPage() {
    // 1페이지부터 시작하기 위해
    return _memokaData.memokaData[_currentIndex].index;
  }

  void setLastPage() {
    _currentIndex = int.parse(_memokaData.lastPage);
  }

  void addData(String front, String back) {
    MemokaData data = MemokaData(
        front: front, back: back, index: _memokaData.memokaData.length);
    _memokaData.memokaData.add(data);
    DataManager().saveData();
  }
}
