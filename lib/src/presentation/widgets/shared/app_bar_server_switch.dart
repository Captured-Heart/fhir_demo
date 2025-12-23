import 'package:fhir_demo/constants/extension.dart';
import 'package:fhir_demo/constants/fhir_server_type_enum.dart';
import 'package:fhir_demo/src/controller/fhir_settings_controller.dart';
import 'package:fhir_demo/src/presentation/widgets/texts/texts_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppBarServerSwitch extends ConsumerWidget {
  const AppBarServerSwitch({super.key, this.onServerChanged});
  final VoidCallback? onServerChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingState = ref.watch(fhirSettingsProvider);
    final settingsCtrl = ref.read(fhirSettingsProvider.notifier);
    return DropdownButtonHideUnderline(
      child: DropdownButton<FhirServerType>(
        value: FhirServerType.values.firstWhere(
          (type) => type.name == settingState.serverType,
          orElse: () => FhirServerType.values.first,
        ),
        isDense: true,
        isExpanded: false,
        items:
            FhirServerType.values.where((type) => type != FhirServerType.custom).map((type) {
              return DropdownMenuItem(
                value: type,
                child: MoodText.text(
                  text: type.name.toUpperCase(),
                  context: context,
                  textStyle: context.textTheme.bodyMedium,
                  // color: AppColors.kWhite,
                ),
              );
            }).toList(),
        onChanged: (value) {
          if (value != null) {
            // Updates server type and base URL in settings
            // DioRepository will automatically pick up the change via ref.listen
            settingsCtrl.updateServerType(value).then((value) {
              if (value) {
                onServerChanged?.call();
              }
            });
          }
        },
      ),
    );
  }
}
