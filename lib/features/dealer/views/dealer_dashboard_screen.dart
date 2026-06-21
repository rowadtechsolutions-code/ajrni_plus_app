import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import 'dealer_cars_screen.dart';
import 'dealer_profile_screen.dart';
import 'dealer_requests_screen.dart';
import 'dealer_statistics_screen.dart';
import '../widgets/dealer_bottom_nav.dart';

class DealerDashboardScreen extends StatefulWidget {
  const DealerDashboardScreen({super.key});

  @override
  State<DealerDashboardScreen> createState() => _DealerDashboardScreenState();
}

class _DealerDashboardScreenState extends State<DealerDashboardScreen> {
  int _index = 0;
  int _refreshVersion = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      DealerCarsScreen(
        key: ValueKey('cars-$_refreshVersion'),
        onChanged: () => setState(() => _refreshVersion++),
      ),
      const DealerRequestsScreen(),
      DealerStatisticsScreen(key: ValueKey('stats-$_refreshVersion')),
      const DealerProfileScreen(),
    ];
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: DealerBottomNav(
        index: _index,
        onChanged: (value) => setState(() => _index = value),
      ),
    );
  }
}
