import 'package:fhir_demo/src/controller/patient_controller.dart';
import 'package:fhir_demo/src/presentation/widgets/dialogs/instruction_dialog.dart';
import 'package:fhir_demo/src/presentation/widgets/shared/app_bar_server_switch.dart';
import 'package:fhir_demo/src/presentation/widgets/shared/selected_server_text.dart';
import 'package:fhir_demo/utils/shared_pref_util.dart';
import 'package:fhir_demo/utils/validations.dart';
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

class RegisterPatientView extends ConsumerStatefulWidget {
  const RegisterPatientView({super.key});

  @override
  ConsumerState<RegisterPatientView> createState() => _RegisterPatientViewState();
}

class _RegisterPatientViewState extends ConsumerState<RegisterPatientView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => showInstructionDialog(
        context: context,
        title: 'Register Patient',
        subtitle: 'Fill out the form to register a new patient in the system. ',
        sharedKeys: SharedKeys.patientInstructionDontShowAgain,
      ),
    );
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
        title: const Text('Register Patient'),
        backgroundColor: const Color(0xff4CAF50),
        foregroundColor: AppColors.kWhite,
        actions: [AppBarServerSwitch()],
      ),
      body: SafeArea(
        child: Form(
          key: patientCtrl.patientFormKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 20,
              children: [
                SelectedServerText(),
                // Header
                MoodText.text(
                  text: 'Patient Information',
                  context: context,
                  textStyle: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),

                // First Name
                MoodTextfield(
                  labelText: 'First Name *',
                  hintText: 'Enter first name',
                  controller: patientCtrl.firstNameController,
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  validator: (value) => AppValidations.validatedName(value),
                ),

                // Last Name
                MoodTextfield(
                  labelText: 'Last Name *',
                  hintText: 'Enter last name',
                  controller: patientCtrl.lastNameController,
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  validator: (value) => AppValidations.validatedName(value),
                ),

                // Date of Birth
                MoodTextfield(
                  labelText: 'Date of Birth *',
                  hintText: 'YYYY-MM-DD',
                  controller: patientCtrl.dateOfBirthController,
                  readOnly: true,
                  onTap:
                      () => _selectDate(
                        onPicked: (selectedDate) {
                          patientCtrl.formatBirthDate(selectedDate!);
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
                        border: Border.all(color: AppColors.kGrey.withOpacity(0.3)),
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
                          onChanged: (value) {
                            patientCtrl.updateGender(value);
                          },
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
                  validator: (value) => AppValidations.validatePhone(value),
                ),

                // Email
                MoodTextfield(
                  labelText: 'Email',
                  hintText: 'Enter email address',
                  controller: patientCtrl.emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email),
                ),

                // Address
                MoodTextfield(
                  labelText: 'Address',
                  hintText: 'Enter full address',
                  controller: patientCtrl.addressController,
                  keyboardType: TextInputType.streetAddress,
                  textCapitalization: TextCapitalization.words,
                  maxLines: 3,
                  inputFormatters: [],
                  prefixIcon: const Icon(Icons.home),
                ),

                // Emergency Contact
                MoodTextfield(
                  labelText: 'Emergency Contact',
                  hintText: 'Enter emergency contact number',
                  controller: patientCtrl.emergencyContactController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.emergency),
                ),

                const SizedBox(height: 10),

                // Submit Button
                MoodPrimaryButton(
                  title: 'Register Patient',
                  onPressed:
                      () => patientCtrl.submitForm(
                        onGenderValidationFailed: () {
                          context.showSnackBar(message: 'Please select a gender', isError: true);
                        },
                        onSuccess: () {
                          context.showSnackBar(message: 'Patient registered successfully');
                          Navigator.pop(context);
                        },
                        onError: () {
                          context.showSnackBar(message: 'Failed to register patient', isError: true);
                        },
                      ),
                  state: patientState.isLoading ? ButtonState.loading : ButtonState.loaded,
                  bGcolor: const Color(0xff4CAF50),
                ),

                // Clear Button
                MoodOutlineButton(title: 'Clear Form', onPressed: patientCtrl.clearForm, color: AppColors.kGrey),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
