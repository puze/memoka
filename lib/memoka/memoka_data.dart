import 'package:excel/excel.dart';

class MemokaData {
  late List<List<Data?>> _memokaData;
  int _currentIndex = 0;
  static const int front = 0;
  static const int back = 1;

  MemokaData(Excel excelData, String meokaTable) {
    //excelData.
    _memokaData = excelData.tables[meokaTable]!.rows;
  }

  bool isFirstMemoka() {
    return _currentIndex == 0;
  }

  void nextMemoka() {
    if (_currentIndex + 1 < _memokaData.length) {
      _currentIndex++;
    } else {
      _currentIndex = 0;
    }
  }

  void previousMemoka() {
    if (_currentIndex - 1 >= 0) {
      _currentIndex--;
    } else {
      _currentIndex = _memokaData.length - 1;
    }
  }

  String getFrontValue() {
    return _memokaData[_currentIndex][front]?.value;
  }

  String getBackValue() {
    return _memokaData[_currentIndex][back]?.value;
  }

  int getPage() {
    return _currentIndex;
  }
}
