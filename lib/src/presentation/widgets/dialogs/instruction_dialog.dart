import 'package:fhir_demo/constants/extension.dart';
import 'package:fhir_demo/utils/shared_pref_util.dart';
import 'package:flutter/material.dart';

void showInstructionDialog({
  required BuildContext context,
  required String title,
  required String subtitle,
  String? fullSubtitle,
  required SharedKeys sharedKeys,
  bool showCheckbox = true,
  VoidCallback? onOkPressed,
}) {
  bool dontShowAgain = false;
  final dontShow = SharedPrefsUtil.getBool(key: sharedKeys.name);

  if (dontShow) return;
  showDialog(
    context: context,
    barrierDismissible: false,
    builder:
        (context) => AlertDialog(
          contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 2),
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                fullSubtitle ??
                    '$subtitle All fields marked with * are mandatory.\n\nYou can also select the FHIR server from the top right dropdown.',
              ),

              const SizedBox(height: 16),
              // do not show this dialog again checkbox
              if (showCheckbox)
                StatefulBuilder(
                  builder: (context, setState) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: dontShowAgain,
                          visualDensity: VisualDensity.compact,
                          onChanged: (value) {
                            setState(() {
                              dontShowAgain = value ?? false;
                            });

                            SharedPrefsUtil.setBool(key: sharedKeys.name, value: value ?? false);
                          },
                        ),
                        Text("Don't show this again", style: context.textTheme.bodySmall),
                      ],
                    );
                  },
                ),
            ],
          ),
          actions: [TextButton(onPressed: onOkPressed ?? () => Navigator.of(context).pop(), child: const Text('OK'))],
        ),
  );
}
