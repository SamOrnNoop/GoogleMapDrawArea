import 'package:flutter/material.dart';
import 'package:geodesy/geodesy.dart' as desy;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:learn_map/utils/defualt_scaffold.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as toolkit;

Set<Polyline> _polylin = {};

class PreviewMapPage extends StatelessWidget {
  final double zoom;

  final Set<Polyline> polylin;
  PreviewMapPage({super.key, required this.polylin, this.zoom = 15}) {
    _polylin.addAll(polylin);
  }

  desy.Geodesy get instance => desy.Geodesy();

  List<desy.LatLng> get points => List.generate(
        polylin.first.points.length,
        (index) => desy.LatLng(polylin.first.points[index].latitude, polylin.first.points[index].longitude),
      );

  List<desy.LatLng> get bounds => instance.getRectangleBounds(points);

  double get length => instance.calculatePolyLineLength(bounds);

  double get matter2 {
    // final double m = length / 4;
    // return m * m;

    return toolkit.SphericalUtil.computeArea(points.map((e) => toolkit.LatLng(e.latitude, e.longitude)).toList())
        .toDouble();
  }

  double get aA => matter2 / 100;

  double get hA => aA / 100;

  desy.LatLng get center => instance.findPolygonCentroid(points);

  @override
  Widget build(BuildContext context) {
    final LatLng target = LatLng(center.latitude, center.longitude);

    return DefaultScaffold(
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.satellite,
            initialCameraPosition: CameraPosition(target: target, zoom: 18),
            polygons: Set.of({
              Polygon(
                polygonId: PolygonId(polylin.first.polylineId.value),
                fillColor: Colors.white54,
                strokeWidth: 2,
                strokeColor: Colors.white,
                points: polylin.first.points,
              ),
            }),
            // polylines: polylin,
          ),
          Positioned(
            bottom: 5,
            left: 5,
            child: _detailWidgetBuilder(),
          )
        ],
      ),
    );
  }

  Widget _detailWidgetBuilder() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _tileTitle("ឈ្មោះ", "សុខ ចាន់ដារ៉ា"),
          _tileTitle("ភេទ", "ប្រុស"),
          _tileTitle("អាយុ", "៣៩"),
          _tileTitle("កូដ", "PAC00_31"),
          _tileTitle("ផ្ទែក្រឡា",
              "${numberConvertedToKh(matter2.toStringAsFixed(2))} ម៉ែត្រការ៉េ/m²\n${numberConvertedToKh(aA.toStringAsFixed(2))} អា\n${numberConvertedToKh(hA.toStringAsFixed(2))} ហិតា"),
          _tileTitle("ប្រវែងសរុប", "${numberConvertedToKh(length)} ម៉ែត្រ/m"),
        ],
      ),
    );
  }
}

Widget _tileTitle(String title, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$title : "),
        Padding(
          padding: const EdgeInsets.only(left: 5),
          child: Text(value),
        ),
      ],
    ),
  );
}

// double calculatePolygonAreaM2(List<LatLng> polygonPoints) {
//   if (polygonPoints.length < 3) {
//     return 0.0; // A polygon needs at least 3 points to have an area
//   }

//   // Convert Maps_flutter.LatLng to latlong2.LatLng
//   final List<latlong.LatLng> latlong2Points =
//       polygonPoints.map((p) => latlong.LatLng(p.latitude, p.longitude)).toList();

//   // The `Area.byGreatCircle` method calculates the area directly in square meters.
//   final areaInSquareMeters = latlong.G

//   return areaInSquareMeters;
// }
// LatLng calculateCentroid(List<desy.LatLng> points) {
//   if (points.isEmpty) {
//     return const LatLng(0, 0); // Or handle empty list case appropriately
//   }

//   double latitudeSum = 0;
//   double longitudeSum = 0;

//   for (final point in points) {
//     latitudeSum += point.latitude;
//     longitudeSum += point.longitude;
//   }

//   final double averageLatitude = latitudeSum / points.length;
//   final double averageLongitude = longitudeSum / points.length;

//   return LatLng(averageLatitude, averageLongitude);
// }

String? numberConvertedToKh(Object? number) {
  if (number == null) return null;
  List<String> result = [];
  String n = "$number";
  for (String value in n.characters) {
    num? rt = num.tryParse(value);
    result.add(_listKhmerNumber(rt ?? value));
  }
  return result.join();
}

String _listKhmerNumber(Object nums) => switch (nums) {
      0 => "០",
      1 => "១",
      2 => "២",
      3 => "៣",
      4 => "៤",
      5 => "៥",
      6 => "៦",
      7 => "៧",
      8 => "៨",
      9 => "៩",
      _ => "$nums"
    };
