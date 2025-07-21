import 'dart:async';
import 'package:flutter/gestures.dart';
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

import 'animation_controller.dart';

class DragCustomEventGetXController extends GetxController {
  DrawMapAnimationController get animatedController => Get.put(DrawMapAnimationController());
  Size get constraints => Get.size;
  MapIdConstants constMapId = const MapIdConstants();
  GoogleMapController? controller;
  List<LatLng> points = [];
  Set<Marker> pointMaker = {};
  Set<Circle> circleCurrentPoint = {};
  SelectedPoint? selectedPoint;
  TextEditingController seachMapController = TextEditingController();
  double zoomeCircle = 1;
  bool isScrollHandleTrack = true;
  bool isToggleWalkTrack = false;

  bool isSinglePointerDrag = true;

  bool isZoomProcessing = false;
  // LatLng? setlectLatLong;

  GoogleMapsFlutterPlatform get mapservice => GoogleMapsFlutterPlatform.instance;

  bool isMarkerDarg = false;

  int get mapId => controller?.mapId ?? 0;

  bool _isToggleDrag = false;

  bool get isToggleDrag => _isToggleDrag;
  void onToggleWalkTrack() {
    if (_isToggleDrag) return;
    if (points.isNotEmpty) {
      confirmNewField(() {
        onRemoveMap();
        Get.back();
        update();
      });
      return;
    }

    isToggleWalkTrack = isToggleWalkTrack.toggle();

    if (!isToggleWalkTrack && points.isNotEmpty) _onConnectionLine();
    if (isToggleWalkTrack) MaterialGoogleMap.onNewPOSITION(controller!, 21);

    update();
  }

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

  Rx<bool> ignoreValue = false.obs;

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

  void onRemoveMap() {
    if (selectedPoint != null) {
      _onRemoveMarkerById(selectedPoint!.id);
      points.removeWhere((value) => selectedPoint!.isMomentPoint(value));
      selectedPoint = null;
      isMarkerDarg = false;
      isScrollHandleTrack = true;
      _onConnectionLine();
    } else {
      pointMaker.clear();
      points.clear();
      pointMaker = {};
      points = [];
    }

    update();
  }

  void onSelectReset(LatLng latlng) async {
    isMarkerDarg = false;
    // _removeIconSuggession();
    _onResetMarkerToDefualt();
    bool isOnPolylin = PolylineAnalyzer(points).isFind180Degree(latlng, (index, position) {
      pointMaker.add(_marker(latlng, constMapId.idPointMarker(latlng.hashCode)));
      points.insert(index, position);
    });
    if (!isOnPolylin) selectedPoint = null;

    update();
  }

  EdgeInsets get viewSafe => MediaQuery.of(Get.context!).systemGestureInsets;
  Future<LatLng> getDrag(Offset globalPosition) async {
    /// finde context map
    final BuildContext mapContext = mapGlobalKey.currentContext!;
    final RenderBox renderBox = mapContext.findRenderObject() as RenderBox;
    final Offset localOffset = renderBox.localToGlobal(globalPosition);
    final MediaQueryData globalQuery = MediaQuery.of(Get.context!);
    final double devicePixelRatio = globalQuery.devicePixelRatio;
    // Make screen position in map
    final int screenX = (localOffset.dx * devicePixelRatio - 2).round();
    final int screenY = (localOffset.dy * devicePixelRatio - 2).round();
    final location = await controller?.getLatLng(ScreenCoordinate(x: screenX, y: screenY));
    return Future<LatLng>.value(location);
  }

  void Function(PointerHoverEvent)? get onHandleScrollMap => selectedPoint == null
      ? null
      : (event) async {
          final LatLng latLng = await getDrag(event.position);
          final double zoom = await controller!.getZoomLevel();
          final double matters = MaterialGoogleMap.scaleOfmatters(zoom, claim: 1);

          bool isAllow = MaterialGoogleMap.isBearingCalulat(matters, selectedPoint!.value, latLng, false);
          isSinglePointerDrag = isAllow;
          if (isAllow) {
            isScrollHandleTrack = false;
          } else {
            isScrollHandleTrack = true;
          }

          update();
        };

  void Function(ScaleStartDetails)? get startDrag => switch (isMarkerDarg) {
        true => (detail) {
            // isSinglePointerDrag = detail.pointerCount == 1;
          },
        _ => null,
      };

  void Function(ScaleEndDetails)? get endDragDrag => switch (isToggleDrag) {
        true => (detail) {
            onToggleDrag();
            animatedController.onGetAnimation();
            onDragEndFindCurveAndConer();
          },
        false when isMarkerDarg => (v) async {
            await Future.delayed(50.milliseconds);

            if (selectedPoint != null && isZoomProcessing) {
              controller?.animateCamera(CameraUpdate.newLatLng(selectedPoint!.value));
              isZoomProcessing = false;
            }
          },
        _ => null,
      };
  GlobalKey<State<GoogleMap>> mapGlobalKey = GlobalKey();
  void Function(ScaleUpdateDetails)? get onDragUpdate => switch (isToggleDrag) {
        true => (details) => onDragCreatePoint(details),
        false when isMarkerDarg => (details) => onDragUpdatePositionPoint(details),
        _ => null,
      };

  void onDragCreatePoint(ScaleUpdateDetails details) async {
    getDrag(details.focalPoint).then((latLng) {
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

  void onDragUpdatePositionPoint(ScaleUpdateDetails details) async {
    double zoom = await controller!.getZoomLevel();

    if (isSinglePointerDrag) {
      final LatLng latLng = await getDrag(details.focalPoint);
      isMarkerDarg = true;

      final double matters = MaterialGoogleMap.scaleOfmatters(zoom, claim: 15);
      bool isAllowDrag = MaterialGoogleMap.isBearingCalulat(matters, selectedPoint!.value, latLng, false);
      if (!isAllowDrag) return;

      if (selectedPoint == null) return;
      isScrollHandleTrack = false;
      if (selectedPoint!.isMomentPoint(points.first) && selectedPoint!.isMomentPoint(points.last)) {
        points.first = latLng;
        points.last = latLng;
      } else {
        int indexWhere = points.indexWhere((point) => selectedPoint!.isMomentPoint(point));
        if (indexWhere.isNegative) return;
        points[indexWhere] = latLng;
      }

      selectedPoint = SelectedPoint(id: selectedPoint!.id, value: latLng);

      updateMarker(selectedPoint!);
    }
    update();
  }

  void onGetWalkingTrack() async {
    Geolocator.checkPermission().then((permission) {
      if (MaterialGoogleMap.isOnlyDenied(permission)) {
        ScaffoldMessenger.of(Get.context!).showSnackBar(const SnackBar(content: Text("No permission GPS")));
      }
    });
    Position position = await Geolocator.getCurrentPosition();
    LatLng latlng = LatLng(position.latitude, position.longitude);

    points.add(latlng);
    pointMaker.add(_marker(
      latlng,
      const MapIdConstants().idPointMarker(latlng.latitude.hashCode),
    ));

    update();
  }

  void onDragEndFindCurveAndConer() async {
    // if (isMarkerDarg) {
    //   isMarkerDarg = false;
    //   _isToggleDrag = false;
    //   selectedPoint = null;
    //   update();
    //   return;
    // }
    await Future<void>.delayed(350.milliseconds);
    pointMaker.clear();

    List<LatLng> resultPoints = PolylineAnalyzer.findCornersAndCurves(points);

    int lastIndex = resultPoints.length - 1;

    bool isBearing = MaterialGoogleMap.isBearingCalulat(15, resultPoints[lastIndex - 1], resultPoints.last);
    if (isBearing) {
      LatLng getAdvide = MaterialGoogleMap.getPointBetweenHandle(resultPoints[lastIndex - 1], resultPoints.last);
      resultPoints.insert(lastIndex, getAdvide);
    }

    await Recurvice(resultPoints).forEach(callback: (index, value) {
      pointMaker.add(_marker(value, constMapId.idPointMarker(value.hashCode)));
    });

    points = resultPoints;
    update();
  }

  Future<(int, LatLng?)> wherePoint(SelectedPoint p) async =>
      await Recurvice(points).where((latlng) => p.isMomentPoint(latlng));

  Marker _marker(LatLng latlng, String id, [BitmapDescriptor? icon]) {
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
        // if (index != null) {
        //   points.insert(index, select.value);
        //   _onRemoveMarkerById(id);
        //   pointMaker.add(_marker(select.value, constMapId.idPointMarker(select.value)));
        // }
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

  void _onRemoveMarkerById(String id) => pointMaker.removeWhere((e) => e.markerId.value == id);

  void _onResetMarkerToDefualt([bool isDefault = true]) {
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

void confirmNewField([void Function()? back]) {
  showDialog(
      context: Get.context!,
      builder: (_) => AlertDialog(
            titlePadding: const EdgeInsets.all(5),
            contentPadding: const EdgeInsets.all(5),
            actionsPadding: const EdgeInsets.all(5),
            title: const Center(child: Text("បញ្ចាក់")),
            titleTextStyle: const TextStyle(color: Colors.black, fontSize: 18),
            content: const Text(
              "តើអ្នកប្រាកដទេក្នុងការសម្រេចចិត្តបង្កើតការវាស់ថ្មី?",
              textAlign: TextAlign.center,
            ),
            contentTextStyle: const TextStyle(fontSize: 16, color: Colors.black),
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
            actions: [
              TextButton(
                  onPressed: Get.back,
                  child: const Text(
                    "ទេ",
                  )),
              TextButton(
                onPressed: back,
                child: const Text(
                  "បាទ",
                  style: TextStyle(color: Colors.blueAccent),
                ),
              )
            ],
          ));
}

  // void onTapAndDragNewPoint(SelectedPoint selectP, [int? dragIndex]) async {
  //   int index = dragIndex ?? (await wherePoint(selectP)).$1;
  //   //  points.indexWhere((latlng) => selectP.isMomentPoint(latlng));
  //   if (index.isNegative) return;
  //   int length = points.length - 1;
  //   int prevIndex = switch (index) { 0 => length - 1, _ => index - 1 };
  //   int nextIndex = length == index ? 0 : index + 1;

  //   LatLng prevPoint = points[prevIndex];
  //   LatLng currentPoint = selectP.value;
  //   LatLng nextPoint = points[nextIndex];

  //   String idPrev = constMapId.idPrevMarker;
  //   String idNext = constMapId.idNextMarker;

  //   if (MaterialGoogleMap.isBearingCalulat(15, prevPoint, currentPoint)) {
  //     LatLng prev = MaterialGoogleMap.getAdviceMediatePointHandle(prevPoint, currentPoint);
  //     pointMaker.add(_marker(prev, idPrev, MaterialGoogleMap.iconSmall, prevIndex + 1));
  //   } else {
  //     _onRemoveMarkerById(idPrev);
  //   }

  //   if (MaterialGoogleMap.isBearingCalulat(15, currentPoint, nextPoint)) {
  //     LatLng next = MaterialGoogleMap.getAdviceMediatePointHandle(currentPoint, nextPoint);
  //     pointMaker.add(_marker(next, idNext, MaterialGoogleMap.iconSmall, nextIndex));
  //   } else {
  //     _onRemoveMarkerById(idNext);
  //   }
  // }