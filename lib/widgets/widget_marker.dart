import 'package:flutter/material.dart';

class WidgetMarker {
  static Widget icon({final Color? borderColor, final Color? fillColor, double size = 15.0}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: fillColor ?? Colors.grey,
        border: Border.all(color: borderColor ?? Colors.blue),
        shape: BoxShape.circle,
      ),
    );
  }
}
