import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_widget/google_maps_widget.dart';
import 'package:learn_map/pages/draw_and_drag_custom/controller.dart';
import 'package:learn_map/utils/defualt_scaffold.dart';
import 'package:learn_map/utils/material_map.dart';
import '../map_shape_preview_detail.dart';
import 'walk_track.dart';

class DrawAndDragCustomEventPage extends StatelessWidget {
  const DrawAndDragCustomEventPage({super.key});

  DragCustomEventGetXController get mapController => Get.put(DragCustomEventGetXController());
  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: mapController,
        builder: (cxt) {
          return DefaultScaffold(
              resizeToAvoidBottomInset: false,
              body: Stack(
                children: [
                  _googleMapBuilder(cxt),
                  _headerBuilder(cxt),
                  _openWalkerTracker(cxt),
                ],
              ),
              floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
              floatingActionButton: switch (mapController.isToggleWalkTrack) {
                true => const Center(),
                _ => Padding(
                    padding: const EdgeInsets.all(5),
                    child: FloatingActionButton(
                      onPressed: () async {
                        if (cxt.points.isNotEmpty) {
                          Get.to(PreviewMapPage(polylin: cxt.polylin));
                          return;
                        }
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
              });
        });
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
              width: double.infinity,
              color: Colors.grey[300],
              child: Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 4, left: 5, right: 10),
                child: Row(
                  children: [
                    Flexible(
                        child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5)),
                      child: Row(
                        children: [
                          Flexible(
                            child: TextFormField(
                              controller: cxt.seachMapController,
                              decoration: const InputDecoration.collapsed(
                                  hintText: 'latitude,longitude',
                                  hintStyle: TextStyle(
                                    fontWeight: FontWeight.normal,
                                  )),
                            ),
                          ),
                          GestureDetector(
                              onTap: () async {
                                String position = cxt.seachMapController.value.text;
                                List<String> splitLatlng = position.split(',');
                                if (splitLatlng.first.isNum && splitLatlng.last.isNum) {
                                  try {
                                    final target = LatLng(
                                      double.parse(splitLatlng.first.trim()),
                                      double.parse(splitLatlng.last.trim()),
                                    );
                                    await cxt.controller!.moveCamera(CameraUpdate.zoomTo(8));
                                    await Future.delayed(100.milliseconds);
                                    await cxt.controller!.animateCamera(
                                      CameraUpdate.newLatLng(target),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(Get.context!).showSnackBar(
                                        const SnackBar(content: Text("ទីតាំរបស់លោកអ្នកមិនត្រឹមត្រូវទេ!")));
                                  }
                                }
                              },
                              child: const CircleAvatar(
                                radius: 11,
                                child: Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(4.0),
                                    child: FittedBox(child: Text("GO")),
                                  ),
                                ),
                              ))
                        ],
                      ),
                    )),
                    const SizedBox(width: 10),
                    _baseIconButton(
                      cxt.points.isEmpty
                          ? () {
                              if (cxt.isToggleWalkTrack) return;
                              cxt.onToggleDrag();
                              mapController.animatedController.onGetAnimation();
                            }
                          : null,
                      GetBuilder(
                          init: mapController.animatedController,
                          builder: (controller) {
                            return AnimatedBuilder(
                                animation: controller.animationController!,
                                builder: (_, chi) {
                                  bool disable = !cxt.isScrollHandleTrack && cxt.points.isEmpty;
                                  return Icon(
                                    Icons.control_camera_rounded,
                                    color: switch (controller.isAnimating) {
                                      true => Colors.red.withOpacity(controller.tween!.value),
                                      false when disable => Colors.blue[900],
                                      _ => null,
                                    },
                                  );
                                });
                          }),
                    ),
                    _baseIconButton(
                      cxt.onToggleWalkTrack,
                      Icon(
                        Icons.directions_walk,
                        color: cxt.isToggleWalkTrack ? Colors.blue : null,
                      ),
                    ),
                    _baseIconButton(
                      mapController.onRemoveMap,
                      const Icon(
                        Icons.delete_rounded,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ));
  }

  Widget _openWalkerTracker(DragCustomEventGetXController cxt) {
    return AnimatedPositioned(
        duration: 300.milliseconds,
        bottom: cxt.isToggleWalkTrack ? 0 : -110,
        left: 0,
        right: 0,
        child: WalkTrackPointWidget(
          onPresssed: cxt.onGetWalkingTrack,
        ));
  }

  Widget _googleMapBuilder(DragCustomEventGetXController cxt) {
    return Listener(
      onPointerHover: (event) {
        if (cxt.isToggleDrag) {
          cxt.isScrollHandleTrack = false;
          return cxt.update();
        } else {
          if (cxt.points.isEmpty) return;
          cxt.onHandleScrollMap?.call(event);
          cxt.isScrollHandleTrack = true;
          return cxt.update();
        }
      },
      onPointerUp: (event) async {
        cxt.isScrollHandleTrack = true;
        if (!cxt.isToggleDrag) return;
        cxt.onToggleDrag();
        cxt.animatedController.onGetAnimation();
        cxt.onDragEndFindCurveAndConer();
      },
      onPointerMove: (event) {
        if (event.device > 0) return;
        cxt.onDragUpdate?.call(
          ScaleUpdateDetails(focalPoint: event.position, localFocalPoint: event.localPosition),
        );
      },
      child: GoogleMap(
        key: cxt.mapGlobalKey,
        scrollGesturesEnabled: cxt.isScrollHandleTrack,
        // scrollGesturesEnabled: true,
        zoomGesturesEnabled: true,
        markers: cxt.pointMaker,
        polylines: cxt.polylin,
        compassEnabled: true,
        rotateGesturesEnabled: false,
        mapType: MapType.hybrid,
        cameraTargetBounds: CameraTargetBounds.unbounded,
        initialCameraPosition: MaterialGoogleMap.cameraPosition,
        onMapCreated: cxt.onCreateController,
        zoomControlsEnabled: true,
        myLocationEnabled: true,
        onTap: cxt.onSelectReset,
        minMaxZoomPreference: MaterialGoogleMap.minMaxZoomPreference,
      ),
    );
  }

  Widget _baseIconButton(void Function()? callback, Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
        ),
        child: IconButton(
          padding: const EdgeInsets.all(0),
          visualDensity: const VisualDensity(vertical: -3, horizontal: -3),
          onPressed: callback,
          iconSize: 15,
          icon: child,
        ),
      ),
    );
  }
}

int counterPointer = 0;
