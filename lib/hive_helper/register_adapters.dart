import 'package:hive/hive.dart';
import 'package:fhir_demo/src/domain/entities/user_entity.dart';

void registerAdapters() {
  Hive.registerAdapter(UserEntityAdapter());
}
