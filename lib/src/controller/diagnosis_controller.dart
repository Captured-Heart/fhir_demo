// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final diagnosisController = NotifierProvider.autoDispose<DiagnosisNotifier, DiagnosisNotifierState>(
  DiagnosisNotifier.new,
);

class DiagnosisNotifier extends AutoDisposeNotifier<DiagnosisNotifierState> {
  late GlobalKey<FormState> _formKey;
  late TextEditingController _patientIdController;
  late TextEditingController _conditionController;
  late TextEditingController _severityController;
  late TextEditingController _onsetDateController;
  late TextEditingController _notesController;
  late TextEditingController _diagnosingDoctorController;
  @override
  build() {
    _formKey = GlobalKey<FormState>();
    _patientIdController = TextEditingController();
    _conditionController = TextEditingController();
    _severityController = TextEditingController();
    _onsetDateController = TextEditingController();
    _notesController = TextEditingController();
    _diagnosingDoctorController = TextEditingController();

    return DiagnosisNotifierState();
  }

  void clearForm() {
    _formKey.currentState?.reset();
    _patientIdController.clear();
    _conditionController.clear();
    _severityController.clear();
    _onsetDateController.clear();
    _notesController.clear();
    _diagnosingDoctorController.clear();
    state = state.copyWith(selectedSeverity: '', selectedStatus: '');
  }

  void setSelectedSeverity(String? severity) {
    state = state.copyWith(selectedSeverity: severity);
  }

  void setSelectedStatus(String? status) {
    state = state.copyWith(selectedStatus: status);
  }

  // -------- GETTERS --------
  GlobalKey<FormState> get formKey => _formKey;
  TextEditingController get patientIdController => _patientIdController;
  TextEditingController get conditionController => _conditionController;
  TextEditingController get severityController => _severityController;
  TextEditingController get onsetDateController => _onsetDateController;
  TextEditingController get notesController => _notesController;
  TextEditingController get diagnosingDoctorController => _diagnosingDoctorController;
}

class DiagnosisNotifierState {
  final String? selectedSeverity;
  final String? selectedStatus;
  final bool isLoading;

  DiagnosisNotifierState({this.selectedSeverity, this.selectedStatus, this.isLoading = false});

  DiagnosisNotifierState copyWith({String? selectedSeverity, String? selectedStatus, bool? isLoading}) {
    return DiagnosisNotifierState(
      selectedSeverity: selectedSeverity ?? this.selectedSeverity,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
