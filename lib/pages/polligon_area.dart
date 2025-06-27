import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:learn_map/controller/polygon_controller.dart';

class MapPollygonAreaPage extends StatefulWidget {
  const MapPollygonAreaPage({super.key});

  @override
  State<MapPollygonAreaPage> createState() => _MapPollygonAreaPageState();
}

class _MapPollygonAreaPageState extends State<MapPollygonAreaPage> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<MapGetController>(
        init: MapGetController(context),
        builder: (controller) {
          return Scaffold(
            body: GoogleMap(
              initialCameraPosition: MapGetController.cameraPosition,
              mapType: MapType.normal,
              markers: Set.of({
                Marker(
                  markerId: const MarkerId('name'),
                  position: MapGetController.cameraPosition.target,
                ),
              }),
              polygons: Set.of(controller.polygons),
            ),
          );
        });
  }
}
