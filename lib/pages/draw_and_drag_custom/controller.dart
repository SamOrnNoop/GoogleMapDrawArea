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
import 'package:learn_map/utils/constants.dart';
import 'package:learn_map/utils/material_map.dart';
import 'animation_controller.dart';

int _markerId = 0;

class DragCustomEventGetXController extends PointController {
  DrawMapAnimationController get animatedController => Get.put(DrawMapAnimationController());

  GoogleMapsFlutterPlatform get mapservice => GoogleMapsFlutterPlatform.instance;

  Size get constraints => Get.size;

  MapIdConstants constMapId = const MapIdConstants();

  GoogleMapController? controller;

  List<LatLng> get onlyPoints => _mainPoints.map((e) => e.point).toList();

  List<SelectedPoint> undoPoints = [];

  FocusNode focusNode = FocusNode();

  SelectedPoint? selectedPoint;

  TextEditingController seachMapController = TextEditingController();

  GlobalKey<State<GoogleMap>> mapGlobalKey = GlobalKey();

  bool isScrollHandleTrack = true;

  bool isToggleWalkTrack = false;

  bool isSinglePointerDrag = false;

  bool isMarkerDarg = false;

  int get mapId => controller?.mapId ?? 0;

  bool _isToggleDrag = false;
  bool get isToggleDrag => _isToggleDrag;
  Rx<bool> enableMenuSearchPlace = false.obs;

  String? querySearch;

  bool ignoreMap = false;

  Set<Marker> get pointMaker {
    return List.generate(onlyPoints.length, (index) {
      SelectedPoint e = _mainPoints[index];
      return _marker(e.point, index == _mainPoints.length - 1 && onlyPoints.length > 2 ? _mainPoints.first.id : e.id)
          .copyWith(
        iconParam: selectedPoint != null && selectedPoint!.id == e.id ? MaterialGoogleMap.updateIconPoint : null,
      );
    }).toSet();
  }

  void onUnrequestField() {
    enableMenuSearchPlace.value = focusNode.hasPrimaryFocus;
    focusNode.unfocus();
  }

  void onToggleWalkTrack() {
    if (_isToggleDrag) return;
    if (onlyPoints.isNotEmpty) {
      confirmNewField(() {
        onRemoveMap();
        Get.back();
        update();
      });
      return;
    }

    isToggleWalkTrack = isToggleWalkTrack.toggle();

    if (!isToggleWalkTrack && onlyPoints.isNotEmpty) _onConnectionLine();
    if (isToggleWalkTrack) MaterialGoogleMap.onNewPOSITION(controller!, 21);

    update();
  }

  void onToggleDrag() {
    _isToggleDrag = _isToggleDrag.toggle();
    update();
  }

  @override
  void onInit() {
    resetIdmarker();
    WidgetsBinding.instance.cancelPointer(0);
    MaterialGoogleMap.initIconMarker();
    focusNode.addListener(() {
      enableMenuSearchPlace.value = focusNode.hasPrimaryFocus;
    });

    seachMapController.addListener(() {
      final String text = seachMapController.text;
      querySearch = text.isEmpty ? null : text;
      update();
    });
    super.onInit();
  }

  void onCreateController(GoogleMapController cxt) async {
    mapservice.init(cxt.mapId);
    controller = cxt;
    MaterialGoogleMap.onAnimatedZoomToCurrent(cxt);
  }

  Polyline _polyViewLine(List<LatLng> latlngs) {
    return Polyline(
      polylineId: const PolylineId('polylin'),
      points: latlngs,
      color: Colors.indigo,
      patterns: [
        PatternItem.gap(20),
        PatternItem.dash(20),
      ],
      width: 2,
    );
  }

  Set<Polyline> get polylin {
    return {_polyViewLine(onlyPoints)};
  }

  Future<void> updateMarker(SelectedPoint value) async {
    onMoveMarkerChangeToSelect(old: selectedPoint, newSelect: value);
    selectedPoint = value;
  }

  void onMoveMarkerChangeToSelect({final SelectedPoint? old, required SelectedPoint newSelect}) {
    if (old != null) {
      /// unselected marker
      final Marker updateMarker = _marker(old.point, old.id);
      mapservice.updateMarkers(
          MarkerUpdates.from({updateMarker.copyWith(iconParam: MaterialGoogleMap.updateIconPoint)}, {updateMarker}),
          mapId: mapId);
    }

    /// Selected new marker
    final Marker updateMarker = _marker(newSelect.point, newSelect.id);
    mapservice.updateMarkers(
        MarkerUpdates.from({updateMarker}, {updateMarker.copyWith(iconParam: MaterialGoogleMap.updateIconPoint)}),
        mapId: mapId);
  }

  void onRemoveMap() {
    if (selectedPoint != null) {
      // _onRemoveMarkerById(selectedPoint!.id);
      _mainPoints.removeWhere((value) => value.id == selectedPoint!.id);
      selectedPoint = null;
      isMarkerDarg = false;
      polylin.clear();
      isScrollHandleTrack = true;

      _onConnectionLine();
    } else {
      pointMaker.clear();
      _mainPoints.clear();
      undoPoints.clear();
      // pointMaker = {};
      resetIdmarker();
    }

    update();
  }

  void onSelectReset(LatLng latlng) async {
    isMarkerDarg = false;
    // _removeIconSuggession();
    _onResetMarkerToDefualt();
    bool isOnPolylin = PolylineAnalyzer(onlyPoints).isFind180Degree(latlng, (index, position) {
      pointMaker.add(_marker(latlng, constMapId.idPointMarker(latlng.hashCode)));
      // mainPoints.insert(index, );
      onInsertPointWithGenId(index, position);
    });
    if (!isOnPolylin) selectedPoint = null;

    update();
  }

  void onUndoPoint() async {
    // int indexWhere = onlyPoints.indexWhere((element) => SelectedPoint.isOnPoint(element, undoPoints.last.point));
    if (undoPoints.isEmpty) return;
    final LatLng targetUndo = undoPoints.last.point;
    int index = indexWherePoint(point: targetUndo);

    if (index.isNegative) return;

    SelectedPoint element = _mainPoints[index];
    updateMarker(element);
    _mainPoints[index] = element..point = undoPoints.last.undoPoint;
    // points[indexWhere] = targetUndo;

    undoPoints.removeLast();
    update();
  }

  // EdgeInsets get viewSafe => MediaQuery.of(Get.context!).systemGestureInsets;

  // Get poistion of latlong from screen calculation.
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

          bool isAllow = MaterialGoogleMap.isBearingCalulat(matters, selectedPoint!.point, latLng, false);
          isSinglePointerDrag = isAllow;
          if (isAllow) {
            isScrollHandleTrack = false;
          } else {
            isScrollHandleTrack = true;
          }
          update();
        };

  void Function(PointerHoverEvent)? get pointerHoverEvent => (event) {
        // isSinglePointerDrag = event.device >= 1;

        if (isSinglePointerDrag) return;
        if (selectedPoint != null) {
          if (!selectedPoint!.isMomentPoint(selectedPoint!.undoPoint)) {
            selectedPoint!.undoPoint = selectedPoint!.point;
          }
        }

        if (enableMenuSearchPlace.value) onUnrequestField();
        if (isToggleDrag) {
          isScrollHandleTrack = false;
          return update();
        } else {
          if (onlyPoints.isEmpty) return;
          // isScrollHandleTrack = true;
          onHandleScrollMap?.call(event);
          // return update();
        }
      };
  void Function(PointerDownEvent)? get pointerEventStart => (event) {
        if (selectedPoint != null) {
          if (undoPoints.isEmpty) return;
          if (!undoPoints.last.isMomentPoint(selectedPoint!.point)) {
            selectedPoint!.undoPoint = selectedPoint!.point;
          }
          isMarkerDarg = true;
          update();
        }
      };

  void Function(ScaleUpdateDetails)? get onDragUpdate => switch (isToggleDrag) {
        true => (details) => onDragCreatePoint(details),
        false when isMarkerDarg => (details) => onDragUpdatePositionPoint(details),
        _ => null,
      };

  void onDragCreatePoint(ScaleUpdateDetails details) async {
    if (isSinglePointerDrag) return;
    isMarkerDarg = false;
    getDrag(details.focalPoint).then((latLng) {
      if (onlyPoints.isEmpty) {
        onAddPointWithGenId(latLng);
        onAddPointWithGenId(latLng);
        update();
        return;
      }
      int index = onlyPoints.length - 2;
      bool isLong = MaterialGoogleMap.isBearingCalulat(3, onlyPoints[index], latLng);

      if (isLong) {
        onInsertPointWithGenId(index, latLng);
        mapservice.updateMarkers(
            MarkerUpdates.from({_marker(onlyPoints.last, constMapId.idPointMarker(2))},
                {_marker(latLng, constMapId.idPointMarker(2))}),
            mapId: mapId);
        mapservice.updatePolylines(
            PolylineUpdates.from(
              {polylin.first.copyWith(pointsParam: onlyPoints)},
              polylin,
            ),
            mapId: mapId);
      }
    });
  }

  void onDragUpdatePositionPoint(ScaleUpdateDetails details) async {
    double zoom = await controller!.getZoomLevel();

    if (isSinglePointerDrag) {
      final LatLng latLng = await getDrag(details.focalPoint);
      final double matters = MaterialGoogleMap.scaleOfmatters(zoom, claim: 15);
      bool isAllowDrag = MaterialGoogleMap.isBearingCalulat(matters, selectedPoint!.point, latLng, false);
      isMarkerDarg = true;
      if (!isAllowDrag) return;

      if (selectedPoint == null) return;
      if (isScrollHandleTrack) {
        isScrollHandleTrack = false;
        update();
      }
      if (selectedPoint!.isMomentPoint(onlyPoints.first) && selectedPoint!.isMomentPoint(onlyPoints.last)) {
        onMoveFirstAndLastLine(SelectedPoint(id: selectedPoint!.id, point: latLng));
      } else {
        onUpdatePoint(latLng, id: selectedPoint!.id);
      }

      mapservice.updateMarkers(
          MarkerUpdates.from({
            _marker(latLng, selectedPoint!.id).copyWith(
              iconParam: MaterialGoogleMap.updateIconPoint,
            )
          }, {
            _marker(selectedPoint!.point, selectedPoint!.id).copyWith(
              iconParam: MaterialGoogleMap.updateIconPoint,
            )
          }),
          mapId: mapId);
      mapservice.updatePolylines(
          PolylineUpdates.from(
            {polylin.first.copyWith(pointsParam: onlyPoints)},
            polylin,
          ),
          mapId: mapId);
      selectedPoint!.point = latLng;
      // selectedPoint = SelectedPoint(id: selectedPoint!.id, value: latLng)..undoPoint = selectedPoint!.undoPoint;
    }
    // update();
  }

  void Function(PointerUpEvent)? get pointerEndEvent => (event) async {
        isScrollHandleTrack = true;
        isSinglePointerDrag = false;
        if (isToggleDrag) {
          animatedController.onGetAnimation();
          await onDragEndFindCurveAndConer();
          onToggleDrag();
          return;
        }
        if (selectedPoint != null) {
          if (selectedPoint!.isMomentPoint(selectedPoint!.undoPoint)) return;
          undoPoints.add(selectedPoint!);
        }
        update();
      };

  void onGetWalkingTrack() async {
    Geolocator.checkPermission().then((permission) {
      if (MaterialGoogleMap.isOnlyDenied(permission)) {
        ScaffoldMessenger.of(Get.context!).showSnackBar(const SnackBar(content: Text("No permission GPS")));
      }
    });
    Position position = await Geolocator.getCurrentPosition();
    LatLng latlng = LatLng(position.latitude, position.longitude);

    onAddPointWithGenId(latlng);
    // points.add(latlng);
    pointMaker.add(_marker(
      latlng,
      const MapIdConstants().idPointMarker(latlng.latitude.hashCode),
    ));

    update();
  }

  Future<void> onDragEndFindCurveAndConer() async {
    await Future<void>.delayed(350.milliseconds);
    pointMaker.clear();
    polylin.clear();
    List<LatLng> resultPoints = PolylineAnalyzer.findCornersAndCurves(onlyPoints);

    int lastIndex = resultPoints.length - 1;

    bool isBearing = MaterialGoogleMap.isBearingCalulat(15, resultPoints[lastIndex - 1], resultPoints.last);
    if (isBearing) {
      LatLng getAdvide = MaterialGoogleMap.getPointBetweenHandle(resultPoints[lastIndex - 1], resultPoints.last);
      resultPoints.insert(lastIndex, getAdvide);
    }

    onReAssignPoint(resultPoints);

    return;
  }

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
        SelectedPoint select = SelectedPoint(id: id, point: latlng)..undoPoint = latlng;
        updateMarker(select);
        BaseLogger.log("Marker Tap lng: $latlng : id:$id ");
        update();
      },
      position: latlng,
    );
  }

  void _onConnectionLine() {
    if (<LatLng>{onlyPoints.first}.difference({onlyPoints.last}).isNotEmpty) {
      onAddPointWithGenId(onlyPoints.first);
    }
    return;
  }

  void _onResetMarkerToDefualt([bool isDefault = true]) {
    if (selectedPoint != null) {
      // _onRemoveMarkerById(selectedPoint!.id);
      if (isDefault) {
        pointMaker.add(_marker(selectedPoint!.point, selectedPoint!.id));
      } else {
        pointMaker.add(_marker(selectedPoint!.point, selectedPoint!.id).copyWith(
          iconParam: MaterialGoogleMap.updateIconPoint,
        ));
      }
    }
  }
}

class SelectedPoint {
  final String id;
  LatLng point;

  SelectedPoint({required this.id, required this.point});

  bool isMomentPoint(LatLng latlng) {
    return latlng.latitude == point.latitude && latlng.longitude == point.longitude;
  }

  static bool isOnPoint(LatLng p1, LatLng p2) {
    return SelectedPoint(id: '', point: p1).isMomentPoint(p2);
  }

  LatLng undoPoint = const LatLng(0.0, 0.0);

  @override
  String toString() {
    return "SelectedPoint(id: $id, point: $point, undoPoint: $undoPoint)";
  }
}

abstract class PointController extends GetxController {
  List<SelectedPoint> _mainPoints = [];

  String get markerIdPrimary {
    _markerId = _markerId + 1;
    return const MapIdConstants().idPointMarker(_markerId);
  }

  void resetIdmarker() => _markerId = 0;

  void onAddPointWithGenId(LatLng p) => _mainPoints.add(
        SelectedPoint(id: markerIdPrimary, point: p),
      );

  void onInsertPointWithGenId(int index, LatLng p) =>
      _mainPoints.insert(index, SelectedPoint(id: markerIdPrimary, point: p));

  void onUpdatePoint(LatLng point, {String? id}) {
    int index = indexWherePoint(id: id, point: point);
    if (index.isNegative) return;
    _mainPoints[index].point = point;
    return;
  }

  void onMoveFirstAndLastLine(SelectedPoint value) {
    _mainPoints.first = value;
    _mainPoints.last = value;
  }

  void onReAssignPoint(List<LatLng> points) {
    _markerId = 0;
    _mainPoints = points.map((p) => SelectedPoint(id: markerIdPrimary, point: p)).toList();
  }

  int indexWherePoint({String? id, LatLng? point}) => _mainPoints.indexWhere((e) => _matchPoint(e, id, point));

  SelectedPoint wherePoint({String? id, LatLng? point}) => _mainPoints.where((e) => _matchPoint(e, id, point)).first;

  bool _matchPoint(SelectedPoint element, String? id, LatLng? point) =>
      element.id == id || (point != null && element.isMomentPoint(point));
}

class MapIdConstants {
  // final String idPrevMarker = 'marker_id_prev';
  // final String idNextMarker = 'marker_id_next';
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
