// final patient = Patient(
//     id: FhirString('123'),
//     name: [
//       HumanName(
//         family: 'Doe'.toFhirString,
//         given: ['John'.toFhirString],
//       ),
//     ],
//     birthDate: '1990-01-01'.toFhirDate,
//   );
// final age = Age(
//   value: FhirDecimal(65),
//   unit: FhirString('years'),
//   system: FhirUri('http://unitsofmeasure.org'),
//   code: FhirCode('a'),
// );

import 'package:fhir_r4/fhir_r4.dart';

class FhirStaticModel {
  Patient addPatient() {
    return Patient(
      id: FhirString('123'),
      name: [
        HumanName(family: 'Doe'.toFhirString, given: ['John'.toFhirString]),
      ],
      birthDate: '1990-01-01'.toFhirDate,
    );
  }
}
