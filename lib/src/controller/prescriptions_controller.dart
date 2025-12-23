// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final prescriptionsController = NotifierProvider.autoDispose<PrescriptionsNotifier, PrescriptionsNotifierState>(
  PrescriptionsNotifier.new,
);

class PrescriptionsNotifier extends AutoDisposeNotifier<PrescriptionsNotifierState> {
  late GlobalKey<FormState> _formKey;
  late TextEditingController _patientIdController;
  late TextEditingController _medicationController;
  late TextEditingController _dosageController;
  late TextEditingController _frequencyController;
  late TextEditingController _durationController;
  late TextEditingController _instructionsController;
  late TextEditingController _prescribingDoctorController;
  late TextEditingController _startDateController;

  @override
  build() {
    _formKey = GlobalKey<FormState>();
    _patientIdController = TextEditingController();
    _medicationController = TextEditingController();
    _dosageController = TextEditingController();
    _frequencyController = TextEditingController();
    _durationController = TextEditingController();
    _instructionsController = TextEditingController();
    _prescribingDoctorController = TextEditingController();
    _startDateController = TextEditingController();

    return PrescriptionsNotifierState();
  }

  void clearForm() {
    _formKey.currentState?.reset();
    _patientIdController.clear();
    _medicationController.clear();
    _dosageController.clear();
    _frequencyController.clear();
    _durationController.clear();
    _instructionsController.clear();
    _prescribingDoctorController.clear();
    _startDateController.clear();
    state = state.copyWith(selectedRoute: null);
  }

  void setSelectedRoute(String? route) {
    state = state.copyWith(selectedRoute: route);
  }

  // -------- GETTERS --------
  GlobalKey<FormState> get formKey => _formKey;
  TextEditingController get patientIdController => _patientIdController;
  TextEditingController get medicationController => _medicationController;
  TextEditingController get dosageController => _dosageController;
  TextEditingController get frequencyController => _frequencyController;
  TextEditingController get durationController => _durationController;
  TextEditingController get instructionsController => _instructionsController;
  TextEditingController get prescribingDoctorController => _prescribingDoctorController;
  TextEditingController get startDateController => _startDateController;
}

class PrescriptionsNotifierState {
  final String? selectedRoute;
  final bool isLoading;

  PrescriptionsNotifierState({this.selectedRoute, this.isLoading = false});

  PrescriptionsNotifierState copyWith({String? selectedRoute, bool? isLoading}) {
    return PrescriptionsNotifierState(
      selectedRoute: selectedRoute ?? this.selectedRoute,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
