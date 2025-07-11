import 'dart:ffi';

class Recurvice<T> {
  int _index = 0;

  int get _length => list.length;

  List<T> list = [];

  Recurvice(this.list);
  bool get isVerify => _length != 0 && _index < _length;
  Future<void> forEach({required Function(int, T) callback}) async {
    if (isVerify) {
      callback(_index, list[_index]);
      _index = _index + 1;
      await forEach(callback: callback);
    } else {
      return;
    }
  }

  Future<(int, T?)> where(bool Function(T) finding) async {
    if (isVerify) {
      T value = list[_index];
      bool isBreak = finding(value);
      if (isBreak) return (_index, value);
      _index = _index + 1;
      return await where(finding);
    } else {
      return (-1, null);
    }
  }
}
