import 'package:fhir_demo/constants/extension.dart';
import 'package:fhir_demo/src/domain/entities/patient_server_id_entity.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fhir_demo/constants/typedefs.dart';
import 'package:fhir_demo/hive_helper/hive_adapters.dart';
import 'package:fhir_demo/hive_helper/register_adapters.dart';
import 'package:fhir_demo/src/domain/entities/user_entity.dart';
import 'package:fhir_demo/src/domain/repository/local_repository.dart';

enum HiveKeys { mood, user, sessionUser, threshHold, theme, patientsId }

class CacheHelper {
  static late final LocalStorage<UserEntity> _userLocalModel;
  static late final LocalStorage<UserEntity> _sessionUserLocalModel;
  static late final LocalStorage<num> _threshHoldLocalModel;
  static late final LocalStorage<String> _themeLocalModel;
  static late final LocalStorage<PatientsServerIdEntity> _patientServerIdLocalModel;

  static FutureVoid openHiveBoxes() async {
    await Hive.initFlutter();
    //i register adapters here
    registerAdapters();
    // i open the boxes (userEntity and moodEntity)
    _userLocalModel = LocalRepository<UserEntity>(await Hive.openBox(HiveAdapters.userEntity));

    _sessionUserLocalModel = LocalRepository<UserEntity>(await Hive.openBox(HiveAdapters.sessionUser));
    _threshHoldLocalModel = LocalRepository<num>(await Hive.openBox(HiveAdapters.threshHold));
    _themeLocalModel = LocalRepository<String>(await Hive.openBox(HiveAdapters.theme));
    _patientServerIdLocalModel = LocalRepository<PatientsServerIdEntity>(
      await Hive.openBox(HiveAdapters.patientServerIdEntity),
    );
  }

  // Getters for the local models
  static LocalStorage<UserEntity> get userLocalModel => _userLocalModel;
  static LocalStorage<UserEntity> get sessionUserLocalModel => _sessionUserLocalModel;
  static LocalStorage<num> get threshHoldLocalModel => _threshHoldLocalModel;
  static LocalStorage<String> get themeLocalModel => _themeLocalModel;
  static LocalStorage<PatientsServerIdEntity> get patientServerIdLocalModel => _patientServerIdLocalModel;

  static UserEntity? get currentUser => _sessionUserLocalModel.read(HiveKeys.sessionUser.name);

  static Future<void> setClaimedThreshold(num threshHold) async {
    await _threshHoldLocalModel.write(HiveKeys.threshHold.name, threshHold);
  }

  // delete some num from threshold
  static Future<void> deleteSomeThreshold(num threshHold) async {
    var oldThreshold = getClaimedThreshold();
    if (oldThreshold < threshHold) return;
    oldThreshold -= threshHold;
    await _threshHoldLocalModel.write(HiveKeys.threshHold.name, oldThreshold);
  }

  static num getClaimedThreshold() {
    return _threshHoldLocalModel.read(HiveKeys.threshHold.name) ?? 0;
  }

  // set theme and get theme
  static Future<void> setTheme(String theme) async {
    await _themeLocalModel.write(HiveKeys.theme.name, theme);
  }

  static String? getTheme() {
    return _themeLocalModel.read(HiveKeys.theme.name);
  }

  // save patient server id
  static Future<void> savePatientServerId(PatientsServerIdEntity patientServerIdEntity) async {
    await _patientServerIdLocalModel.write(patientServerIdEntity.id, patientServerIdEntity);
  }

  // get patient server id lists
  static List<PatientsServerIdEntity>? getPatientServerId() {
    return _patientServerIdLocalModel.list;
  }

  // get according to server type
  static List<PatientsServerIdEntity>? getPatientServerIdByServerType(String serverType) {
    'what is the server type $serverType'.logError();
    final allPatients = getPatientServerId();
    'patient length ${allPatients?.length}'.logError();
    if (allPatients == null) return [];
    try {
      return allPatients.where((patient) {
        // 'what is the patient server type ${patient.serverType}'.logError();
        return patient.serverType.toLowerCase() == serverType.toLowerCase();
      }).toList();
    } catch (e) {
      return [];
    }
  }
}
