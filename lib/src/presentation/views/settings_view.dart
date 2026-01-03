import 'package:fhir_demo/constants/app_images.dart';
import 'package:fhir_demo/constants/button_state.dart';
import 'package:fhir_demo/constants/fhir_server_type_enum.dart';
import 'package:fhir_demo/hive_helper/cache_helper.dart';
import 'package:fhir_demo/src/presentation/widgets/buttons/outline_button.dart';
import 'package:fhir_demo/src/presentation/widgets/buttons/primary_button.dart';
import 'package:fhir_demo/src/presentation/widgets/shared/custom_screen_header.dart';
import 'package:fhir_demo/src/presentation/widgets/textfield/app_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fhir_demo/constants/app_colors.dart';
import 'package:fhir_demo/constants/extension.dart';
import 'package:fhir_demo/constants/spacings.dart';
import 'package:fhir_demo/src/controller/fhir_settings_controller.dart';
import 'package:fhir_demo/src/presentation/widgets/texts/texts_widget.dart';

class SettingsView extends ConsumerStatefulWidget {
  const SettingsView({super.key});

  @override
  ConsumerState<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends ConsumerState<SettingsView> {
  bool _isTestingConnection = false;

  Future<void> _testConnection() async {
    setState(() => _isTestingConnection = true);

    final notifier = ref.read(fhirSettingsProvider.notifier);
    final success = await notifier.testConnection();

    setState(() => _isTestingConnection = false);

    if (mounted) {
      context.showSnackBar(
        message: success ? '✓ Connection successful!' : '✗ Connection failed. Please check your settings.',
        isError: !success,
      );
    }
  }

  void _resetDialog(FhirSettingsNotifier notifier) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Reset Settings'),
            content: const Text('Are you sure you want to reset all settings to default values?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              TextButton(
                onPressed: () {
                  notifier.resetToDefaults();
                  Navigator.pop(context);
                  context.showSnackBar(message: 'Settings reset to defaults');
                },
                child: const Text('Reset'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingState = ref.watch(fhirSettingsProvider);
    final settingsCtrl = ref.read(fhirSettingsProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Section
            CustomScreenHeader(
              title: 'Settings',
              subtitle: 'Configure FHIR server connection',
              trailing: Icon(Icons.settings, color: AppColors.kWhite, size: 28),
            ),

            // Settings Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 24,
                  children: [
                    Column(
                      spacing: 4,
                      children: [
                        Image.asset(AppImages.noImageAvatar.pngPath, height: 100, width: 100, fit: BoxFit.cover),

                        MoodText.text(
                          context: context,
                          text: CacheHelper.currentUser?.name ?? '',
                          textStyle: context.textTheme.titleMedium,
                        ),

                        MoodText.text(
                          context: context,
                          text: CacheHelper.currentUser?.email ?? '',
                          textStyle: context.textTheme.bodySmall,
                        ),
                      ],
                    ),
                    // Server Type Section
                    BuildSettingsSection(
                      title: 'Server Type',
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.kGrey.withValues(alpha: 0.3)),
                          borderRadius: AppSpacings.borderRadiusk20All,
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<FhirServerType>(
                            value: FhirServerType.values.firstWhere(
                              (type) => type.name == settingState.serverType,
                              orElse: () => FhirServerType.values.first,
                            ),
                            isExpanded: true,
                            items:
                                FhirServerType.values.map((type) {
                                  return DropdownMenuItem(value: type, child: Text(type.name.toUpperCase()));
                                }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                settingsCtrl.updateServerType(value);
                              }
                            },
                          ),
                        ),
                      ),
                    ),

                    // Server URL Section
                    if (settingState.serverType == FhirServerType.custom.name)
                      BuildSettingsSection(
                        title: 'Add Custom Server Base URL',
                        child: MoodTextfield(
                          controller: settingsCtrl.serverUrlController,
                          hintText: settingState.serverBaseUrl,
                          focusNode: settingsCtrl.serverUrlFocusNode,
                          prefixIcon: const Icon(Icons.link),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.save),
                            onPressed: () {
                              settingsCtrl.updateServerUrl(settingsCtrl.serverUrlController.text);
                              context.showSnackBar(message: 'Server URL updated');
                            },
                          ),
                          keyboardType: TextInputType.url,
                        ),
                      ),

                    // Authentication Section
                    // BuildSettingsSection(
                    //   title: 'Authentication',
                    //   child: Column(
                    //     spacing: 12,
                    //     children: [
                    //       SwitchListTile(
                    //         title: const Text('Use Authentication'),
                    //         subtitle: const Text('Enable API key authentication'),
                    //         value: settingState.useAuthentication,
                    //         onChanged: (value) {
                    //           settingsCtrl.toggleAuthentication(value);
                    //         },
                    //         shape: RoundedRectangleBorder(
                    //           borderRadius: AppSpacings.borderRadiusk20All,
                    //           side: BorderSide(color: AppColors.kGrey.withValues(alpha: 0.3)),
                    //         ),
                    //       ),
                    //       if (settingState.useAuthentication)
                    //         TextField(
                    //           controller: settingsCtrl.apiKeyController,
                    //           decoration: InputDecoration(
                    //             hintText: 'Enter API Key',
                    //             border: OutlineInputBorder(borderRadius: AppSpacings.borderRadiusk20All),
                    //             prefixIcon: const Icon(Icons.key),
                    //             suffixIcon: IconButton(
                    //               icon: const Icon(Icons.save),
                    //               onPressed: () {
                    //                 settingsCtrl.updateApiKey();
                    //                 context.showSnackBar(message: 'API key updated');
                    //               },
                    //             ),
                    //           ),
                    //           obscureText: true,
                    //         ),
                    //     ],
                    //   ),
                    // ),

                    // Action Buttons Section
                    // Column(
                    //   spacing: 12,
                    //   children: [
                    //     // Test Connection Button
                    //     MoodPrimaryButton(
                    //       onPressed: _isTestingConnection ? null : _testConnection,
                    //       state: _isTestingConnection ? ButtonState.loading : ButtonState.loaded,
                    //       icon: const Icon(Icons.wifi_tethering, color: AppColors.kWhite),
                    //       title: 'Test Connection',
                    //     ),

                    //     // Reset to Defaults Button
                        MoodOutlineButton(onPressed: () => _resetDialog(settingsCtrl), title: 'Reset to Defaults'),
                    //   ],
                    // ),

                    // Info Card
                    SettingsServerInfoCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsServerInfoCard extends ConsumerWidget {
  const SettingsServerInfoCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(fhirSettingsProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.kPrimary.withValues(alpha: 0.1),
        borderRadius: AppSpacings.borderRadiusk20All,
        border: Border.all(color: AppColors.kPrimary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.kPrimary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Current Configuration',
                style: context.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.kPrimary),
              ),
            ],
          ),
          Text('Server: ${settings.serverType}', style: context.textTheme.bodySmall),
          Text(
            'URL: ${settings.serverBaseUrl}',
            style: context.textTheme.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            'Authentication: ${settings.useAuthentication ? "Enabled" : "Disabled"}',
            style: context.textTheme.bodySmall,
          ),
          Text('Timeout: ${settings.requestTimeout}s', style: context.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class BuildSettingsSection extends StatelessWidget {
  const BuildSettingsSection({super.key, required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        MoodText.text(
          text: title,
          context: context,
          textStyle: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        child,
      ],
    );
  }
}
