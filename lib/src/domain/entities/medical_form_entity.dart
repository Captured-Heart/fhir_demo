import 'package:flutter/material.dart';

/// Model representing a medical form available in the FHIR system
class MedicalFormEntity {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String route;

  const MedicalFormEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.route,
  });
}
