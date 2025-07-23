import 'dart:developer';
import 'dart:ffi';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:learn_map/utils/material_map.dart';

class HistoryLogPage extends StatefulWidget {
  const HistoryLogPage({super.key});

  @override
  State<HistoryLogPage> createState() => _HistoryLogPageState();
}

class _HistoryLogPageState extends State<HistoryLogPage> {
  bool isTabdo = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("History"),
      ),
      body: Listener(
        // onPointerHover: (prit) {
        //   if (isTabdo) {
        //     setState(() {
        //       isTabdo = false;
        //     });
        //   }
        //   log('Message start ${prit.timeStamp.inMicroseconds}');
        // },
        // onPointerDown: (up) async {
        //   // await Future.delayed(50.milliseconds);
        //   // if (isTabdo) {
        //   setState(() {
        //     isTabdo = false;
        //   });
        // },
        // onPointerUp: (a) {
        //   isTabdo = true;
        // },

        // },
        child: GestureDetector(
          // // dragStartBehavior: DragStartBehavior.down,
          // behavior: HitTestBehavior.deferToChild,

          // // onTapDown: (details) {
          // //   isTabdo = details.kind == PointerDeviceKind.mouse;
          // //   setState(() {});
          // //   print("Message :$isTabdo");
          // // },
          // onScaleStart: isTabdo ? (print) {} : null,
          // onScaleUpdate: isTabdo
          //     ? (details) {
          //         log("pand :$isTabdo");
          //       }
          //     : null,

          // onPanCancel: () {
          //   log('ca');
          // },
          // By declaring these, this detector “eats” any vertical-drag gesture.
          // onVerticalDragStart: (_) {},
          // onPanUpdate: isTabdo
          //     ? null
          //     : (_) {
          //         print(_);
          //       },
          // onPanEnd: isTabdo ? null : (_) => isTabdo = false,
          // // onVerticalDragEnd: (_) {},

          child: Container(clipBehavior: Clip.none, child: map()),
        ),
      ),
    );
  }

  Widget map() {
    return GoogleMap(
      initialCameraPosition: MaterialGoogleMap.cameraPosition,
    );
  }

//  void Function(DragStartDetails)? start => (d) {
//         // start = ();
//         return;
//       };
}
