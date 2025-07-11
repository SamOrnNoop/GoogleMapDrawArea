import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:learn_map/utils/base_print.dart';
import 'package:learn_map/utils/marker_custome.dart';
import 'package:learn_map/widgets/widget_marker.dart';

BitmapDescriptor? _iconPoint;
BitmapDescriptor? _udpateIconPoint;
BitmapDescriptor? _suggestionIcon;

class MaterialGoogleMap {
  static CameraPosition cameraPosition =
      CameraPosition(target: const LatLng(11.58330103577817, 104.88023529639402), zoom: minMaxZoomPreference.minZoom!);

  static MinMaxZoomPreference minMaxZoomPreference = const MinMaxZoomPreference(16, 40);

  static BitmapDescriptor get iconPoint => _iconPoint ?? BitmapDescriptor.defaultMarker;

  static BitmapDescriptor get updateIconPoint => _udpateIconPoint ?? BitmapDescriptor.defaultMarker;

  static BitmapDescriptor get iconSmall => _suggestionIcon ?? BitmapDescriptor.defaultMarker;

  static void initIconMarker() async {
    ToBitDescription(WidgetMarker.icon()).toBitmapDescriptor().then((icon) => _iconPoint = icon);
    ToBitDescription(
      WidgetMarker.icon(fillColor: Colors.redAccent, borderColor: Colors.yellow, size: 18.0),
    ).toBitmapDescriptor().then((icon) => _udpateIconPoint = icon);
    ToBitDescription(WidgetMarker.icon(fillColor: Colors.green, borderColor: Colors.green, size: 12))
        .toBitmapDescriptor()
        .then((icon) => _suggestionIcon = icon);
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

  static bool isBearingCalulat(int long, LatLng start, LatLng end) {
    double calcu = Geolocator.distanceBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    );
    return calcu.ceil() > long;
  }
}
