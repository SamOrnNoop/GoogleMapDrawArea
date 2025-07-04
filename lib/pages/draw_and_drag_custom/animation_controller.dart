import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DrawMapAnimationController extends GetxController with GetSingleTickerProviderStateMixin {
  static DrawMapAnimationController find = Get.find<DrawMapAnimationController>();
  AnimationController? animationController;
  Animation<double>? tween;

  bool get isAnimating => animationController?.isAnimating ?? false;
  @override
  void onInit() {
    animationController = AnimationController(vsync: this, duration: 500.milliseconds);
    tween = Tween<double>(begin: 1, end: 0).animate(animationController!);
    super.onInit();
  }

  void onRepeated() => animationController?.repeat(reverse: true);
  void onStopAnimation() => animationController?.reset();

  void onGetAnimation([final void Function(bool value)? onDone]) {
    if (onDone != null) onDone.call(isAnimating);
    if (isAnimating) return onStopAnimation();
    return onRepeated();
  }

  void onDisposeAnimated() {
    animationController?.stop();
    Future.delayed(50.milliseconds, () {
      animationController?.removeListener(() {});
      tween?.removeListener(() {});
      animationController?.dispose();
      animationController = null;
      tween = null;
    });
  }

  @override
  void onClose() {
    onDisposeAnimated();
    super.onClose();
  }
}
