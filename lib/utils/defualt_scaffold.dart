import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DefaultScaffold extends Scaffold {
  const DefaultScaffold(
      {super.key,
      super.body,
      super.appBar,
      super.floatingActionButton,
      super.floatingActionButtonLocation,
      super.bottomNavigationBar,
      super.drawer});

  @override
  FloatingActionButtonLocation? get floatingActionButtonLocation =>
      super.floatingActionButtonLocation ?? FloatingActionButtonLocation.startTop;
  @override
  Widget? get floatingActionButton =>
      super.floatingActionButton ??
      FloatingActionButton(
        backgroundColor: Colors.white70,
        child: const Icon(Icons.arrow_back),
        onPressed: () {
          Get.back();
        },
      );
}
