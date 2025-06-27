import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:learn_map/utils/marker_custome.dart';
import 'package:learn_map/widgets/widget_marker.dart';

List<FarmInformationModel> datas = <FarmInformationModel>[];

class DragAndDropMapController extends GetxController {
  late GoogleMapController mapController;
  List<LatLng> collectedLocation = <LatLng>[];
  Set<Marker> updatePositionByMaker = <Marker>{};

  BitmapDescriptor? customIconMarkerPoint;
  BitmapDescriptor? bigIconMain;
  double raduirsCircle = 20.0;
  // Uint8List? icon;
  // Uint8List? pointIcon;
  int lineSize = 2;
  Color lineColor = Colors.red;

  FarmInformationModel data = FarmInformationModel();
  @override
  void onInit() {
    init();
    super.onInit();
  }

  int get mapId => mapController.mapId;
  void init() async {
    // await Future.delayed(const Duration(milliseconds: 500));
    // customIconMarkerPoint = await MarkerCustome.widgetToIcon(widgetKey);
    customIconMarkerPoint = await ToBitDescription(WidgetMarker.icon()).toBitmapDescriptor();
    bigIconMain =
        await ToBitDescription(WidgetMarker.icon(fillColor: Colors.white, borderColor: Colors.green, size: 18))
            .toBitmapDescriptor();

    Position position = await Geolocator.getCurrentPosition();
    mapController.animateCamera(
        CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(position.latitude, position.longitude))));
    // GoogleMapsFlutterPlatform.instance.updateMarkers(markerUpdates, mapId: mapId).;

    // icon = await getBytesFromAsset('assets/images/pin.png', 40);
    // pointIcon = await getBytesFromAsset('assets/images/points.png', 20);
    // print(iconMaker?.assetName);
  }

  void onCreateMap(GoogleMapController controller) => mapController = controller;
  void onDraggerMarkerPointer() {
    final List<LatLng> points = collectedLocation;
    if (points.length > 1) {
      int betweentIndex = points.length - 2;
      final LatLng intermediatePoint = getAdviceMediatePointHandle(points[betweentIndex], points.last);
      collectedLocation.insert(betweentIndex + 1, intermediatePoint);
    }
  }

  void onAddnewPointBoforeOrNext(int index, bool next) {
    if (index < 1 || index == lastIndex) return;
    final LatLng currentPoints = collectedLocation[index];

    if (next) {
      final LatLng newXpiont = collectedLocation[index + 1];
      LatLng intermediatePoint = getAdviceMediatePointHandle(currentPoints, newXpiont);
      collectedLocation.insert(index, intermediatePoint);
    } else {
      final LatLng oldXpiont = collectedLocation[index - 1];
      LatLng intermediatePoint = getAdviceMediatePointHandle(currentPoints, oldXpiont);
      collectedLocation.insert(index, intermediatePoint);
    }
    return update();
  }

  bool pointsEmpty() {
    return collectedLocation.isEmpty;
  }

  void onUndoMap() {
    collectedLocation.removeLast();
    update();
  }

  void onDeleteMap([final int? index]) {
    if (index != null) collectedLocation.removeAt(index);
    if (!pointsEmpty()) collectedLocation.clear();
    return update();
  }

  Marker defaultMarkerOnLine(
    String id, {
    required LatLng point,
    bool enableTap = false,
    BitmapDescriptor? icon,
    final bool flat = false,
    void Function()? onTap,
    void Function(LatLng)? onDrag,
    void Function(LatLng)? onDragStart,
  }) {
    return Marker(
        consumeTapEvents: enableTap,
        draggable: true,
        markerId: MarkerId(id),
        onTap: onTap,
        position: point,
        flat: true,
        onDrag: onDrag,
        onDragStart: onDragStart,
        anchor: const Offset(0.5, 0.5),
        icon: icon ?? BitmapDescriptor.defaultMarker);
  }

  LatLng getAdviceMediatePointHandle(LatLng startPoint, LatLng targetPoint, [int advice = 2]) {
    return LatLng(startPoint.latitude + (targetPoint.latitude - startPoint.latitude) / advice,
        startPoint.longitude + (targetPoint.longitude - startPoint.longitude) / advice);
  }

  void onSetDataInformation(FarmInformationModel value) {
    data = value;
  }

  void onUpdateColors(final Color color) {
    if (lineColor.value == color.value) return;
    lineColor = color;
    update();
    Navigator.pop(Get.context!);
  }

  void onUpdateLineSize(final int size) {
    if (size == lineSize) return;
    lineSize = size;
    update();
    Navigator.pop(Get.context!);
  }

  void onChangePosition(LatLng latlong) async {
    // if (updatePositionByMaker.isNotEmpty) updatePositionByMaker.clear();

    collectedLocation.add(latlong);
    onDraggerMarkerPointer();
    update();
  }

  int get lastIndex => collectedLocation.length - 1;
  bool ifFindingMatch(LatLng latlng) {
    final LatLng first = collectedLocation.first;
    // final LatLng last = collectedLocation.last;
    return first.latitude == latlng.latitude && latlng.longitude == first.longitude;
  }

  void onDragUpdatePosition(PositionUpdated position) {
    final first = collectedLocation.first;
    final last = collectedLocation.last;

    if (collectedLocation[position.index] == first && collectedLocation[position.index] == last) {
      collectedLocation[0] = position.latlong;
      collectedLocation[lastIndex] = position.latlong;
    } else {
      collectedLocation[position.index] = position.latlong;
    }
    update();
  }

  void onClearPolyLine() {
    collectedLocation.clear();
    update();
  }
}

class PositionUpdated {
  int? _index;
  int get index => _index!;
  set setindex(int value) => _index = value;

  LatLng? _latLng;

  LatLng get latlong => _latLng!;
  set setlatlong(LatLng value) => _latLng = value;

  PositionUpdated();

  PositionUpdated.update(final int index, final LatLng ltlng) {
    setindex = index;
    setlatlong = ltlng;
  }
}

class PointMap {
  int? _id;
  List<LatLng> _points = [];

  int get id => int.tryParse(getUUID) ?? _id ?? 0;
  List<LatLng> get points => _points;
  set setId(int value) => _id = value;
  set setPoint(List<LatLng> values) => _points = values;
  void add(LatLng value) => _points.add(value);
  void insert(index, LatLng value) => _points.insert(index, value);
}

class FarmInformationModel {
  String? _code;
  String? _name;
  List<PointMap> _positionPoints = [];
  String get code => _code ?? "";
  String get name => _name ?? "";
  List<PointMap> get positionPoints => _positionPoints;

  set setname(String value) => _name = value;
  set setcode(String value) => _code = value;
  set setpoints(List<PointMap> values) => _positionPoints = values;
  FarmInformationModel();

  @override
  String toString() {
    return 'FarmInformationModel(name:$name, code: $code)';
  }
}

final Random _random = Random();
String _uuid = "123456789";
String get getUUID => String.fromCharCodes(
      Iterable.generate(
        4,
        (_) => _uuid.codeUnitAt(_random.nextInt(_uuid.length)),
      ),
    );
