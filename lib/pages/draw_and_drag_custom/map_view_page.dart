import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_widget/google_maps_widget.dart';
import 'package:learn_map/pages/draw_and_drag_custom/animation_controller.dart';
import 'package:learn_map/pages/draw_and_drag_custom/controller.dart';
import 'package:learn_map/utils/defualt_scaffold.dart';
import 'package:learn_map/utils/material_map.dart';

class DrawAndDragCustomEventPage extends StatelessWidget {
  const DrawAndDragCustomEventPage({super.key});

  DrawMapAnimationController get animatedController => Get.put(DrawMapAnimationController());
  DragCustomEventGetXController get mapController => Get.put(DragCustomEventGetXController());
  @override
  Widget build(BuildContext context) {
    return DefaultScaffold(
      body: GetBuilder(
          init: mapController,
          builder: (cxt) {
            return Stack(
              children: [
                _googleMapBuilder(cxt),
                _headerBuilder(cxt),
              ],
            );
          }),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(5),
        child: FloatingActionButton(
          onPressed: () async {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
                "We are developing right now. You cannot save anything here.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              // margin: EdgeInsets.symmetric(horizontal: 10),
              backgroundColor: Colors.grey,
              clipBehavior: Clip.none,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
            ));
          },
          child: const Icon(Icons.save),
        ),
      ),
    );
  }

  Widget _headerBuilder(DragCustomEventGetXController cxt) {
    return Positioned(
        left: 0,
        right: 0,
        child: Column(
          children: [
            AppBar(
              title: const Text("Drag"),
              titleTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              centerTitle: true,
              iconTheme: const IconThemeData(color: Colors.white),
              backgroundColor: Colors.blue[900],
            ),
            Container(
              height: 50,
              width: double.infinity,
              color: Colors.grey[300],
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
                child: Row(
                  children: [
                    _baseIconButton(
                      () {
                        cxt.onToggleDrag();
                        animatedController.onGetAnimation();
                      },
                      GetBuilder(
                          init: animatedController,
                          builder: (controller) {
                            return AnimatedBuilder(
                                animation: controller.animationController!,
                                builder: (_, chi) {
                                  return Icon(
                                    Icons.control_camera_rounded,
                                    color: controller.isAnimating
                                        ? Colors.red.withOpacity(controller.tween!.value)
                                        : Colors.blue[900],
                                  );
                                });
                          }),
                    ),
                    _baseIconButton(
                      () {},
                      const Icon(Icons.directions_walk),
                    ),
                    const Spacer(),
                    _baseIconButton(
                      mapController.onRemoveMap,
                      const Icon(Icons.delete_rounded),
                    ),
                  ],
                ),
              ),
            )
          ],
        ));
  }

  Widget _googleMapBuilder(DragCustomEventGetXController cxt) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      supportedDevices: const {PointerDeviceKind.touch, PointerDeviceKind.trackpad},
      dragStartBehavior: DragStartBehavior.down,
      onScaleUpdate: cxt.onDragUpdate,
      // onPanUpdate: cxt.onDragUpdate,
      onScaleEnd: switch (cxt.isToggleDrag) {
        true => (detail) {
            cxt.onToggleDrag();
            animatedController.onGetAnimation();
            cxt.onDragEndFindCurveAndConer();
          },
        _ => null,
      },
      child: IgnorePointer(
        ignoring: false,
        // ignoring: cxt.isToggleDrag,
        child: GoogleMap(
          scrollGesturesEnabled: true,
          zoomGesturesEnabled: true,
          markers: cxt.pointMaker,
          polylines: cxt.polylin,
          compassEnabled: true,
          mapType: MapType.hybrid,
          cameraTargetBounds: CameraTargetBounds.unbounded,
          initialCameraPosition: MaterialGoogleMap.cameraPosition,
          onMapCreated: cxt.onCreateController,
          zoomControlsEnabled: true,
          myLocationEnabled: true,
          onTap: (value) {
            cxt.onSelectReset();
          },
          minMaxZoomPreference: MaterialGoogleMap.minMaxZoomPreference,
        ),
      ),
    );
  }

  Widget _baseIconButton(void Function()? callback, Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
        ),
        child: IconButton(
          onPressed: callback,
          icon: child,
        ),
      ),
    );
  }
}
