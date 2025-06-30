import 'package:flutter/material.dart';
import 'package:google_maps_widget/google_maps_widget.dart';
import 'package:learn_map/utils/defualt_scaffold.dart';

class PreviewMapPage extends StatelessWidget {
  final double zoom;

  final Set<Polyline> polylin;
  const PreviewMapPage({super.key, required this.polylin, this.zoom = 15});

  @override
  Widget build(BuildContext context) {
    final LatLng target = polylin.first.points.first;
    return DefaultScaffold(
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: target, zoom: zoom),
        polygons: Set.of({
          Polygon(
            polygonId: PolygonId(polylin.first.polylineId.value),
            fillColor: Colors.red.shade50,
            strokeWidth: 2,
            strokeColor: Colors.blue,
            points: polylin.first.points,
          )
        }),
        // polylines: polylin,
      ),
    );
  }
}
