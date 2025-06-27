import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

var circle = Circle(
  circleId: const CircleId('dottedCircle'),
  center: const LatLng(20.5937, 78.9629),
  radius: 500,
  strokeWidth: 0,
  fillColor: Colors.orangeAccent.withOpacity(.25),
);
var polyline = Polyline(
  polylineId: const PolylineId('dottedCircle'),
  color: Colors.deepOrange,
  width: 2,
  patterns: [
    PatternItem.dash(20),
    PatternItem.gap(20),
  ],
  points: List<LatLng>.generate(360,
      (index) => calculateNewCoordinates(11.583666938519569, 104.88009743705771, 500, double.parse(index.toString()))),
);

LatLng calculateNewCoordinates(double lat, double lon, double radiusInMeters, double angleInDegrees) {
  // Convert angle from degrees to radians
  double PI = 3.141592653589793238;

  double angleInRadians = angleInDegrees * PI / 180;

  // Constants for Earth's radius and degrees per meter
  const earthRadiusInMeters = 6371000; // Approximate Earth radius in meters
  const degreesPerMeterLatitude = 1 / earthRadiusInMeters * 180 / pi;
  final degreesPerMeterLongitude = 1 / (earthRadiusInMeters * cos(lat * PI / 180)) * 180 / pi;

  // Calculate the change in latitude and longitude in degrees
  double degreesOfLatitude = radiusInMeters * degreesPerMeterLatitude;
  double degreesOfLongitude = radiusInMeters * degreesPerMeterLongitude;

  // Calculate the new latitude and longitude
  double newLat = lat + degreesOfLatitude * sin(angleInRadians);
  double newLon = lon + degreesOfLongitude * cos(angleInRadians);
  return LatLng(newLat, newLon);
}
