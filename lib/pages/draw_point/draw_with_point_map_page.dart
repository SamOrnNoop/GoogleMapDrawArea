import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:learn_map/pages/draw_point/controller.dart';
import 'package:learn_map/utils/material_map.dart';

import '../../utils/defualt_scaffold.dart';

class DrawWitPointMapPage extends StatelessWidget {
  const DrawWitPointMapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: GetxDrawWithPointController(),
        builder: (cxt) {
          return DefaultScaffold(
            body: GoogleMap(
              initialCameraPosition: MaterialGoogleMap.cameraPosition,
              minMaxZoomPreference: MaterialGoogleMap.minMaxZoomPreference,
              onTap: cxt.onGeLocation,
            ),
          );
        });
  }
}
