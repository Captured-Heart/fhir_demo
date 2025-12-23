// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appointmentsController = NotifierProvider.autoDispose<AppointmentsNotifier, AppointmentsNotifierState>(
  AppointmentsNotifier.new,
);

class AppointmentsNotifier extends AutoDisposeNotifier<AppointmentsNotifierState> {
  late GlobalKey<FormState> _formKey;
  late TextEditingController _patientIdController;
  late TextEditingController _doctorController;
  late TextEditingController _appointmentDateController;
  late TextEditingController _appointmentTimeController;
  late TextEditingController _reasonController;
  late TextEditingController _locationController;
  late TextEditingController _notesController;

  @override
  build() {
    _formKey = GlobalKey<FormState>();
    _patientIdController = TextEditingController();
    _doctorController = TextEditingController();
    _appointmentDateController = TextEditingController();
    _appointmentTimeController = TextEditingController();
    _reasonController = TextEditingController();
    _locationController = TextEditingController();
    _notesController = TextEditingController();

    return AppointmentsNotifierState();
  }

  void clearForm() {
    _formKey.currentState?.reset();
    _patientIdController.clear();
    _doctorController.clear();
    _appointmentDateController.clear();
    _appointmentTimeController.clear();
    _reasonController.clear();
    _locationController.clear();
    _notesController.clear();
    state = state.copyWith(selectedType: null, selectedStatus: null);
  }

  void setSelectedType(String? type) {
    state = state.copyWith(selectedType: type);
  }

  void setSelectedStatus(String? status) {
    state = state.copyWith(selectedStatus: status);
  }

  // -------- GETTERS --------
  GlobalKey<FormState> get formKey => _formKey;
  TextEditingController get patientIdController => _patientIdController;
  TextEditingController get doctorController => _doctorController;
  TextEditingController get appointmentDateController => _appointmentDateController;
  TextEditingController get appointmentTimeController => _appointmentTimeController;
  TextEditingController get reasonController => _reasonController;
  TextEditingController get locationController => _locationController;
  TextEditingController get notesController => _notesController;
}

class AppointmentsNotifierState {
  final String? selectedType;
  final String? selectedStatus;
  final bool isLoading;

  AppointmentsNotifierState({this.selectedType, this.selectedStatus, this.isLoading = false});

  AppointmentsNotifierState copyWith({String? selectedType, String? selectedStatus, bool? isLoading}) {
    return AppointmentsNotifierState(
      selectedType: selectedType ?? this.selectedType,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
