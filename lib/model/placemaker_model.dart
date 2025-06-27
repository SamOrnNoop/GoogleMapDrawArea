import 'package:google_maps_flutter/google_maps_flutter.dart';

class PlacemakerModel {
  String? _name;
  PlacemakerData? _placemakerData;
  List<PositionLocation> _polygonDataMode = [];

  final List<LatLng> _latLong = [];

  List<LatLng> get latLong => _latLong;

  String get name => _name ?? "";
  set setname(String value) => _name = value;
  PlacemakerData? get data => _placemakerData;
  set setPlacemaker(PlacemakerData value) => _placemakerData = value;

  List<PositionLocation>? get coordinates => _polygonDataMode;

  void addCoordinates(PositionLocation values) => _polygonDataMode.add(values);

  void appendLatlong(LatLng value) => _latLong.add(value);

  factory PlacemakerModel.fromData(final Map<String, dynamic> xmlData) {
    PlacemakerModel model = PlacemakerModel();
    model._name = xmlData['name'];
    model._placemakerData = PlacemakerData.fromData(xmlData['maker_data']);
    model._polygonDataMode = (xmlData['coordinates'] as List?)?.map((e) => PositionLocation.fromDate(e)).toList() ?? [];
    return model;
  }

  PlacemakerModel();
}

class PlacemakerData {
  String? _name;
  String? _code;
  String? _proving;
  String? _unicoName;
  String? _type;

  String? get name => _name;
  String? get code => _code;
  String? get proving => _proving;
  String? get unicoName => _unicoName;
  String? get type => _type;

  factory PlacemakerData.fromData(Map<String, dynamic> xmll) {
    PlacemakerData model = PlacemakerData();
    model._name = xmll['name'];
    model._code = xmll['code'];
    model._proving = xmll['proving'];
    model._unicoName = xmll['unicoName'];
    model._type = xmll['type'];
    return model;
  }
  PlacemakerData();
}

class PositionLocation {
  double? _latitude;
  double? _longitude;

  set setLat(double value) => _latitude = value;
  set setLong(double value) => _longitude = value;

  double? get latitude => _latitude;
  double? get longitude => _longitude;

  factory PositionLocation.fromDate(Map<String, dynamic> xmll) {
    PositionLocation model = PositionLocation();
    model.setLat = xmll['lat'];
    model.setLong = xmll['long'];
    return model;
  }
  PositionLocation();

  @override
  String toString() {
    return "LatLong $latitude,$longitude";
  }
}
