import 'package:fhir_demo/hive_helper/cache_helper.dart';
import 'package:fhir_demo/src/controller/fhir_settings_controller.dart';
import 'package:fhir_demo/src/domain/entities/patient_server_id_entity.dart';
import 'package:fhir_demo/src/presentation/widgets/dialogs/instruction_dialog.dart';
import 'package:fhir_demo/src/presentation/widgets/textfield/app_drop_down.dart';
import 'package:fhir_demo/utils/shared_pref_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PatientIdDropdown extends ConsumerStatefulWidget {
  const PatientIdDropdown({super.key, this.onChanged});

  final Function(String)? onChanged;

  @override
  ConsumerState<PatientIdDropdown> createState() => _PatientIdDropdownState();
}

class _PatientIdDropdownState extends ConsumerState<PatientIdDropdown> {
  String? value;
  @override
  Widget build(BuildContext context) {
    final serverType = ref.watch(fhirSettingsProvider).serverType;
    final patientServerIds =
        CacheHelper.getPatientServerIdByServerType(serverType)?.map((e) => e.getIdAndName()).toList();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (patientServerIds == null || patientServerIds.isEmpty) {
        showInstructionDialog(
          context: context,
          title: 'Patient ID is required',
          subtitle: '',
          fullSubtitle: 'To fill out the form, you must have a Patient ID for the selected FHIR server: $serverType.',
          sharedKeys: SharedKeys.diagnosisPatientId,
          showCheckbox: false,
          onOkPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
        );
      }
    });
    return AppDropDownWidget(
      value: value,
      labelText: 'Patient ID *',
      items: patientServerIds ?? [],
      onChanged: (value) {
        final selectedId = (value as String);
        if (widget.onChanged != null) {
          widget.onChanged!(selectedId);
        }
        setState(() {
          this.value = selectedId;
        });
      },
    );
  }
}
