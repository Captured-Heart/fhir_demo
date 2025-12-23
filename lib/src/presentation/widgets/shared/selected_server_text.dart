import 'package:fhir_demo/constants/app_colors.dart';
import 'package:fhir_demo/constants/extension.dart';
import 'package:fhir_demo/src/controller/fhir_settings_controller.dart';
import 'package:fhir_demo/src/presentation/widgets/texts/texts_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectedServerText extends ConsumerWidget {
  const SelectedServerText({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedServer = ref.watch(fhirSettingsProvider.select((state) => state.serverBaseUrl));

    return MoodText.text(
      text: 'Selected Server: $selectedServer',
      context: context,
      textStyle: context.textTheme.bodySmall?.copyWith(),
      color: AppColors.kGreen,
    );
  }
}
