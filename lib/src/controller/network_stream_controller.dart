import 'package:fhir_demo/src/domain/repository/network/connectivity_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

final networkStreamProvider = StreamProvider<InternetStatus>((ref) async* {
  yield* ref.watch(connectivityRepositoryProvider).internetStatus();
});
