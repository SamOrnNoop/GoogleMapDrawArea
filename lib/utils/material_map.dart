import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:learn_map/utils/base_print.dart';
import 'package:learn_map/utils/marker_custome.dart';
import 'package:learn_map/widgets/widget_marker.dart';

BitmapDescriptor? _iconPoint;
BitmapDescriptor? _udpateIconPoint;

class MaterialGoogleMap {
  static CameraPosition cameraPosition =
      CameraPosition(target: const LatLng(11.58330103577817, 104.88023529639402), zoom: minMaxZoomPreference.minZoom!);

  static MinMaxZoomPreference minMaxZoomPreference = const MinMaxZoomPreference(16, 40);

  static BitmapDescriptor get iconPoint => _iconPoint ?? BitmapDescriptor.defaultMarker;

  static BitmapDescriptor get updateIconPoint => _udpateIconPoint ?? BitmapDescriptor.defaultMarker;

  static void initIconMarker() async {
    _iconPoint ??= await ToBitDescription(WidgetMarker.icon()).toBitmapDescriptor();
    _udpateIconPoint ??= await ToBitDescription(
      WidgetMarker.icon(fillColor: Colors.blue, borderColor: Colors.yellow, size: 18),
    ).toBitmapDescriptor();
    Geolocator.getCurrentPosition();
    BaseLogger.log('Has downloaded and saved Icon point');
  }

  static LatLng getAdviceMediatePointHandle(LatLng startPoint, LatLng targetPoint, [int advice = 2]) {
    return LatLng(startPoint.latitude + (targetPoint.latitude - startPoint.latitude) / advice,
        startPoint.longitude + (targetPoint.longitude - startPoint.longitude) / advice);
  }

  static void onAnimatedZoomToCurrent(GoogleMapController cxt) {
    Geolocator.checkPermission().then((permission) {
      BaseLogger.printError(permission);
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        Geolocator.openAppSettings();
      } else {
        Geolocator.getLastKnownPosition().then((position) async {
          if (position == null) return;
          cxt.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(target: LatLng(position.latitude, position.longitude), zoom: 19),
          ));
        });
      }
    });
  }
}
