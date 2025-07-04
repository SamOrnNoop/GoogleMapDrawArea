import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:google_maps_widget/google_maps_widget.dart';
import 'package:learn_map/controller/poly_smater.dart';
import 'package:learn_map/utils/base_print.dart';
import 'package:learn_map/utils/collection.dart';
import 'package:learn_map/utils/constants.dart';
import 'package:learn_map/utils/material_map.dart';

class DragCustomEventGetXController extends GetxController {
  Size get constraints => Get.size;
  GoogleMapController? controller;
  List<LatLng> points = [];
  Set<Marker> pointMaker = {};
  Set<Circle> circleCurrentPoint = {};

  LatLng? setlectLatLong;

  GoogleMapsFlutterPlatform get mapservice => GoogleMapsFlutterPlatform.instance;

  int get mapId => controller?.mapId ?? 0;

  bool _isToggleDrag = false;

  bool get isToggleDrag => _isToggleDrag;

  void onToggleDrag() {
    _isToggleDrag = _isToggleDrag.toggle();
    update();
  }

  void onCreateController(GoogleMapController cxt) async {
    mapservice.init(cxt.mapId);

    controller = cxt;
    MaterialGoogleMap.onAnimatedZoomToCurrent(cxt);
    Geolocator.getLastKnownPosition().then((position) {
      if (position == null) return;
      circleCurrentPoint.add(_circle(LatLng(position.latitude, position.longitude)));
      update();
    });
  }

  Circle _circle(LatLng latlng) {
    return Circle(
        circleId: const CircleId('currentPoinst'),
        center: latlng,
        radius: 2.5,
        fillColor: Colors.blue,
        strokeColor: Colors.red,
        strokeWidth: 2);
  }

  Set<Polyline> get polylin {
    return {
      Polyline(
        polylineId: const PolylineId('bb'),
        points: points,
        color: Colors.blue,
        patterns: [
          PatternItem.gap(20),
          PatternItem.dash(20),
        ],
        width: 2,
      ),
    };
  }

  Marker _marker(LatLng latlng, int iD) {
    String id = 'marker_id_$iD';
    return Marker(
      markerId: MarkerId(id),
      anchor: const Offset(0.5, 0.5),
      icon: MaterialGoogleMap.iconPoint,
      consumeTapEvents: true,
      onTap: () {
        mapservice.updateMarkers(
            MarkerUpdates.from({
              Marker(
                markerId: MarkerId(id),
              )
            }, {
              Marker(markerId: MarkerId(id))
            }),
            mapId: mapId);
        BaseLogger.log("Marker Tap lng: $latlng : id:$id ");
      },
      position: latlng,
    );
  }

  void onRemoveMap() {
    pointMaker.clear();
    points.clear();
    pointMaker = {};
    points = [];

    update();
  }

  void onUndo() {
    if (setlectLatLong != null) {
      pointMaker.remove(const Marker(markerId: MarkerId('')));
      points.remove(setlectLatLong);
    }
    update();
  }

  EdgeInsets get viewSafe => MediaQuery.of(Get.context!).systemGestureInsets;
  Future<LatLng> getDrag(DragUpdateDetails details) async {
    double getViewSafe = viewSafe.top + viewSafe.bottom + viewSafe.left + viewSafe.right;
    int screenWidth = ((constraints.height) * (details.localPosition.dx / constraints.width)).ceil();

    int screenHeight = ((constraints.height) * (details.localPosition.dy / constraints.width)).ceil();

    final location = await controller?.getLatLng(ScreenCoordinate(
        x: screenWidth + (details.localPosition.dx - getViewSafe).ceil(),
        y: screenHeight + (details.localPosition.dy - getViewSafe).ceil()));
    return Future<LatLng>.value(location);
  }

  void onDragLocation(DragUpdateDetails details) async {
    final LatLng latLng = await getDrag(details);

    if (points.isEmpty) {
      points.add(latLng);
      pointMaker.add(_marker(latLng, 1));
      points.add(latLng);
      return;
    }
    pointMaker.add(_marker(latLng, 2));
    int index = points.length - 2;

    // if (matter.ceil() > 1) {
    points.insert(index, latLng);
    // }

    update();
  }

  // Set<LatLng> sampleLate = {};

  void onDragEndFindCurveAndConer() async {
    int indecateIndex = 0;
    final List<LatLng> curveCornerpoints = PolylineAnalyzer().selectOnlyCornerAndCurve(points.toList())
      ..remove
      ..removeLast();

    await Recurvice(curveCornerpoints).forEach(callback: (index, latlng) {
      double matter = Geolocator.distanceBetween(
        curveCornerpoints[indecateIndex].latitude,
        curveCornerpoints[indecateIndex].longitude,
        latlng.latitude,
        latlng.longitude,
      );

      if (matter.ceil() > 2) {
        pointMaker.add(_marker(latlng, index));
        indecateIndex = index;
      }
    });

    update();
  }
}
