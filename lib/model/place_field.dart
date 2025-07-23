class PlaceFieldModel {
  int _id = -0;
  String _displayName = "";
  String _country = "";
  double _lat = 0.0, _long = 0.0;

  int get id => _id;

  String get displayName => _displayName;

  String get country => _country;
  double get lat => _lat;

  double get long => _long;

  PlaceFieldModel();

  factory PlaceFieldModel.fromJson(Map<String, dynamic> json) => PlaceFieldModel()
    .._id = json['id']
    .._displayName = json['display_name']
    .._country = "county"
    .._lat = json['lat']
    .._long = json['lon'];
}
