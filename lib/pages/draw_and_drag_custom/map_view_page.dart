import 'dart:developer';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:google_maps_widget/google_maps_widget.dart';
import 'package:learn_map/controller/circle_controller.dart';
import 'package:learn_map/model/place_field.dart';
import 'package:learn_map/pages/draw_and_drag_custom/controller.dart';
import 'package:learn_map/services/https.dart';
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
                        if (cxt.onlyPoints.isNotEmpty) {
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
                    _searchPlaceWidget(cxt),
                    const SizedBox(width: 10),
                    _baseIconButton(
                      cxt.onlyPoints.isEmpty
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
                                  bool disable = !cxt.isScrollHandleTrack && cxt.onlyPoints.isEmpty;
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
                      mapController.onUndoPoint,
                      const Icon(Icons.undo_sharp),
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
            ),
            Obx(() {
              return AnimatedCrossFade(
                  firstChild: const SizedBox(width: double.infinity),
                  secondChild: _listPlaceWidgetBuilder(cxt),
                  crossFadeState:
                      cxt.enableMenuSearchPlace.value ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  duration: 200.milliseconds);
            })
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
      onPointerHover: cxt.pointerHoverEvent,
      onPointerUp: cxt.pointerEndEvent,
      onPointerDown: cxt.pointerEventStart,
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
        rotateGesturesEnabled: true,
        mapType: MapType.hybrid,
        cameraTargetBounds: CameraTargetBounds.unbounded,
        initialCameraPosition: MaterialGoogleMap.cameraPosition,
        onMapCreated: cxt.onCreateController,
        zoomControlsEnabled: true,
        myLocationEnabled: true,

        onCameraMove: (position) {},

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

Widget _searchPlaceWidget(DragCustomEventGetXController cxt) {
  return Flexible(
    child: Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5)),
      child: Row(
        children: [
          Flexible(
            child: TextFormField(
              enableSuggestions: true,
              controller: cxt.seachMapController,
              focusNode: cxt.focusNode,
              decoration: const InputDecoration.collapsed(
                  hintText: 'ស្វែងរកទីតាំង',
                  hintStyle: TextStyle(
                    fontWeight: FontWeight.normal,
                  )),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _listPlaceWidgetBuilder(DragCustomEventGetXController cxt) {
  return Container(
    height: 300,
    width: double.infinity,
    decoration: const BoxDecoration(
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(5)),
      color: Colors.white,
    ),
    child: FutureBuilder<List<PlaceFieldModel>>(
        future: HttpsServices().khmerStateOfMap(cxt.querySearch),
        builder: (_, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 20),
              itemCount: snap.data!.length,
              itemBuilder: (_, i) {
                final data = snap.data![i];
                return ListTile(
                  enabled: true,
                  onTap: () {
                    cxt.onUnrequestField();
                    cxt.controller!.animateCamera(
                        CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(data.lat, data.long), zoom: 10)));
                  },
                  leading: const Icon(
                    Icons.place,
                    color: Colors.red,
                  ),
                  title: Text(data.displayName),
                );
              });
        }),
  );
}
