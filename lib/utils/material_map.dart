import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:learn_map/utils/base_print.dart';
import 'package:learn_map/utils/marker_custome.dart';
import 'package:learn_map/widgets/widget_marker.dart';

BitmapDescriptor? _iconPoint;
BitmapDescriptor? _udpateIconPoint;

class MaterialGoogleMap {
  static CameraPosition cameraPosition =
      CameraPosition(target: const LatLng(11.58330103577817, 104.88023529639402), zoom: minMaxZoomPreference.minZoom!);

  static MinMaxZoomPreference minMaxZoomPreference = const MinMaxZoomPreference(15, 30);

  static BitmapDescriptor get iconPoint => _iconPoint ?? BitmapDescriptor.defaultMarker;

  static BitmapDescriptor get updateIconPoint => _udpateIconPoint ?? BitmapDescriptor.defaultMarker;

  static void initIconMarker() async {
    _iconPoint ??= await ToBitDescription(WidgetMarker.icon()).toBitmapDescriptor();
    _udpateIconPoint ??= await ToBitDescription(
      WidgetMarker.icon(fillColor: Colors.blue, borderColor: Colors.yellow, size: 18),
    ).toBitmapDescriptor();
    BaseLogger.log('Has downloaded and saved Icon point');
  }
}
