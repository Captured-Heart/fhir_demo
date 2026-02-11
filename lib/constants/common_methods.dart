import 'package:fhir_demo/constants/typedefs.dart';

class CommonMethods {
  static MapStringDynamic buildJsonPreview(MapStringDynamic mapStringDynamic) {
    try {
      return mapStringDynamic;
    } catch (e) {
      return {'value': 'No Data'};
    }
  }
}
