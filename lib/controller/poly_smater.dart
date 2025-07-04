import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:learn_map/utils/base_print.dart';

class ExPolyEditor {
  final List<LatLng> points;
  // final Widget pointIcon;
  // final Size pointIconSize;
  final bool intermediateIcon;
  // final Size intermediateIconSize;
  // final void Function(LatLng? updatePoint)? callbackRefresh;
  final bool addClosePathMarker;

  const ExPolyEditor({
    required this.points,
    // required this.pointIcon,
    this.intermediateIcon = false,
    // this.callbackRefresh,
    this.addClosePathMarker = false,
    // this.pointIconSize = const Size(30, 30),
    // this.intermediateIconSize = const Size(30, 30),
  });

  // int? _markerToUpdate;

  // void updateMarker(details, point) {
  //   if (_markerToUpdate != null) {
  //     points[_markerToUpdate!] = LatLng(point.latitude, point.longitude);
  //   }
  //   callbackRefresh?.call(LatLng(point.latitude, point.longitude));
  // }

  // List add(List<LatLng> pointsList, LatLng point) {
  //   pointsList.add(point);
  //   callbackRefresh?.call(point);
  //   return pointsList;
  // }

  // LatLng remove(int index) {
  //   final point = points.removeAt(index);
  //   callbackRefresh?.call(point);
  //   return point;
  // }

  List<LatLng> edit() {
    List<LatLng> dragMarkers = [];

    // for (var c = 0; c < points.length; c++) {
    //   // final indexClosure = c;
    //   dragMarkers.add(points[c]);
    // }

    for (var c = 0; c < points.length - 1; c++) {
      final polyPoint = points[c];
      final polyPoint2 = points[c + 1];

      if (intermediateIcon) {
        // final indexClosure = c;
        final intermediatePoint = LatLng(polyPoint.latitude + (polyPoint2.latitude - polyPoint.latitude) / 2,
            polyPoint.longitude + (polyPoint2.longitude - polyPoint.longitude) / 2);
        BaseLogger.log('Adive Message: $intermediatePoint ');
        dragMarkers.add(intermediatePoint);
      }
    }

    /// Final close marker from end back to beginning we want if its a closed polygon.
    if (addClosePathMarker && (points.length > 2)) {
      if (intermediateIcon) {
        final finalPointIndex = points.length - 1;

        final intermediatePoint = LatLng(
            points[finalPointIndex].latitude + (points[0].latitude - points[finalPointIndex].latitude) / 2,
            points[finalPointIndex].longitude + (points[0].longitude - points[finalPointIndex].longitude) / 2);

        // final indexClosure = points.length - 1;
        BaseLogger.log(' Final: $intermediatePoint ');
        dragMarkers.add(intermediatePoint);
      }
    }

    return !intermediateIcon ? points : dragMarkers;
  }
}

class PolylineAnalyzer {
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
  List<LatLng> _findeCornerAndCurveHull(List<LatLng> points) {
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

    // // Build lower hull
    for (int i = points.length - 1; i >= 0; i--) {
      LatLng p = points[i];
      while (lower.length >= 2 && _crossProduct(lower[lower.length - 2], lower.last, p) <= 0) {
        lower.removeLast();
      }

      lower.add(p);
    }

    // Combine upper and lower hulls, removing duplicate start/end points
    // Remove the last point from 'lower' if it's the same as 'upper's first point
    // This handles cases where the first point of the sorted list is also the last point of the lower hull
    if (lower.isNotEmpty && upper.isNotEmpty && lower.last == points.first) {
      lower.removeLast();
    }
    // Remove the last point from 'upper' if it's the same as 'lower's first point
    // This handles cases where the last point of the sorted list is also the first point of the lower hull
    if (upper.isNotEmpty && lower.isNotEmpty && upper.last == points.last) {
      // Check against points.last which should be the highest x point
      upper.removeLast();
    }

    // A more robust way to remove duplicates at the join
    // If the last point of upper is the same as the first point of lower, remove it from lower
    if (upper.isNotEmpty && lower.isNotEmpty && upper.last == lower.first) {
      lower.removeAt(0);
    }

    return upper + lower;
  }

  List<LatLng> selectOnlyCornerAndCurve(List<LatLng> latlngs) => _findeCornerAndCurveHull(latlngs);
}
