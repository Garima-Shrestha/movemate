import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/routes/route_names.dart';
import '../../../../core/constants/app_colors.dart';

class DashboardScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const DashboardScreen({required this.navigationShell, super.key});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final bool isSearch = location.contains(RouteNames.destinationSearch);

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: isSearch ? 1 : navigationShell.currentIndex,
        selectedItemColor: isSearch ? AppColors.textLight : AppColors.primary,
        unselectedItemColor: AppColors.textLight,
        onTap: (index) {
          if (index == 0 && isSearch) {
            context.go(RouteNames.userHome);
            return;
          }
          navigationShell.goBranch(index);
        },

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Bookings'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}