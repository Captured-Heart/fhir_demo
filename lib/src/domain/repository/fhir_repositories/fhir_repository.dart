import 'dart:developer';

import 'package:fhir_demo/constants/typedefs.dart';
import 'package:fhir_r4/fhir_r4.dart';

class FhirRepository {
  const FhirRepository._();

  static MapStringDynamic someMethod() {
    final patient = Patient(
      link: [PatientLink(other: Reference(reference: 'Practitioner/123'.toFhirString), type: LinkType('ddd'))],
      language: CommonLanguages('en-US'),
      text: Narrative(status: NarrativeStatus.generated, div: '<div xmlns="http://www.w3.org/1999/xhtml">Patient narrative text</div>'.toFhirXhtml),
    );
    final body = patient.toJson();
    log(patient.toYaml());
    return body;
  }
}

// enum TheseAreTheFhirResources {
//   Account,

//   ActivityDefinition,

//   AdministrableProductDefinition,

//   AdverseEvent,

//   AllergyIntolerance,

//   Appointment,

//   AppointmentResponse,

//   AuditEvent,

//   Basic,

//   Binary,

//   BiologicallyDerivedProduct,

//   BodyStructure,

//   Bundle,

//   CapabilityStatement,

//   CarePlan,

//   CareTeam,

//   CatalogEntry,

//   ChargeItem,

//   ChargeItemDefinition,

//   Citation,

//   Claim,

//   ClaimResponse,

//   ClinicalImpression,

//   ClinicalUseDefinition,

//   CodeSystem,

//   Communication,

//   CommunicationRequest,

//   CompartmentDefinition,

//   Composition,

//   ConceptMap,

//   Condition,

//   Consent,

//   Contract,

//   Coverage,

//   CoverageEligibilityRequest,

//   CoverageEligibilityResponse,

//   DetectedIssue,

//   Device,

//   DeviceDefinition,

//   DeviceMetric,

//   DeviceRequest,

//   DeviceUseStatement,

//   DiagnosticReport,

//   DocumentManifest,

//   DocumentReference,

//   Encounter,

//   EnrollmentRequest,

//   EnrollmentResponse,

//   EpisodeOfCare,

//   EventDefinition,

//   Evidence,

//   EvidenceReport,

//   EvidenceVariable,

//   ExampleScenario,

//   ExplanationOfBenefit,

//   FamilyMemberHistory,

//   FhirEndpoint,

//   FhirGroup,

//   FhirList,

//   Flag,

//   Goal,

//   GraphDefinition,

//   GuidanceResponse,

//   HealthcareService,

//   ImagingStudy,

//   Immunization,

//   ImmunizationEvaluation,

//   ImmunizationRecommendation,

//   ImplementationGuide,

//   Ingredient,

//   InsurancePlan,

//   Invoice,

//   Library,

//   Linkage,

//   Location,

//   ManufacturedItemDefinition,

//   Measure,

//   MeasureReport,
//   Media,
//   Medication,
//   MedicationAdministration,
//   MedicationDispense,
//   MedicationKnowledge,
//   MedicationRequest,
//   MedicationStatement,
//   MedicinalProductDefinition,
//   MessageDefinition,
//   MessageHeader,
//   MolecularSequence,
//   NamingSystem,
//   NutritionOrder,
//   NutritionProduct,
//   Observation,
//   ObservationDefinition,
//   OperationDefinition,
//   OperationOutcome,
//   Organization,
//   OrganizationAffiliation,
//   PackagedProductDefinition,
//   Parameters,
//   Patient,

//   PaymentNotice,
//   PaymentReconciliation,
//   Person,
//   PlanDefinition,
//   Practitioner,
//   PractitionerRole,
//   Procedure,
//   Provenance,
//   Questionnaire,
//   QuestionnaireResponse,
//   RegulatedAuthorization,
//   RelatedPerson,
//   RequestGroup,
//   ResearchDefinition,

//   ResearchElementDefinition,

//   ResearchStudy,

//   ResearchSubject,

//   RiskAssessment,

//   Schedule,

//   SearchParameter,

//   ServiceRequest,

//   Slot,

//   Specimen,

//   SpecimenDefinition,

//   StructureDefinition,

//   StructureMap,

//   Subscription,

//   SubscriptionStatus,

//   SubscriptionTopic,

//   Substance,

//   SubstanceDefinition,

//   SupplyDelivery,

//   SupplyRequest,

//   Task,

//   TerminologyCapabilities,

//   TestReport,

//   TestScript,

//   ValueSet,

//   VerificationResult,

//   VisionPrescription,
// }
