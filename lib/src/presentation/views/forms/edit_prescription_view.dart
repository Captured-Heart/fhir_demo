import 'package:fhir_demo/src/controller/prescriptions_controller.dart';
import 'package:fhir_demo/src/presentation/widgets/shared/app_bar_server_switch.dart';
import 'package:fhir_demo/src/presentation/widgets/shared/selected_server_text.dart';
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

class EditPrescriptionView extends ConsumerStatefulWidget {
  final MedicationRequest prescription;

  const EditPrescriptionView({super.key, required this.prescription});

  @override
  ConsumerState<EditPrescriptionView> createState() => _EditPrescriptionViewState();
}

class _EditPrescriptionViewState extends ConsumerState<EditPrescriptionView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(prescriptionsController.notifier).populateFormForEdit(widget.prescription);
    });
  }

  Future<void> _selectDate() async {
    final controller = ref.read(prescriptionsController.notifier);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      controller.startDateController.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(prescriptionsController.notifier);
    final state = ref.watch(prescriptionsController);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Prescription'),
        backgroundColor: const Color(0xffFF9800),
        foregroundColor: AppColors.kWhite,
        actions: [AppBarServerSwitch()],
      ),
      body: SafeArea(
        child: Form(
          key: controller.formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 20,
              children: [
                SelectedServerText(),

                MoodText.text(
                  text: 'Edit Prescription Details',
                  context: context,
                  textStyle: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),

                MoodTextfield(
                  labelText: 'Patient ID *',
                  hintText: 'Enter patient identifier',
                  controller: controller.patientIdController,
                  prefixIcon: const Icon(Icons.person),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter patient ID';
                    }
                    return null;
                  },
                ),

                MoodTextfield(
                  labelText: 'Medication Name *',
                  hintText: 'Enter medication name',
                  controller: controller.medicationController,
                  textCapitalization: TextCapitalization.words,
                  prefixIcon: const Icon(Icons.medication),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter medication name';
                    }
                    return null;
                  },
                ),

                MoodTextfield(
                  labelText: 'Dosage *',
                  hintText: 'e.g., 500mg',
                  controller: controller.dosageController,
                  prefixIcon: const Icon(Icons.local_pharmacy),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter dosage';
                    }
                    return null;
                  },
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8,
                  children: [
                    MoodText.text(
                      text: 'Route of Administration *',
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
                          value: state.selectedRoute,
                          hint: const Text('Select route'),
                          isExpanded: true,
                          items:
                              ['Oral', 'Intravenous', 'Intramuscular', 'Subcutaneous', 'Topical', 'Inhalation'].map((
                                route,
                              ) {
                                return DropdownMenuItem(value: route, child: Text(route));
                              }).toList(),
                          onChanged: (value) => controller.setSelectedRoute(value),
                        ),
                      ),
                    ),
                  ],
                ),

                MoodTextfield(
                  labelText: 'Frequency *',
                  hintText: 'e.g., Twice daily',
                  controller: controller.frequencyController,
                  textCapitalization: TextCapitalization.sentences,
                  prefixIcon: const Icon(Icons.schedule),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter frequency';
                    }
                    return null;
                  },
                ),

                MoodTextfield(
                  labelText: 'Duration *',
                  hintText: 'e.g., 7 days',
                  controller: controller.durationController,
                  prefixIcon: const Icon(Icons.timer),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter duration';
                    }
                    return null;
                  },
                ),

                MoodTextfield(
                  labelText: 'Start Date *',
                  hintText: 'YYYY-MM-DD',
                  controller: controller.startDateController,
                  readOnly: true,
                  onTap: _selectDate,
                  suffixIcon: const Icon(Icons.calendar_today),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select start date';
                    }
                    return null;
                  },
                ),

                MoodTextfield(
                  labelText: 'Prescribing Doctor *',
                  hintText: 'Enter doctor name',
                  controller: controller.prescribingDoctorController,
                  textCapitalization: TextCapitalization.words,
                  prefixIcon: const Icon(Icons.local_hospital),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter doctor name';
                    }
                    return null;
                  },
                ),

                MoodTextfield(
                  labelText: 'Special Instructions',
                  hintText: 'Enter special instructions for patient',
                  controller: controller.instructionsController,
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 3,
                  prefixIcon: const Icon(Icons.info_outline),
                ),

                const SizedBox(height: 10),

                MoodPrimaryButton(
                  title: 'Update Prescription',
                  onPressed: () {
                    if (controller.formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Prescription updated successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.pop(context);
                    }
                  },
                  state: state.isLoading ? ButtonState.loading : ButtonState.initial,
                  bGcolor: const Color(0xffFF9800),
                ),

                MoodOutlineButton(title: 'Reset Form', onPressed: () => controller.clearForm(), color: AppColors.kGrey),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
