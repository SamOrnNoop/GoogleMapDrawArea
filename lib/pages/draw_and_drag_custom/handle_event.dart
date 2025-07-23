import 'package:flutter/gestures.dart';

class HandlerPointerEvent {
  final List<int> _handlerPointers = [];
  int get pointerCount => _handlerPointers.length;
  final int _inDuration = 450;

  /// Here is the counter event of pointers.
  /// it can ignore multi pointers/ fingers
  /// just including values 1,2,3,4,5.
  /// That numbers mean it count when finger/pointer stays on touch.

  List<int>? _ignorepointers;
  void setIgorePointerCount(List<int> value) => _ignorepointers = value;

  /// Handle event deley
  Future<void> waitingPointer() async => await Future.delayed(Duration(microseconds: _inDuration));

  /// Handle event start
  void onStartEvent(int pointerId, void Function() push) async {
    _handlerPointers.add(pointerId);
    await waitingPointer();
    _handleCallback(pointerId, push, onElse: () => GestureBinding.instance.cancelPointer(pointerId));
  }

  //Handle event update
  void onUpdateEvent(int pointerId, void Function() push) async {
    await waitingPointer();
    _handleCallback(pointerId, push);
  }

//Handle event end
  void onEndEvent(int pointerId, void Function() push) async {
    _handleCallback(pointerId, push);

    await waitingPointer();
    _handlerPointers.clear();
  }

  void _handleCallback(int p, void Function() call, {void Function()? onElse}) {
    if (_handlerPointers.isEmpty) return;
    if (_handlerPointers.last == p) {
      if (_ignorepointers != null && _ignorepointers != []) {
        bool ignore = _ignorepointers!.any((e) => e == _handlerPointers.length);
        if (ignore) return;
      }
      return call();
    }

    if (onElse != null) onElse.call();
  }
}
