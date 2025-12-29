import 'dart:convert';

import 'package:fhir_demo/constants/api_constants.dart';
import 'package:fhir_demo/constants/typedefs.dart';
import 'package:fhir_r4/fhir_r4.dart';

class ProjectPatientEntity {
  final String id;
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  final String? gender;
  final String phoneNumber;
  final String? email;
  final String? address;
  final String? emergencyContactNo;

  ProjectPatientEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    this.gender,
    required this.phoneNumber,
    this.email,
    this.address,
    this.emergencyContactNo,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'gender': gender,
      'phoneNumber': phoneNumber,
      'email': email,
      'address': address,
      'emergencyContactNo': emergencyContactNo,
    };
  }

  MapStringDynamic addPatient({Patient? existingPatient}) {
    final body = Patient(
      id: FhirString(id),
      active: FhirBoolean(true),
      name: [
        HumanName(family: lastName.toFhirString, given: [firstName.toFhirString]),
      ],
      identifier: [Identifier(value: ApiConstants.projectIdentifier.toFhirString)],
      birthDate: dateOfBirth.toFhirDate,
      gender: gender != null ? AdministrativeGender(gender?.toLowerCase()) : null,
      telecom: [
        ContactPoint(system: ContactPointSystem.email, value: email?.toFhirString),
        ContactPoint(system: ContactPointSystem.phone, value: phoneNumber.toFhirString),
        ContactPoint(system: ContactPointSystem.other, value: emergencyContactNo?.toFhirString),
      ],
      address: address != null ? [Address(text: address?.toFhirString)] : null,
    );

    if (existingPatient != null) {
      final updatedPatient = existingPatient.copyWith(
        name: body.name,
        birthDate: body.birthDate,
        gender: body.gender,
        telecom: body.telecom,
        address: body.address,
        active: body.active,
      );
      return updatedPatient.toJson();
    }

    return body.toJson();
  }

  factory ProjectPatientEntity.fromMap(Map<String, dynamic> map) {
    return ProjectPatientEntity(
      id: map['id'] as String,
      firstName: map['firstName'] as String,
      lastName: map['lastName'] as String,
      dateOfBirth: DateTime.parse(map['dateOfBirth'] as String),
      gender: map['gender'] != null ? map['gender'] as String : null,
      phoneNumber: map['phoneNumber'] as String,
      email: map['email'] != null ? map['email'] as String : null,
      address: map['address'] != null ? map['address'] as String : null,
      emergencyContactNo: map['emergencyContactNo'] != null ? map['emergencyContactNo'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory ProjectPatientEntity.fromJson(String source) =>
      ProjectPatientEntity.fromMap(json.decode(source) as Map<String, dynamic>);
}
