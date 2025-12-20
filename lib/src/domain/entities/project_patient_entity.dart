import 'dart:convert';

class ProjectPatientEntity {
  final String id;
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  final String? gender;
  final String? phoneNumber;
  final String? email;
  final String? address;
  final String? emergencyContactNo;

  ProjectPatientEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    this.gender,
    this.phoneNumber,
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

  factory ProjectPatientEntity.fromMap(Map<String, dynamic> map) {
    return ProjectPatientEntity(
      id: map['id'] as String,
      firstName: map['firstName'] as String,
      lastName: map['lastName'] as String,
      dateOfBirth: DateTime.parse(map['dateOfBirth'] as String),
      gender: map['gender'] != null ? map['gender'] as String : null,
      phoneNumber: map['phoneNumber'] != null ? map['phoneNumber'] as String : null,
      email: map['email'] != null ? map['email'] as String : null,
      address: map['address'] != null ? map['address'] as String : null,
      emergencyContactNo: map['emergencyContactNo'] != null ? map['emergencyContactNo'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory ProjectPatientEntity.fromJson(String source) =>
      ProjectPatientEntity.fromMap(json.decode(source) as Map<String, dynamic>);
}
