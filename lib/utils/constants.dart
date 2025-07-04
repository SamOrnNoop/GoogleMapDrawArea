import 'package:flutter/material.dart';

class Constants {
  static const String apiKey = 'AIzaSyBHGOmtcSeVpiLXBHL1SYBqQxT9iReNJ_c';

  static const Color primaryColor = Color.fromARGB(255, 95, 117, 115);
}

extension CheckBoo on bool {
  bool toggle() {
    if (this == false) return true;
    return false;
  }
}
