import 'package:hive/hive.dart';
import 'package:fhir_demo/src/domain/entities/user_entity.dart';
import 'package:fhir_demo/src/domain/entities/patient_server_id_entity.dart';

void registerAdapters() {
  Hive.registerAdapter(UserEntityAdapter());
	Hive.registerAdapter(PatientsServerIdEntityAdapter());
}
