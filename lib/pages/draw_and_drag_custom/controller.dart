import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
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
  MapIdConstants constMapId = const MapIdConstants();
  GoogleMapController? controller;
  List<LatLng> points = [];
  Set<Marker> pointMaker = {};
  Set<Circle> circleCurrentPoint = {};
  SelectedPoint? selectedPoint;

  // LatLng? setlectLatLong;

  GoogleMapsFlutterPlatform get mapservice => GoogleMapsFlutterPlatform.instance;

  bool isMarkerDarg = false;

  int get mapId => controller?.mapId ?? 0;

  bool _isToggleDrag = false;

  bool get isToggleDrag => _isToggleDrag;

  void onToggleDrag() {
    _isToggleDrag = _isToggleDrag.toggle();
    update();
  }

  @override
  void onInit() {
    MaterialGoogleMap.initIconMarker();
    super.onInit();
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
        polylineId: const PolylineId('polylin'),
        points: points,
        color: Colors.indigo,
        patterns: [
          PatternItem.gap(20),
          PatternItem.dash(20),
        ],
        width: 2,
      ),
    };
  }

  Future<void> updateMarker(SelectedPoint value) async {
    if (selectedPoint != null) {
      pointMaker.remove(_marker(selectedPoint!.value, selectedPoint!.id));
      pointMaker.add(_marker(selectedPoint!.value, selectedPoint!.id));
    }
    pointMaker.remove(_marker(value.value, value.id));
    pointMaker.add(_marker(value.value, value.id).copyWith(iconParam: MaterialGoogleMap.updateIconPoint));

    selectedPoint = value;
  }

  Marker _marker(LatLng latlng, String id, [BitmapDescriptor? icon, int? index]) {
    // String id = 'marker_id_$iD';
    return Marker(
      markerId: MarkerId(id),
      anchor: const Offset(0.5, 0.5),
      icon: icon ?? MaterialGoogleMap.iconPoint,
      consumeTapEvents: true,
      draggable: false,
      onTap: () async {
        isMarkerDarg = true;
        SelectedPoint select = SelectedPoint(id: id, value: latlng);
        updateMarker(select);
        BaseLogger.log("Marker Tap lng: $latlng : id:$id ");
        if (index != null) {
          points.insert(index, select.value);
          _onRemoveMarkerById(id);
          pointMaker.add(_marker(select.value, constMapId.idPointMarker(select.value)));
        }

        onTapAndDragNewPoint(select);
        BaseLogger.log("Marker add new Item :$index ");
        update();
      },
      position: latlng,
    );
  }

  void _onConnectionLine() {
    if (<LatLng>{points.first}.difference({points.last}).isNotEmpty) {
      points.add(points.first);
    }
    return;
  }

  void onRemoveMap() {
    if (selectedPoint != null) {
      _onRemoveMarkerById(selectedPoint!.id);
      points.removeWhere((value) => selectedPoint!.isMomentPoint(value));
      selectedPoint = null;
      isMarkerDarg = false;
      _onConnectionLine();
      _removeIconSuggession();
    } else {
      pointMaker.clear();
      points.clear();
      pointMaker = {};
      points = [];
    }

    update();
  }

  void onSelectReset() {
    isMarkerDarg = false;
    _removeIconSuggession();
    onResetMarkerToDefualt();

    update();
  }

  void _onRemoveMarkerById(String id) => pointMaker.removeWhere((e) => e.markerId.value == id);
  void onResetMarkerToDefualt([bool isDefault = true]) {
    if (selectedPoint != null) {
      _onRemoveMarkerById(selectedPoint!.id);
      if (isDefault) {
        pointMaker.add(_marker(selectedPoint!.value, selectedPoint!.id));
      } else {
        pointMaker.add(_marker(selectedPoint!.value, selectedPoint!.id).copyWith(
          iconParam: MaterialGoogleMap.updateIconPoint,
        ));
      }
    }
  }

  EdgeInsets get viewSafe => MediaQuery.of(Get.context!).systemGestureInsets;
  Future<LatLng> getDrag(DragUpdateDetails details) async {
    double getSafeVerti = viewSafe.top + viewSafe.bottom;
    double getSafeHoriz = viewSafe.left + viewSafe.right;
    int screenWidth = ((constraints.height) * (details.localPosition.dx / constraints.width)).ceil();

    int screenHeight = ((constraints.height) * (details.localPosition.dy / constraints.width)).ceil();

    final location = await controller?.getLatLng(ScreenCoordinate(
        x: screenWidth + (details.localPosition.dx - (getSafeHoriz + getSafeVerti)).ceil(),
        y: screenHeight + (details.localPosition.dy - (getSafeVerti)).ceil()));
    return Future<LatLng>.value(location);
  }

  void Function(ScaleUpdateDetails)? get onDragUpdate => switch (isToggleDrag) {
        true => (details) => onDragCreatePoint(details),
        false when isMarkerDarg => (details) => onDragUpdatePositionPoint(details),
        _ => null,
      };

  void onDragCreatePoint(ScaleUpdateDetails details) async {
    getDrag(DragUpdateDetails(globalPosition: details.localFocalPoint, localPosition: details.localFocalPoint))
        .then((latLng) {
      if (points.isEmpty) {
        points.insert(0, latLng);
        pointMaker.add(_marker(latLng, constMapId.idPointMarker(001)));
        points.add(latLng);
        return;
      }
      int index = points.length - 2;
      bool isLong = MaterialGoogleMap.isBearingCalulat(3, points[index], latLng);

      if (isLong) {
        pointMaker.add(_marker(latLng, constMapId.idPointMarker(002)));
        points.insert(index, latLng);
      }

      update();
    });
  }

  double _scaleZoome = 1.1;
  void onDragUpdatePositionPoint(ScaleUpdateDetails details) async {
    final LatLng latLng = await getDrag(
        DragUpdateDetails(globalPosition: details.localFocalPoint, localPosition: details.localFocalPoint));
    if (details.pointerCount > 1) {
      BaseLogger.log(details.scale);
      double zoom = await controller!.getZoomLevel();

      if (details.scale > _scaleZoome) {
        await controller?.animateCamera(CameraUpdate.zoomTo(zoom + 1));
      } else {
        await controller?.animateCamera(CameraUpdate.zoomTo(zoom - 1));
      }
      _scaleZoome = details.scale;
      return;
    } else if (details.pointerCount <= 1 && details.scale == 1.0) {
      isMarkerDarg = true;

      if (selectedPoint == null) return;
      if (selectedPoint!.isMomentPoint(points.first) && selectedPoint!.isMomentPoint(points.last)) {
        onTapAndDragNewPoint(selectedPoint!);
        points.first = latLng;
        points.last = latLng;
      } else {
        int indexWhere = points.indexWhere((point) => selectedPoint!.isMomentPoint(point));
        if (indexWhere.isNegative) return;
        points[indexWhere] = latLng;
        onTapAndDragNewPoint(selectedPoint!, indexWhere);
      }

      selectedPoint = SelectedPoint(id: selectedPoint!.id, value: latLng);

      updateMarker(selectedPoint!);
    }
    update();
  }

  void onDragEndFindCurveAndConer() async {
    if (isMarkerDarg) {
      isMarkerDarg = false;
      _isToggleDrag = false;
      selectedPoint = null;
      update();
      return;
    }
    await Future<void>.delayed(350.milliseconds);
    pointMaker.clear();

    List<LatLng> resultPoints = PolylineAnalyzer.findCornersAndCurves(points);

    int lastIndex = resultPoints.length - 1;

    bool isBearing = MaterialGoogleMap.isBearingCalulat(15, resultPoints[lastIndex - 1], resultPoints.last);
    if (isBearing) {
      LatLng getAdvide = MaterialGoogleMap.getAdviceMediatePointHandle(resultPoints[lastIndex - 1], resultPoints.last);
      resultPoints.insert(lastIndex, getAdvide);
    }
    await Recurvice(resultPoints)
        .forEach(callback: (index, value) => pointMaker.add(_marker(value, constMapId.idPointMarker(value.hashCode))));

    points = resultPoints;
    update();
  }

  Future<(int, LatLng?)> wherePoint(SelectedPoint p) async =>
      await Recurvice(points).where((latlng) => p.isMomentPoint(latlng));

  void onTapAndDragNewPoint(SelectedPoint selectP, [int? dragIndex]) async {
    int index = dragIndex ?? (await wherePoint(selectP)).$1;
    //  points.indexWhere((latlng) => selectP.isMomentPoint(latlng));
    if (index.isNegative) return;
    int length = points.length - 1;
    int prevIndex = switch (index) { 0 => length - 1, _ => index - 1 };
    int nextIndex = length == index ? 0 : index + 1;

    LatLng prevPoint = points[prevIndex];
    LatLng currentPoint = selectP.value;
    LatLng nextPoint = points[nextIndex];

    String idPrev = constMapId.idPrevMarker;
    String idNext = constMapId.idNextMarker;

    if (MaterialGoogleMap.isBearingCalulat(15, prevPoint, currentPoint)) {
      LatLng prev = MaterialGoogleMap.getAdviceMediatePointHandle(prevPoint, currentPoint);
      pointMaker.add(_marker(prev, idPrev, MaterialGoogleMap.iconSmall, prevIndex + 1));
    } else {
      _onRemoveMarkerById(idPrev);
    }

    if (MaterialGoogleMap.isBearingCalulat(15, currentPoint, nextPoint)) {
      LatLng next = MaterialGoogleMap.getAdviceMediatePointHandle(currentPoint, nextPoint);
      pointMaker.add(_marker(next, idNext, MaterialGoogleMap.iconSmall, nextIndex));
    } else {
      _onRemoveMarkerById(idNext);
    }
  }

  void _handleMapTap(LatLng tappedLatLng) {
    bool polylineTapped = false;
    Recurvice(points).forEach(callback: (index, value) {});

    if (!polylineTapped) {
      BaseLogger.log('Map tap at ${tappedLatLng.latitude}, ${tappedLatLng.longitude} is not on any polyline.');
    }
  }

  void _removeIconSuggession() {
    _onRemoveMarkerById(constMapId.idPrevMarker);
    _onRemoveMarkerById(constMapId.idNextMarker);
  }
}

class SelectedPoint {
  final String id;
  final LatLng value;
  const SelectedPoint({required this.id, required this.value});

  bool isMomentPoint(LatLng latlng) {
    return latlng.latitude == value.latitude && latlng.longitude == value.longitude;
  }
}

class MapIdConstants {
  final String idPrevMarker = 'marker_id_prev';
  final String idNextMarker = 'marker_id_next';
  final String idPolyline = "polylin";
  String idPointMarker([Object? id]) => "marker_id_$id";
  const MapIdConstants();
}
