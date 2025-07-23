import 'package:dio/dio.dart';
import 'package:learn_map/model/place_field.dart';

class HttpsServices {
  final String url = "https://search.osmnames.org/q/";
  final String key = ".js?key=iuzaFSBbfgFUp5zcijcSu";
  Future<List<PlaceFieldModel>> khmerStateOfMap([String? search]) async {
    final String query = (search ?? "Cambodia").replaceAll(" ", "%20");
    try {
      final Response response = await Dio().get('$url$query$key');
      final List<dynamic> datas = List.from(response.data['results']);
      return datas.map((element) => PlaceFieldModel.fromJson(element)).toList();
    } catch (e) {
      return [];
    }
  }
}
