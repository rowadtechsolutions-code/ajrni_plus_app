import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../cars/views/cars_screen.dart';
import '../../favorites/views/favorites_screen.dart';
import '../../offices/views/offices_screen.dart';
import '../../profile/views/profile_screen.dart';
import '../widgets/app_bottom_nav_bar.dart';
import '../../cars/providers/cars_provider.dart';
import '../../favorites/providers/favorites_provider.dart';
import '../../home/providers/home_provider.dart';
import '../../offices/providers/offices_provider.dart';
import '../../auth/providers/auth_provider.dart';
import 'home_screen.dart';

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final country = auth.session?.country ?? '';
      final city = auth.session?.city ?? '';
      context.read<HomeProvider>().load(country: country, city: city);
      context.read<CarsProvider>().load(country: country, city: city);
      context.read<OfficesProvider>().load(country: country, city: city);
      if (auth.isLoggedIn) {
        context.read<FavoritesProvider>().load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(onNavigate: (value) => setState(() => _index = value)),
      const CarsScreen(),
      const OfficesScreen(),
      const FavoritesScreen(),
      const ProfileScreen(),
    ];
    return Scaffold(
      backgroundColor: AppColors.white,
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: AppBottomNavBar(
        selectedIndex: _index,
        onChanged: (value) => setState(() => _index = value),
      ),
    );
  }
}
