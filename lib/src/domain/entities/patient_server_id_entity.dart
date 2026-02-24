import 'package:hive/hive.dart';
import 'package:fhir_demo/hive_helper/hive_types.dart';
import 'package:fhir_demo/hive_helper/hive_adapters.dart';
import 'package:fhir_demo/hive_helper/fields/patients_server_id_entity_fields.dart';

part 'patient_server_id_entity.g.dart';

@HiveType(typeId: HiveTypes.patientsServerIdEntity, adapterName: HiveAdapters.patientsServerIdEntity)
class PatientsServerIdEntity extends HiveObject {
  @HiveField(PatientsServerIdEntityFields.serverType)
  final String serverType;
  @HiveField(PatientsServerIdEntityFields.patientId)
  final String patientId;
  @HiveField(PatientsServerIdEntityFields.patientName)
  final String patientName;
  @HiveField(PatientsServerIdEntityFields.id)
  final String id;

  PatientsServerIdEntity({
    required this.serverType,
    required this.patientId,
    required this.patientName,
    required this.id,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'serverType': serverType, 'patientId': patientId, 'patientName': patientName, 'id': id};
  }

  factory PatientsServerIdEntity.fromMap(Map<String, dynamic> map) {
    return PatientsServerIdEntity(
      serverType: map['serverType'] as String,
      patientId: map['patientId'] as String,
      patientName: map['patientName'] as String,
      id: map['id'] as String,
    );
  }

  // String toJson() => json.encode(toMap());

  // factory PatientsServerIdEntity.fromJson(String source) =>
  //     PatientsServerIdEntity.fromMap(json.decode(source) as Map<String, dynamic>);
}

extension PatientsServerIdEntityX on PatientsServerIdEntity {
  String getIdAndName() => '$patientName - ($patientId)';
}
