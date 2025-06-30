import 'package:flutter/material.dart';
import 'package:learn_map/app.dart';
import 'package:learn_map/utils/material_map.dart';

void main() {
  MaterialGoogleMap.initIconMarker();
  runApp(const AppInitBuilder());
}
