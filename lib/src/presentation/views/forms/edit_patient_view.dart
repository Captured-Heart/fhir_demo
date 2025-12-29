import 'package:fhir_demo/src/controller/patient_controller.dart';
import 'package:fhir_demo/src/presentation/widgets/shared/app_bar_server_switch.dart';
import 'package:fhir_demo/src/presentation/widgets/shared/selected_server_text.dart';
import 'package:fhir_demo/utils/validations.dart';
import 'package:fhir_r4/fhir_r4.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fhir_demo/constants/app_colors.dart';
import 'package:fhir_demo/constants/button_state.dart';
import 'package:fhir_demo/constants/extension.dart';
import 'package:fhir_demo/constants/spacings.dart';
import 'package:fhir_demo/src/presentation/widgets/buttons/primary_button.dart';
import 'package:fhir_demo/src/presentation/widgets/buttons/outline_button.dart';
import 'package:fhir_demo/src/presentation/widgets/textfield/app_textfield.dart';
import 'package:fhir_demo/src/presentation/widgets/texts/texts_widget.dart';

class EditPatientView extends ConsumerStatefulWidget {
  final Patient patient;

  const EditPatientView({super.key, required this.patient});

  @override
  ConsumerState<EditPatientView> createState() => _EditPatientViewState();
}

class _EditPatientViewState extends ConsumerState<EditPatientView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(patientController.notifier).populateFormForEdit(widget.patient);
    });
  }

  Future<void> _selectDate({Function(DateTime?)? onPicked}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      onPicked?.call(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final patientCtrl = ref.read(patientController.notifier);
    final patientState = ref.watch(patientController);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Patient'),
        backgroundColor: const Color(0xff4CAF50),
        foregroundColor: AppColors.kWhite,
        actions: [AppBarServerSwitch()],
      ),
      body: SafeArea(
        child: Form(
          key: patientCtrl.patientFormKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 20,
              children: [
                SelectedServerText(),

                // Header
                MoodText.text(
                  text: 'Edit Patient Information',
                  context: context,
                  textStyle: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),

                // First Name
                MoodTextfield(
                  labelText: 'First Name *',
                  hintText: 'Enter first name',
                  controller: patientCtrl.firstNameController,
                  textCapitalization: TextCapitalization.words,
                  prefixIcon: const Icon(Icons.person),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter first name';
                    }
                    return null;
                  },
                ),

                // Last Name
                MoodTextfield(
                  labelText: 'Last Name *',
                  hintText: 'Enter last name',
                  controller: patientCtrl.lastNameController,
                  textCapitalization: TextCapitalization.words,
                  prefixIcon: const Icon(Icons.person_outline),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter last name';
                    }
                    return null;
                  },
                ),

                // Date of Birth
                MoodTextfield(
                  labelText: 'Date of Birth *',
                  hintText: 'YYYY-MM-DD',
                  controller: patientCtrl.dateOfBirthController,
                  readOnly: true,
                  onTap:
                      () => _selectDate(
                        onPicked: (date) {
                          if (date != null) {
                            patientCtrl.dateOfBirthController.text =
                                '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                          }
                        },
                      ),
                  suffixIcon: const Icon(Icons.calendar_today),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select date of birth';
                    }
                    return null;
                  },
                ),

                // Gender
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8,
                  children: [
                    MoodText.text(
                      text: 'Gender *',
                      context: context,
                      textStyle: context.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.kGrey.withValues(alpha: 0.3)),
                        borderRadius: AppSpacings.borderRadiusk20All,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: patientState.selectedGender,
                          hint: const Text('Select gender'),
                          isExpanded: true,
                          items:
                              ['Male', 'Female'].map((gender) {
                                return DropdownMenuItem(value: gender, child: Text(gender));
                              }).toList(),
                          onChanged: (value) => patientCtrl.updateGender(value),
                        ),
                      ),
                    ),
                  ],
                ),

                // Phone
                MoodTextfield(
                  labelText: 'Phone Number *',
                  hintText: 'Enter phone number',
                  controller: patientCtrl.phoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter phone number';
                    }
                    return null;
                  },
                ),

                // Email
                MoodTextfield(
                  labelText: 'Email',
                  hintText: 'Enter email address',
                  controller: patientCtrl.emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email),
                  validator: (v) => AppValidations.validatedEmail(v),
                ),

                // Address
                MoodTextfield(
                  labelText: 'Street Address',
                  hintText: 'Enter street address',
                  inputFormatters: [],

                  controller: patientCtrl.addressController,
                  textCapitalization: TextCapitalization.words,
                  prefixIcon: const Icon(Icons.home),
                ),

                // City
                // MoodTextfield(
                //   labelText: 'City',
                //   hintText: 'Enter city',
                //   controller: patientCtrl.cityController,
                //   textCapitalization: TextCapitalization.words,
                //   prefixIcon: const Icon(Icons.location_city),
                // ),

                // // State
                // MoodTextfield(
                //   labelText: 'State/Province',
                //   hintText: 'Enter state or province',
                //   controller: patientCtrl.stateController,
                //   textCapitalization: TextCapitalization.words,
                //   prefixIcon: const Icon(Icons.map),
                // ),

                // // Postal Code
                // MoodTextfield(
                //   labelText: 'Postal Code',
                //   hintText: 'Enter postal code',
                //   controller: patientCtrl.postalCodeController,
                //   prefixIcon: const Icon(Icons.pin_drop),
                // ),

                // Emergency Contact
                MoodTextfield(
                  labelText: 'Emergency Contact',
                  hintText: 'Enter emergency contact number',
                  controller: patientCtrl.emergencyContactController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.emergency),
                ),
                const SizedBox(height: 10),

                // Update Button
                MoodPrimaryButton(
                  title: 'Update Patient',
                  onPressed: () {
                    patientCtrl.editPatientForm(
                      existingPatient: widget.patient,
                      onGenderValidationFailed: () {
                        context.showSnackBar(message: 'Please select a gender', isError: true);
                      },
                      onSuccess: () {
                        context.showSnackBar(message: 'Patient updated successfully');
                        Navigator.pop(context);
                      },
                      onError: () {
                        context.showSnackBar(message: 'Failed to update patient', isError: true);
                      },
                    );
                  },
                  state: patientState.isLoading ? ButtonState.loading : ButtonState.initial,
                  bGcolor: const Color(0xff4CAF50),
                ),

                // Clear Button
                MoodOutlineButton(
                  title: 'Reset Form',
                  onPressed: () => patientCtrl.clearForm(),
                  color: AppColors.kGrey,
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
