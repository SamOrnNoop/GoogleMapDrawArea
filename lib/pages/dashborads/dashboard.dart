import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_widget/google_maps_widget.dart';
import 'package:learn_map/controller/poly_smater.dart';
import 'package:learn_map/pages/draw_point/draw_with_point_map_page.dart';
import 'package:learn_map/utils/base_print.dart';
import 'package:learn_map/utils/constants.dart';

import '../draw_and_drag_custom/map_view_page.dart';

class DashboardPageView extends StatelessWidget {
  const DashboardPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Stack(
        children: [
          Positioned.fill(
              child: Container(
            decoration: BoxDecoration(
                color: Colors.yellow,
                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomLeft, colors: [
                  Colors.grey.shade50,
                  Colors.teal.shade100,
                  Colors.teal.shade200,
                  Colors.teal.shade100,
                  Colors.white70,
                ])),
          )),
          const Positioned.fill(
            child: BackdropFilter(
              filter: ColorFilter.mode(Colors.grey, BlendMode.lighten),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ListView(
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _appBarBuilder(),
                Padding(
                  padding: const EdgeInsets.only(top: 25, bottom: 5),
                  child: _title("Menu"),
                ),
                _builderMenu(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: _title("Recently"),
                ),
                ListView.separated(
                    physics: const ClampingScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return const ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          child: Text("B"),
                        ),
                        title: Text(
                          'Chan Dara Flower',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          'The easiest way to measure the acreage of a plot of land is to start by entering an address that is associated with the plot of land you need the area of.',
                          maxLines: 2,
                        ),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return const Divider();
                    },
                    itemCount: 5)
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardItem {
  final String? title;
  final String? value;

  const DashboardItem({this.title, this.value});

  static int get itemLength => items.length;
  static List<DashboardItem> get items {
    return const [
      DashboardItem(title: "Draw with point", value: 'draw'),
      DashboardItem(title: "Walk Drawing", value: 'walk'),
      DashboardItem(title: "Drag Custom", value: 'drag-and-draw'),
      DashboardItem(title: "History", value: 'history'),
    ];
  }
}

Widget _appBarBuilder() {
  return const Padding(
    padding: EdgeInsets.only(top: kToolbarHeight),
    child: Card(
      margin: EdgeInsets.zero,
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: Center(
            child: Text(
          'GoogleMap Drawing',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Constants.primaryColor),
        )),
      ),
    ),
  );
  // return AppBar(title: const Text("GoogleMap Draw"), centerTitle: true);
}

Widget _title(String title) {
  return Text(
    title,
    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
  );
}

Widget _builderMenu() {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: GridView.builder(
        itemCount: DashboardItem.itemLength,
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 1.5),
        itemBuilder: (context, index) {
          DashboardItem item = DashboardItem.items[index];
          return _itemBuilderWidget(context, item, () {
            switch (item.value) {
              case 'draw':
                Get.to(const DrawWitPointMapPage());

                break;
              case 'drag-and-draw':
                Get.to(const DrawAndDragCustomEventPage());
              default:
                Get.to(MapScreen());
            }
            BaseLogger.log(item.value);
            // print(item.value);
          });
        }),
  );
}

Widget _itemBuilderWidget(BuildContext context, DashboardItem item, void Function() callback) {
  return ElevatedButton(
    onPressed: callback,
    style: ElevatedButton.styleFrom(
        foregroundColor: Constants.primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        )),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.map, size: 40),
        const SizedBox(height: 5),
        Text(
          item.title ?? '',
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    ),
  );
}

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  Set<Polygon> _polygons = {};

  final LatLng _center = const LatLng(11.5841, 104.8790); // Example center for Cambodia

  // Your list of LatLng points
  List<LatLng> myPoints = [
    LatLng(11.58416984202727, 104.87888978709076),
    LatLng(11.584184366165987, 104.8788860980891),
    LatLng(11.584180728953674, 104.87916398347218),
    LatLng(11.584206018513024, 104.87942210767532),
    LatLng(11.58403567708512, 104.87944692432723),
    LatLng(11.583880204254895, 104.87947883633417),
    LatLng(11.583850438664898, 104.87931569581949),
    LatLng(11.583842936778789, 104.87907553254225),
    LatLng(11.58383562404187, 104.87889391947893),
    LatLng(11.584010095642167, 104.8788675986238),
    LatLng(11.584202530177011, 104.87905665802975),
  ];

  @override
  void initState() {
    super.initState();
    // This is where you would typically load your map data
    // _addPointsToMap will be called once the map is created.
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    init();
    // _addPointsToMap();
  }

  void init() {
    _polylines.clear();

    List<LatLng> latlongs = PolylineAnalyzer().selectOnlyCornerAndCurve(myPoints);
    _polylines.add(Polyline(polylineId: const PolylineId('map'), points: latlongs));
    for (var position in latlongs) {
      _markers.add(Marker(markerId: MarkerId('{"amp_${position.hashCode}"}'), position: position));
    }

    setState(() {});
  }

  void _addPointsToMap() {
    _markers.clear();
    _polylines.clear();
    _polygons.clear();

    // 1. Add markers for all original points
    for (int i = 0; i < myPoints.length; i++) {
      _markers.add(
        Marker(
          markerId: MarkerId('original_point_$i'),
          position: myPoints[i],
          infoWindow: InfoWindow(title: 'Original Point ${i + 1}'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ),
      );
    }

    // 2. Draw the polyline connecting all original points
    _polylines.add(
      Polyline(
        polylineId: PolylineId('original_polyline'),
        points: myPoints,
        color: Colors.blue,
        width: 3,
      ),
    );

    // 3. Calculate the Convex Hull
    List<LatLng> convexHullPoints = _findConvexHull(myPoints);

    // 4. Draw the Convex Hull as a Polygon (outer "corners" connected)
    if (convexHullPoints.length >= 3) {
      // A polygon needs at least 3 points
      _polygons.add(
        Polygon(
          polygonId: PolygonId('convex_hull'),
          points: convexHullPoints,
          strokeColor: Colors.red,
          strokeWidth: 2,
          fillColor: Colors.red.withOpacity(0.2),
        ),
      );

      // 5. Highlight Convex Hull Points (outer "corner" points) with different markers
      for (int i = 0; i < convexHullPoints.length; i++) {
        _markers.add(
          Marker(
            markerId: MarkerId('hull_corner_$i'),
            position: convexHullPoints[i],
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen), // Green for convex corners
            infoWindow: InfoWindow(title: 'Convex Corner ${i + 1}'),
          ),
        );
      }

      // 6. Identify and highlight points inside the hull (the ones "in the curve" but not on the outer boundary)
      List<LatLng> pointsInsideHull = [];
      for (LatLng p in myPoints) {
        // Simple check: if a point is not exactly one of the hull points
        // For floating point comparisons, a small epsilon (tolerance) is safer.
        bool isOnHull = convexHullPoints.any(
            (hp) => (hp.latitude - p.latitude).abs() < 0.00000001 && (hp.longitude - p.longitude).abs() < 0.00000001);
        if (!isOnHull) {
          pointsInsideHull.add(p);
        }
      }

      for (int i = 0; i < pointsInsideHull.length; i++) {
        _markers.add(
          Marker(
            markerId: MarkerId('inside_curve_$i'),
            position: pointsInsideHull[i],
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange), // Orange for internal points
            infoWindow: InfoWindow(title: 'Internal Point ${i + 1}'),
          ),
        );
      }
    } else {
      print("Not enough points to form a convex hull polygon (needs at least 3).");
    }

    setState(() {}); // Update the map with new markers, polylines, and polygons
  }

  /// Calculates the cross product of vectors (p1-p0) and (p2-p0).
  /// Returns a value that indicates the orientation of the triplet (p0, p1, p2):
  /// > 0 if p2 is to the left of p0->p1 (counter-clockwise turn)
  /// < 0 if p2 is to the right of p0->p1 (clockwise turn)
  /// = 0 if p2 is collinear with p0->p1
  double _crossProduct(LatLng p0, LatLng p1, LatLng p2) {
    return (p1.longitude - p0.longitude) * (p2.latitude - p0.latitude) -
        (p1.latitude - p0.latitude) * (p2.longitude - p0.longitude);
  }

  /// Finds the convex hull of a set of 2D points using Andrew's Monotone Chain algorithm.
  /// Points are assumed to be LatLng, where longitude is x and latitude is y.
  List<LatLng> _findConvexHull(List<LatLng> points) {
    if (points.length <= 2) {
      return List.from(points); // Hull is the points themselves if 2 or fewer
    }

    // Sort points lexicographically (by x then by y)
    points.sort((a, b) {
      int cmp = a.longitude.compareTo(b.longitude);
      if (cmp == 0) {
        return a.latitude.compareTo(b.latitude);
      }
      return cmp;
    });

    List<LatLng> upper = [];
    List<LatLng> lower = [];

    // Build upper hull
    for (LatLng p in points) {
      while (upper.length >= 2 && _crossProduct(upper[upper.length - 2], upper.last, p) <= 0) {
        upper.removeLast();
      }
      upper.add(p);
    }

    // Build lower hull
    for (int i = points.length - 1; i >= 0; i--) {
      LatLng p = points[i];
      while (lower.length >= 2 && _crossProduct(lower[lower.length - 2], lower.last, p) <= 0) {
        lower.removeLast();
      }
      lower.add(p);
    }

    // Combine upper and lower hulls, removing duplicate start/end points
    lower.removeLast(); // Remove last point (duplicate of upper's first)
    upper.removeLast(); // Remove last point (duplicate of lower's first)

    return upper + lower;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Google Maps - Polyline & Corners')),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 16.0,
        ),
        markers: _markers,
        polylines: _polylines,
        polygons: _polygons,
      ),
    );
  }
}
