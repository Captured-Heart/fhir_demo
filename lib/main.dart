import 'package:fhir_demo/utils/shared_pref_util.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fhir_demo/constants/nav_routes.dart';
import 'package:fhir_demo/constants/text_constants.dart';
import 'package:fhir_demo/hive_helper/cache_helper.dart';
import 'package:fhir_demo/src/controller/theme_controller.dart';
import 'package:fhir_demo/src/presentation/views/auth_view.dart';
import 'package:fhir_demo/src/presentation/views/bottom_nav_view.dart';
import 'package:fhir_demo/src/presentation/views/splash_view.dart';
import 'package:fhir_demo/src/presentation/views/forms/register_patient_view.dart';
import 'package:fhir_demo/src/presentation/views/forms/diagnosis_view.dart';
import 'package:fhir_demo/src/presentation/views/forms/prescriptions_view.dart';
import 'package:fhir_demo/src/presentation/views/forms/observations_view.dart';
import 'package:fhir_demo/src/presentation/views/forms/appointments_view.dart';
import 'package:fhir_demo/src/presentation/views/forms/lab_results_view.dart';
import 'package:fhir_demo/src/presentation/widgets/themes/app_themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await SharedPrefsUtil.init();

  await CacheHelper.openHiveBoxes();
  runApp(
    ProviderScope(
      child: EasyLocalization(
        supportedLocales: const [Locale('en', 'US'), Locale('de', 'DE')],
        saveLocale: true,
        path: 'assets/l10n',
        fallbackLocale: const Locale('en', 'US'),

        child: const MainApp(),
      ),
    ),
  );
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      // key: ValueKey(context.locale),
      restorationScopeId: 'app',
      title: TextConstants.fhirDemo.tr(),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      themeMode: themeMode,

      onGenerateTitle: (context) => TextConstants.fhirDemo.tr(),
      theme: AppThemeData.themeLight,
      darkTheme: AppThemeData.themeDark,
      home: SplashView(),
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) {
            return switch (settings.name) {
              NavRoutes.splashRoute => SplashView(),
              NavRoutes.homeRoute => BottomNavView(),
              NavRoutes.authRoute => AuthView(),
              NavRoutes.registerPatientRoute => RegisterPatientView(),
              NavRoutes.diagnosisRoute => DiagnosisView(),
              NavRoutes.prescriptionsRoute => PrescriptionsView(),
              NavRoutes.observationsRoute => ObservationsView(),
              NavRoutes.appointmentsRoute => AppointmentsView(),
              NavRoutes.labResultsRoute => LabResultsView(),
              _ => SplashView(),
            };
          },
        );
      },
    );
  }
}
