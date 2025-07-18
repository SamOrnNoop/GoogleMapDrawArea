import 'dart:math';

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
      CameraPosition(target: const LatLng(11.257508998010033, 105.77254247662181), zoom: minMaxZoomPreference.minZoom!);

  static MinMaxZoomPreference minMaxZoomPreference = const MinMaxZoomPreference(17.5, 40);

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

  static LatLng getPointBetweenHandle(LatLng startPoint, LatLng targetPoint, [int advice = 2]) {
    return LatLng(startPoint.latitude + (targetPoint.latitude - startPoint.latitude) / advice,
        startPoint.longitude + (targetPoint.longitude - startPoint.longitude) / advice);
  }

  static void onAnimatedZoomToCurrent(GoogleMapController cxt) {
    return;
    Geolocator.checkPermission().then((permission) {
      BaseLogger.printError(permission);
      if (isOnlyDenied(permission)) {
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

  static bool isOnlyDenied(LocationPermission permission) {
    return permission == LocationPermission.denied || permission == LocationPermission.deniedForever;
  }

  static bool isBearingCalulat(double long, LatLng start, LatLng end, [bool isGreaterthan = true]) {
    double calcu = Geolocator.distanceBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    );
    return isGreaterthan ? calcu.ceil() > long : calcu.ceil() < long;
  }

  static double scaleOfmatters(
    final double zoom, {
    double claim = 1,
    double? reference,
  }) {
    double newZoom;
    final double baseRadiusAtReferenceZoom = reference ?? 100000.0;
    const double referenceZoom = 5.0;
    newZoom = baseRadiusAtReferenceZoom / pow(2, zoom - referenceZoom);
    newZoom = newZoom.clamp(claim, 200000.0);
    BaseLogger.log(newZoom);
    return newZoom;
  }

  static double zoomLeaveCircle(final double zoom, [double? reference]) {
    double newRadius;
    final double baseRadiusAtReferenceZoom = reference ?? 100000.0;
    const double referenceZoom = 3.11;
    newRadius = baseRadiusAtReferenceZoom / pow(2, zoom - referenceZoom);
    newRadius = newRadius.clamp(0.5, 200000.0);

    return newRadius;
  }
}
