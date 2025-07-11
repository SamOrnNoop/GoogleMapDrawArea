import 'dart:math';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:learn_map/utils/base_print.dart';

import '../utils/material_map.dart';

class PolylineAnalyzer {
  static List<LatLng> findCornersAndCurves(List<LatLng> polylineCoordinates) {
    Set<LatLng> points = {};
    if (polylineCoordinates.length < 3) {
      return []; // Not enough points to form corners
    }

    for (int i = 1; i < polylineCoordinates.length - 1; i++) {
      LatLng prevPoint = polylineCoordinates[i - 1];
      LatLng currentPoint = polylineCoordinates[i];
      LatLng nextPoint = polylineCoordinates[i + 1];

      double angle = _calculateAngle(prevPoint, currentPoint, nextPoint);
      BaseLogger.log(angle);
      if (angle > 30 && angle < 60) {
        points.add(currentPoint);
      } else if (_specifiAgngle.contains(angle.round())) {
        if (points.isEmpty) {
          points.add(currentPoint);
        } else {
          if (MaterialGoogleMap.isBearingCalulat(2, points.last, currentPoint)) {
            points.add(currentPoint);
          }
        }
      }
    }
    List<LatLng> resultPoints = points.toList();
    resultPoints.insert(0, polylineCoordinates.first);
    resultPoints.add(polylineCoordinates.first);
    return resultPoints;
  }

  static double _calculateAngle(LatLng prevPoint, LatLng currentPoint, LatLng nextPoint) {
    double angle1 = atan2(prevPoint.latitude - currentPoint.latitude, prevPoint.longitude - currentPoint.longitude);
    double angle2 = atan2(nextPoint.latitude - currentPoint.latitude, nextPoint.longitude - currentPoint.longitude);
    double angle = (angle2 - angle1) * 180 / pi;
    if (angle < 0) {
      angle += 360;
    }
    return angle;
  }

  static const List<int> _specifiAgngle = [0, 70, 80, 90, 100, 110, 120, 130, 140, 150, 160, 170, 178];
}
