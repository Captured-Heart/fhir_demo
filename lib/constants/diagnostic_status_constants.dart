import 'package:fhir_r4/fhir_r4.dart';

/// Constants for diagnostic and clinical status values
class DiagnosticStatusConstants {
  DiagnosticStatusConstants._();

  /// Extracts unique diagnostic report status values from the FHIR enum
  static final List<String> diagnosticReportStatuses =
      DiagnosticReportStatusEnum.values.map((e) => e.name).toSet().toList();

  /// Clinical status values for conditions (not from enum, but standard FHIR values)
  static const List<String> clinicalStatuses = ['active', 'recurrence', 'relapse', 'inactive', 'remission', 'resolved'];
}
