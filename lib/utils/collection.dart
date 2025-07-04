class Recurvice<T> {
  int _index = 0;

  int get _length => list.length;

  List<T> list = [];

  Recurvice(this.list);

  Future<void> forEach({required void Function(int, T) callback}) async {
    if (_length != 0 && _index < _length) {
      callback.call(_index, list[_index]);
      _index = _index + 1;
      await forEach(callback: callback);
    } else {
      return Future.value();
    }
  }
}
