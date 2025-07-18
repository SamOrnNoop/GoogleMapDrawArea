import 'package:flutter/material.dart';
import 'package:google_maps_widget/google_maps_widget.dart';

class FieldModel {
  String _firstName = "";
  String _lastName = "";
  String _gender = "";
  int? _age;
  String? _code;
  String? _colorCode;
  String? _type;
  List<LatLng> _points = [];

  FieldModel({final FieldModel? from}) {
    if (from != null) FieldModel.constructor(from);
  }

  String get firstName => _firstName;
  set setFirstName(String value) => _firstName = value;

  String get lastName => _lastName;
  set setLastName(String value) => _lastName = value;

  String get gender => _gender;
  set setGender(String value) => _gender = value;

  String? get type => _type;
  set setType(String? value) => _type = value;

  int? get age => _age;
  set setAge(int? value) => _age = value;

  String? get code => _code;
  set setCode(String? value) => _code = value;

  List<LatLng> get points => _points;
  set setPoints(List<LatLng> values) => _points = values;

  void addPoint(LatLng value) => _points.add(value);
  void insertPoint(int index, LatLng value) => _points.insert(index, value);
  Color? get colorCode => _colorCode != null ? Color(int.parse("0xFF$_colorCode")) : null;

  set setColorCode(Object? value) {
    if (value == null) _colorCode = null;
    if (value is String) _colorCode = value;
    if (value is Color) _colorCode = value.value.toRadixString(16);
  }

  FieldModel.constructor(FieldModel from) {
    setAge = from.age ?? 0;
    setCode = from.code;
    setColorCode = from.colorCode;
    setFirstName = from.firstName;
    setLastName = from.lastName;
    setGender = from.gender;
    setPoints = from.points;
    setType = from.type;
  }
  factory FieldModel.fromJson(Map<String, dynamic> json) {
    return FieldModel()
      ..setFirstName = json['firstName']
      ..setLastName = json['lastName']
      ..setAge = json['age']
      ..setGender = json['gender']
      ..setType = json['type']
      ..setCode = json['code']
      ..setColorCode = json['colorCode']
      ..setPoints = json['points'];
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "firstName": firstName,
      "lastName": lastName,
      "age": age,
      "gender": gender,
      "code": code,
      "type": type,
      "colorCode": colorCode,
      "points": points,
    };
  }
}
