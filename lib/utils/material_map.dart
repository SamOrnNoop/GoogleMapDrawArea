import 'package:google_maps_flutter/google_maps_flutter.dart';

class MaterialGoogleMap {
  static CameraPosition cameraPosition =
      CameraPosition(target: const LatLng(11.58330103577817, 104.88023529639402), zoom: minMaxZoomPreference.minZoom!);

  static const MinMaxZoomPreference minMaxZoomPreference = MinMaxZoomPreference(15, 30);
}
