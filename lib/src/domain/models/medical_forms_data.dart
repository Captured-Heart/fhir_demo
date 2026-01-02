import 'package:fhir_demo/src/domain/entities/medical_form_entity.dart';
import 'package:fhir_demo/src/presentation/views/forms/appointments_view.dart';
import 'package:fhir_demo/src/presentation/views/forms/edit_diagnosis_view.dart';
import 'package:fhir_demo/src/presentation/views/forms/edit_patient_view.dart';
import 'package:fhir_demo/src/presentation/views/forms/lab_view.dart';
import 'package:fhir_demo/src/presentation/views/forms/observations_view.dart';
import 'package:fhir_demo/src/presentation/views/forms/prescriptions_view.dart';
import 'package:fhir_demo/src/presentation/views/results/patient_result_view.dart';
import 'package:fhir_demo/src/presentation/views/results/diagnosis_result_view.dart';
import 'package:fhir_demo/src/presentation/views/results/prescriptions_result_view.dart';
import 'package:fhir_demo/src/presentation/views/results/observation_result_view.dart';
import 'package:fhir_demo/src/presentation/views/results/appointment_result_view.dart';
import 'package:fhir_demo/src/presentation/views/results/lab_result_view.dart';
import 'package:fhir_r4/fhir_r4.dart';
import 'package:flutter/material.dart';

/// Constants and data for medical forms used in FHIR integration
enum MedicalFormsData {
  registerPatient(
    id: 'register_patient',
    title: 'Registered Patient',
    description: 'Add new patient records',
    icon: Icons.person_add,
    color: Color(0xff4CAF50),
    route: '/register-patient',
  ),
  diagnosis(
    id: 'diagnosis',
    title: 'Diagnosis',
    description: 'Record medical diagnosis',
    icon: Icons.medical_services,
    color: Color(0xff2196F3),
    route: '/diagnosis',
  ),
  prescriptions(
    id: 'prescriptions',
    title: 'Prescriptions',
    description: 'Manage medications',
    icon: Icons.medication,
    color: Color(0xffFF9800),
    route: '/prescriptions',
  ),
  observations(
    id: 'observations',
    title: 'Observations',
    description: 'Record vital signs',
    icon: Icons.monitor_heart,
    color: Color(0xffE91E63),
    route: '/observations',
  ),
  appointments(
    id: 'appointments',
    title: 'Appointments',
    description: 'Schedule visits',
    icon: Icons.calendar_month,
    color: Color(0xff9C27B0),
    route: '/appointments',
  ),
  labResults(
    id: 'lab_results',
    title: 'Lab Results',
    description: 'View test results',
    icon: Icons.science,
    color: Color(0xff00BCD4),
    route: '/lab-results',
  );

  const MedicalFormsData({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.route,
  });

  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String route;

  /// Convert to MedicalFormEntity
  MedicalFormEntity toEntity() =>
      MedicalFormEntity(id: id, title: title, description: description, icon: icon, color: color, route: route);

  /// Get all forms as entities
  static List<MedicalFormEntity> get medicalForms => values.map((e) => e.toEntity()).toList();

  static void navigateToForm(BuildContext context, String formId, Object? arguments) {
    final form = values.firstWhere((form) => form.id == formId, orElse: () => registerPatient);
    Navigator.pushNamed(context, form.route, arguments: arguments);
  }

  /// Navigate to result detail view without using named routes
  static void navigateToResultView(
    BuildContext context,
    String formId, {
    required String categoryTitle,
    required Color categoryColor,
    required IconData categoryIcon,
  }) {
    final form = values.firstWhere((form) => form.id == formId, orElse: () => registerPatient);
    void navigateToResultView(Widget resultView) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => resultView));
    }

    return switch (form) {
      registerPatient => () {
        navigateToResultView(
          PatientResultDetailView(
            categoryTitle: categoryTitle,
            categoryColor: categoryColor,
            categoryIcon: categoryIcon,
          ),
        );
      }(),

      MedicalFormsData.diagnosis => () {
        navigateToResultView(
          DiagnosisResultDetailView(
            categoryTitle: categoryTitle,
            categoryColor: categoryColor,
            categoryIcon: categoryIcon,
          ),
        );
      }(),

      MedicalFormsData.prescriptions => () {
        navigateToResultView(
          PrescriptionResultDetailView(
            categoryTitle: categoryTitle,
            categoryColor: categoryColor,
            categoryIcon: categoryIcon,
          ),
        );
      }(),

      MedicalFormsData.observations => () {
        navigateToResultView(
          ObservationResultDetailView(
            categoryTitle: categoryTitle,
            categoryColor: categoryColor,
            categoryIcon: categoryIcon,
          ),
        );
      }(),

      MedicalFormsData.appointments => () {
        navigateToResultView(
          AppointmentResultDetailView(
            categoryTitle: categoryTitle,
            categoryColor: categoryColor,
            categoryIcon: categoryIcon,
          ),
        );
      }(),

      MedicalFormsData.labResults => () {
        navigateToResultView(
          LabResultDetailView(categoryTitle: categoryTitle, categoryColor: categoryColor, categoryIcon: categoryIcon),
        );
      }(),
    };
  }

  // navigate to edit form view
  static void navigateToEditForm(BuildContext context, String formId, {required Object? arguments}) {
    navigateToEditForm(Widget page) {
      return Navigator.push(context, MaterialPageRoute(builder: (context) => page));
    }

    final form = values.firstWhere((form) => form.id == formId, orElse: () => registerPatient);
    return switch (form) {
      registerPatient => () {
        navigateToEditForm(EditPatientView(patient: (arguments as Patient)));
      }(),
      MedicalFormsData.diagnosis => () {
        navigateToEditForm(EditDiagnosisView(diagnosis: (arguments as DiagnosticReport)));
      }(),

      MedicalFormsData.prescriptions => () {
        navigateToEditForm(PrescriptionsView(prescription: (arguments as MedicationRequest)));
      }(),

      MedicalFormsData.observations => () {
        navigateToEditForm(ObservationsView(observation: (arguments as Observation)));
      }(),

      MedicalFormsData.appointments => () {
        navigateToEditForm(AppointmentsView(appointment: (arguments as Appointment), ));
      }(),

      MedicalFormsData.labResults => () {
        navigateToEditForm(LabView(labResult: (arguments as DiagnosticReport)   ));
      }(),
    };
  }
}
