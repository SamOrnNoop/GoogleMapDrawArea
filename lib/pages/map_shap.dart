import 'dart:developer';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

import '../controller/drag_drop_polygone_map.dart';
import '../controller/polygon_controller.dart';

class MapShapePage extends StatefulWidget {
  const MapShapePage({super.key});

  @override
  State<MapShapePage> createState() => _MapShapePageState();
}

class _MapShapePageState extends State<MapShapePage> {
  DragAndDropMapController controller = Get.put(DragAndDropMapController());
  GoogleMapsFlutterPlatform get mapInstance => GoogleMapsFlutterPlatform.instance..init(controller.mapId);
  @override
  void initState() {
    super.initState();
  }

  bool isDraggabel = false;
  Marker get test => Marker(
      markerId: const MarkerId('1'),
      position: MapGetController.cameraPosition.target,
      draggable: false,
      consumeTapEvents: true,
      onTap: () {
        isDraggabel = true;
        setState(() {});
      });
  // double _oldZoom = 10.0;
  @override
  Widget build(BuildContext context) {
    final Size constraints = MediaQuery.of(context).size;
    return GetBuilder<DragAndDropMapController>(
        init: controller,
        builder: (controller) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            body: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  _buildHearderMenue(controller),
                  Flexible(
                    child: GestureDetector(
                      onTap: () async {
                        ScreenCoordinate screen =
                            await controller.mapController.getScreenCoordinate(MapGetController.cameraPosition.target);
                        final location = await controller.mapController.getLatLng(screen);
                        print(location.toString());
                      },
                      onPanEnd: !isDraggabel
                          ? null
                          : (v) {
                              setState(() {
                                isDraggabel = false;
                              });
                            },
                      onPanUpdate: !isDraggabel
                          ? null
                          : (details) async {
                              // ScreenCoordinate screen =
                              //     await controller.mapController.getScreenCoordinate(MapGetController.cameraPosition.target);

                              int screenWidth =
                                  ((constraints.height) * (details.localPosition.dx / constraints.width)).round();

                              int screenHeight =
                                  ((constraints.height) * (details.localPosition.dy / constraints.width)).round();

                              final location = await controller.mapController.getLatLng(ScreenCoordinate(
                                  x: screenWidth + (details.localPosition.dx - 50).round(),
                                  y: screenHeight + (details.localPosition.dy - 50).round()));
                              mapInstance.updateMarkers(
                                  MarkerUpdates.from({test}, {test.copyWith(positionParam: location)}),
                                  mapId: controller.mapId);

                              log(location.toString());

                              // controller.mapController.animateCamera(CameraUpdate.newLatLng(location));
                            },
                      behavior: HitTestBehavior.opaque,
                      child: GoogleMap(
                          buildingsEnabled: true,
                          scrollGesturesEnabled: true,
                          // webGestureHandling: ,
                          // gestureRecognizers: Set.from({
                          //   Factory<Test>(() => Test(
                          //         () async {
                          //           // GoogleMapsFlutterPlatform.instance
                          //           //     .onMarkerDrag(mapId: controller.mapController.mapId)
                          //           //     .listen((MarkerDragEvent value) {
                          //           //   print(value.position);
                          //           // });

                          //           log('message start');

                          //           // controller.mapController.getLatLng(await controller.mapController.getScreenCoordinate(latLng))
                          //         },
                          //       )),
                          // }),
                          // markers: !controller.pointsEmpty()
                          //     ? Set.of(
                          //         Iterable.generate(
                          //           controller.collectedLocation.length,
                          //           (index) {
                          //             LatLng point = controller.collectedLocation[index];
                          //             String idMark = (index + 1).toString();
                          //             return controller.defaultMarkerOnLine(idMark,
                          //                 // flat: index == controller.lastIndex,
                          //                 onTap: () {
                          //                   final first = controller.collectedLocation.first;
                          //                   final last = controller.collectedLocation.last;
                          //                   if (last == first) {
                          //                     showOnSuggesstion(index, controller);
                          //                     return;
                          //                   }
                          //                   if (last == point) return;
                          //                   if (controller.ifFindingMatch(point)) {
                          //                     return controller.onChangePosition(point);
                          //                   }
                          //                 },
                          //                 onDrag: (value) => controller.onDragUpdatePosition(PositionUpdated()
                          //                   ..setindex = index
                          //                   ..setlatlong = value),
                          //                 point: point,
                          //                 icon: controller.bigIconMain);
                          //           },
                          //         ),
                          //       )
                          //     : {},
                          markers: {test},
                          zoomControlsEnabled: true,
                          zoomGesturesEnabled: true,
                          mapToolbarEnabled: true,
                          compassEnabled: true,
                          cameraTargetBounds: CameraTargetBounds.unbounded,
                          minMaxZoomPreference: const MinMaxZoomPreference(12.0, 30),
                          // onTap: controller.onChangePosition,
                          onTap: (location) {},
                          onMapCreated: controller.onCreateMap,
                          initialCameraPosition: MapGetController.cameraPosition,
                          polylines: {
                            Polyline(
                                polylineId: const PolylineId('a'),
                                points: controller.collectedLocation,
                                color: controller.lineColor,
                                width: controller.lineSize)
                          }
                          // Set.of(controller.collectedLocation.isNotEmpty
                          //     ? {
                          //         Polyline(
                          //             // patterns: [
                          //             //   PatternItem.dash(20),
                          //             //   PatternItem.gap(10),
                          //             // ],

                          //             jointType: JointType.bevel,
                          //             consumeTapEvents: false,
                          //             polylineId: const PolylineId('a'),
                          //             // startCap: Cap.customCapFromBitmap(
                          //             //   BitmapDescriptor.bytes(controller.pointIcon!),
                          //             // ),
                          //             // startCap: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),

                          //             // endCap: Cap.customCapFromBitmap(BitmapDescriptor.bytes(controller.pointIcon!)),
                          //             points: controller.collectedLocation,
                          //             color: controller.lineColor,
                          //             width: controller.lineSize),
                          //       }
                          //     : const Iterable.empty()),

                          ),
                    ),
                  ),
                ],
              ),
            ),
            floatingActionButton: Padding(
              padding: const EdgeInsets.only(left: 30.0),
              child: ElevatedButton(
                  onPressed: () => _onShowCreateNewFileFarm(controller),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlue),
                  child: const SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: Center(child: Text("Create")),
                  )),
            ),
          );
        });
  }

  Widget _textButton(String text, void Function()? callback) {
    return TextButton(onPressed: callback, child: Text(text));
  }

  Widget _iconButton(Widget icon, void Function()? callback) {
    return Padding(
      padding: const EdgeInsets.all(1),
      child: ElevatedButton.icon(
        onPressed: callback,
        label: icon,
      ),
    );
  }

  Widget _buildHearderMenue(DragAndDropMapController controller) {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _iconButton(const Icon(Icons.menu), () {
            _onShowMenue(controller);
          }),
          _iconButton(const Icon(Icons.linear_scale_outlined), () {}),
          _iconButton(const Icon(Icons.directions_walk_sharp), () {}),
          _iconButton(const Icon(Icons.undo_rounded), controller.onUndoMap),
          _iconButton(const Icon(Icons.delete), controller.onDeleteMap),
        ],
      ),
    );
  }

  void _onShowMenue(DragAndDropMapController controller) {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            // title: const Text("Custom line"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Colors',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                _textButton("Red", () => controller.onUpdateColors(Colors.red)),
                _textButton("Blue", () => controller.onUpdateColors(Colors.blue)),
                _textButton("Yellow", () => controller.onUpdateColors(Colors.yellow)),
                Text(
                  'Sizes',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                _textButton("4.0", () => controller.onUpdateLineSize(4)),
                _textButton("9.0", () => controller.onUpdateLineSize(9)),
                _textButton("12.0", () => controller.onUpdateLineSize(12)),
              ],
            ),
          );
        });
  }

  void showOnSuggesstion(int index, DragAndDropMapController controller) {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: const Text("Add new a point"),
            content: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _textButton("Add to Berfore", () {
                controller.onAddnewPointBoforeOrNext(index, false);
                return Get.back();
              }),
              _textButton("Add to Next", () {
                controller.onAddnewPointBoforeOrNext(index, true);
                return Get.back();
              }),
            ]),
          );
        });
  }

  void _onShowCreateNewFileFarm(DragAndDropMapController controller) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        constraints: BoxConstraints(maxHeight: (Get.height - 250)),
        builder: (_) {
          final GlobalKey<FormState> stateKey = GlobalKey<FormState>();
          final TextEditingController farmName = TextEditingController();
          final TextEditingController code = TextEditingController();
          return Container(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: stateKey,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Complete the information",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      _iconButton(
                        const Icon(Icons.save),
                        () {
                          if (!stateKey.currentState!.validate()) {
                            return;
                          } else {
                            controller.onSetDataInformation(FarmInformationModel()
                              ..setcode = code.text
                              ..setname = farmName.text);
                            return Get.back();
                          }
                        },
                      ),
                    ],
                  ),
                  TextFormField(
                    controller: code,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Input the code';
                      }

                      return null;
                    },
                    decoration: const InputDecoration(labelText: 'Code'),
                  ),
                  TextFormField(
                    controller: farmName,
                    decoration: const InputDecoration(labelText: 'Name'),
                  )
                ],
              ),
            ),
          );
        });
  }
}

class Test extends DragGestureRecognizer {
  Function _test;

  Test(this._test);

  @override
  void resolve(GestureDisposition disposition) {
    super.resolve(disposition);
    _test();
  }

  @override
  void acceptGesture(int pointer) {
    super.acceptGesture(pointer);
  }

  @override
  void addAllowedPointer(PointerDownEvent event) {
    log(event.toString());
    super.addAllowedPointer(event);
  }

  @override
  void addPointer(PointerDownEvent event) {
// print(event.delta.)x
    onUpdate?.call(DragUpdateDetails(
      globalPosition: event.localDelta,
      delta: event.delta,
      primaryDelta: event.orientation,
      localPosition: event.localPosition,
    ));
    super.addPointer(event);
  }

  @override
  bool get onlyAcceptDragOnThreshold => true;
  @override
  GestureDragUpdateCallback? get onUpdate {
    log('asdfsadfljsdf');
    return super.onUpdate;
  }

  @override
  @override
  DragStartBehavior get dragStartBehavior => DragStartBehavior.down;
  @override
  String get debugDescription => "UPDATING";
  @override
  @override
  bool isFlingGesture(VelocityEstimate estimate, PointerDeviceKind kind) {
    return kind == PointerDeviceKind.touch;
  }
}

class Dragger extends MultiDragGestureRecognizer {
  Dragger({required super.debugOwner});

  @override
  MultiDragPointerState createNewPointerState(PointerDownEvent event) {
    throw UnimplementedError();
  }

  @override
  String get debugDescription => throw UnimplementedError();
}
