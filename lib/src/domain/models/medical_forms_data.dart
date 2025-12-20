import 'package:fhir_demo/src/domain/entities/medical_form_entity.dart';
import 'package:flutter/material.dart';

/// Constants and data for medical forms used in FHIR integration
class MedicalFormsData {
  MedicalFormsData._();

  /// List of available medical forms
  static const List<MedicalFormEntity> medicalForms = [
    MedicalFormEntity(
      id: 'register_patient',
      title: 'Register Patient',
      description: 'Add new patient records',
      icon: Icons.person_add,
      color: Color(0xff4CAF50), // Green
      route: '/register-patient',
    ),
    MedicalFormEntity(
      id: 'diagnosis',
      title: 'Diagnosis',
      description: 'Record medical diagnosis',
      icon: Icons.medical_services,
      color: Color(0xff2196F3), // Blue
      route: '/diagnosis',
    ),
    MedicalFormEntity(
      id: 'prescriptions',
      title: 'Prescriptions',
      description: 'Manage medications',
      icon: Icons.medication,
      color: Color(0xffFF9800), // Orange
      route: '/prescriptions',
    ),
    MedicalFormEntity(
      id: 'observations',
      title: 'Observations',
      description: 'Record vital signs',
      icon: Icons.monitor_heart,
      color: Color(0xffE91E63), // Pink
      route: '/observations',
    ),
    MedicalFormEntity(
      id: 'appointments',
      title: 'Appointments',
      description: 'Schedule visits',
      icon: Icons.calendar_month,
      color: Color(0xff9C27B0), // Purple
      route: '/appointments',
    ),
    MedicalFormEntity(
      id: 'lab_results',
      title: 'Lab Results',
      description: 'View test results',
      icon: Icons.science,
      color: Color(0xff00BCD4), // Cyan
      route: '/lab-results',
    ),
  ];
}
