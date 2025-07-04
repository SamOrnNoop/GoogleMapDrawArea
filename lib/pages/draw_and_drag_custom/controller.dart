import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map_line_editor/flutter_map_line_editor.dart' as edit;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:google_maps_widget/google_maps_widget.dart';
import 'package:latlong2/latlong.dart' as lltllng;
import 'package:learn_map/controller/poly_smater.dart';

import 'package:learn_map/utils/base_print.dart';
import 'package:learn_map/utils/constants.dart';
import 'package:learn_map/utils/material_map.dart';

class DragCustomEventGetXController extends GetxController {
  Size get constraints => Get.size;
  GoogleMapController? controller;
  List<LatLng> points = [];
  Set<Marker> pointMaker = {};

  LatLng? setlectLatLong;

  GoogleMapsFlutterPlatform get mapservice => GoogleMapsFlutterPlatform.instance;

  int get mapId => controller?.mapId ?? 0;

  bool _isToggleDrag = false;

  bool get isToggleDrag => _isToggleDrag;

  void onToggleDrag() {
    _isToggleDrag = _isToggleDrag.toggle();
    update();
  }

  void onCreateController(GoogleMapController cxt) {
    mapservice.init(cxt.mapId);

    controller = cxt;
  }

  Set<Circle> get circle {
    return {
      Circle(
          circleId: const CircleId('circle_parse'),
          center: MaterialGoogleMap.cameraPosition.target,
          radius: 0.4,
          fillColor: Colors.blue,
          strokeColor: Colors.red,
          strokeWidth: 2)
    };
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

    double matter = Geolocator.distanceBetween(
      points[index].latitude,
      points[index].longitude,
      latLng.latitude,
      latLng.longitude,
    );

    if (matter.ceil() > 1) {
      points.insert(index, latLng);
    }

    update();
  }

  int indecateIndex = 0;
  Set<LatLng> sampleLate = {};
  void onDragEndFindCurveAndConer() async {
    for (int index = 0; index < points.length; index++) {
      double matter = Geolocator.distanceBetween(
        points[indecateIndex].latitude,
        points[indecateIndex].longitude,
        points[index].latitude,
        points[index].longitude,
      );

      if (matter.ceil() > 2) {
        sampleLate.add(points[indecateIndex]);

        indecateIndex = index;
      }
    }

    ExPolyEditor polyEditor =
        ExPolyEditor(points: sampleLate.toList(), addClosePathMarker: false, intermediateIcon: false);
    for (final LatLng latLng in polyEditor.edit()) {
      pointMaker.add(_marker(latLng, indecateIndex++));
      update();
    }
  }
}
