import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:learn_map/model/placemaker_model.dart';
import 'package:xml/xml.dart';

class MapGetController extends GetxController {
  final BuildContext buildContext;
  MapGetController(this.buildContext);

  static MapGetController get fine => Get.find<MapGetController>();

  static CameraPosition cameraPosition =
      const CameraPosition(target: LatLng(11.812122438098198, 104.8045777156949), zoom: 8.0);
  List<PlacemakerModel> collectLocationDatas = [];
  @override
  void onInit() {
    getLocationData();
    super.onInit();
  }

  Iterable<Polygon> get polygons => Iterable<Polygon>.generate(collectLocationDatas.length, (index) {
        PlacemakerModel place = collectLocationDatas[index];

        return Polygon(
          consumeTapEvents: true,
          polygonId: PolygonId(place.data?.code ?? ""),
          points: place.latLong,
          strokeColor: Colors.primaries[index % 6],
          fillColor: Colors.primaries[index % 4],
          strokeWidth: 2,
          onTap: () => onOnSheetDetailPolygons(place),
        );
      });

  Future<void> getLocationData() async {
    String? downloadXml = await rootBundle.loadString('assets/PA_08August2023_73PA_ph.kml');
    XmlDocument document = XmlDocument.parse(downloadXml);
    final List<XmlElement> placemarks = document.findAllElements('Placemark').toList();

    for (XmlElement element in placemarks) {
      PlacemakerModel makersPlace = PlacemakerModel();
      makersPlace.setname = element.getElement('name')?.innerText ?? "";
      List<XmlElement> informations = element.findElements('ExtendedData').toList();
      List<XmlElement> polygons = element.findElements('Polygon').toList();
      for (XmlElement info in informations) {
        List<XmlElement> datas = info.findAllElements('SimpleData').toList();
        Map<String, String> toMap = {};
        for (XmlElement data in datas) {
          switch (data.getAttribute('name')) {
            case 'Name_Eng':
              toMap['name'] = data.innerText.trim();
              break;
            case 'CODE':
              toMap['code'] = data.innerText.trim();
              break;
            case 'Province_K':
              toMap['proving'] = data.innerText.trim();
              break;
            case 'Nam_Unico':
              toMap['unicoName'] = data.innerText.trim();
              break;
          }
        }
        makersPlace.setPlacemaker = PlacemakerData.fromData(toMap);
      }

      for (XmlElement poly in polygons) {
        XmlElement? coordinates =
            poly.getElement('outerBoundaryIs')?.getElement('LinearRing')?.getElement('coordinates');
        if (coordinates != null) {
          String? getCoordinates = coordinates.innerText.trim();
          List<String> latLong = getCoordinates.split(',0');
          for (String element in latLong) {
            if (element.isNotEmpty) {
              List<String> position = element.split(',');
              if (position.isNotEmpty) {
                final double? long = double.tryParse(position[0]);
                final double? lat = double.tryParse(position[1]);
                if (lat != null && long != null) makersPlace.appendLatlong(LatLng(lat, long));
              }
            }

            // makersPlace.addCoordinates(
            //   // PolygonDataMode.fromDate({'lat': double.parse(position[0]), 'long': num.parse(position[1])}),
            // );
          }
        }
      }
      // log(collectLocationDatas.first.latlong.toString());
      await Future.delayed(const Duration(milliseconds: 50));
      collectLocationDatas.add(makersPlace);
      update();
    }
  }

  void onOnSheetDetailPolygons(PlacemakerModel detail) {
    showModalBottomSheet(
        context: buildContext,
        builder: (_) {
          return Material(
            child: Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Container(
                      padding: const EdgeInsets.only(left: 25.0),
                      alignment: Alignment.centerLeft,
                      width: double.infinity,
                      height: 50,
                      color: Colors.grey.shade100,
                      child: Text(detail.data?.code ?? ""),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Container(
                      padding: const EdgeInsets.only(left: 25.0),
                      alignment: Alignment.centerLeft,
                      width: double.infinity,
                      height: 50,
                      color: Colors.grey.shade100,
                      child: Text(detail.name),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Container(
                      padding: const EdgeInsets.only(left: 25.0),
                      alignment: Alignment.centerLeft,
                      height: 50,
                      width: double.infinity,
                      color: Colors.grey.shade100,
                      child: Text(detail.data?.unicoName ?? ""),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }
}
