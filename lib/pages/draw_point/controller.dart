import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:learn_map/utils/base_print.dart';

class GetxDrawWithPointController extends GetxController {
  void onGeLocation(LatLng latlong) {
    BaseLogger.log(latlong);
  }
}
