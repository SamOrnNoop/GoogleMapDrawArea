import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:learn_map/utils/base_print.dart';
import 'package:learn_map/utils/material_map.dart';

import '../map_shape_preview_detail.dart';

class GetxDrawWithPointController extends GetxController {
  GoogleMapController? controller;
  final List<LatLng> _points = [];
  final Set<Marker> _markerPoint = {};
  // Set<Polyline> _polylinePoint = {};

  void onCreateController(GoogleMapController cxt) => controller = cxt;
  Set<Marker> get getMarkerPoint => _markerPoint;
  Set<Polyline> polylinePoint() => Set.of({
        Polyline(
          consumeTapEvents: false,
          polylineId: const PolylineId('aa'),
          points: _points.toList(),
          jointType: JointType.bevel,
          onTap: () {},
        ),
      });

  bool isMatchingOnlyFirst(LatLng position) {
    return isWhereMatching(_points.first, position);
  }

  bool get isLastAndFirstMatchingPoistion {
    return _points.length > 2 && isWhereMatching(_points.first, _points.last);
  }

  bool isWhereMatching(LatLng first, LatLng second) {
    return <LatLng>{first}.intersection({second}).isNotEmpty;
  }

  void addPoint(LatLng latLong) {
    _points.add(latLong);
    update();
  }

  void onChangedPoistion(LatLng position) {
    if (isLastAndFirstMatchingPoistion) return;
    _markerPoint.add(Marker(
        anchor: const Offset(0.5, 0.5),
        markerId: MarkerId("${_points.length + 1}"),
        icon: MaterialGoogleMap.iconPoint,
        consumeTapEvents: true,
        position: position,
        draggable: true,
        onDrag: (drag) {},
        onTap: () async {
          if (!isLastAndFirstMatchingPoistion && isMatchingOnlyFirst(position)) {
            if (_points.length > 2) {
              addPoint(position);

              Future.delayed(500.milliseconds, () async {
                final double? zoom = await controller?.getZoomLevel();
                showBottomSheetView(polylinePoint(), zoom);
              });
            }
          }
        }));
    addPoint(position);

    BaseLogger.log(position);
  }
}

void showBottomSheetView(Set<Polyline> polylin, double? zoom) async {
  await showModalBottomSheet(
      context: Get.context!,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
          ),
          child: Center(
              child: ElevatedButton(
            child: const SizedBox(height: 50, width: double.infinity, child: Center(child: Text("Detail Preview"))),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => PreviewMapPage(
                    polylin: polylin,
                    zoom: zoom ?? 15,
                  ),
                ),
              );
            },
          )),
        );
      });
}
