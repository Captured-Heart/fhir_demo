import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fhir_demo/constants/text_constants.dart';
import 'package:fhir_demo/hive_helper/cache_helper.dart';
import 'package:fhir_demo/src/controller/bottom_nav_controller.dart';
import 'package:fhir_demo/src/presentation/views/home_view.dart';
import 'package:fhir_demo/src/presentation/views/results_view.dart';
import 'package:fhir_demo/src/presentation/views/settings_view.dart';

class BottomNavView extends ConsumerStatefulWidget {
  const BottomNavView({super.key});

  @override
  ConsumerState<BottomNavView> createState() => _BottomNavViewState();
}

class _BottomNavViewState extends ConsumerState<BottomNavView> {
  @override
  void initState() {
    super.initState();
  }

  Widget bodyWidget({required int currentIndex}) {
    switch (currentIndex) {
      case 0:
        return const HomeView();
      case 1:
        return const ResultsView();
      case 2:
        return const SettingsView();

      default:
        return const HomeView();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(bottomNavBarIndexProvider);
    final currentThreshold = CacheHelper.getClaimedThreshold();
    print('Current Threshold: $currentThreshold');

    return Scaffold(
      body: bodyWidget(currentIndex: currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: (index) {
          ref.read(bottomNavBarIndexProvider.notifier).update((state) => index);
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: TextConstants.home.tr()),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Results'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: TextConstants.settings.tr()),
        ],
      ),
    );
  }
}
