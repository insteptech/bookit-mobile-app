import 'package:bookit_mobile_app/features/main/calendar/presentation/calendar_screen.dart';
import 'package:bookit_mobile_app/features/main/dashboard/presentation/dashboard_screen.dart';
import 'package:bookit_mobile_app/features/main/menu/presentation/menu_screen.dart';
import 'package:bookit_mobile_app/features/main/offerings/presentation/offerings_screen.dart';
import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Screens for each tab
  final List<Widget> _screens = [
    DashboardScreen(),
    CalendarScreen(),
    OfferingsScreen(),
    MenuScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
Widget build(BuildContext context) {
  final theme = Theme.of(context);

  return Scaffold(
    body: _screens[_selectedIndex],
    bottomNavigationBar: Padding(
      padding: const EdgeInsets.only(top: 5), // Increase top padding here
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: theme.colorScheme.onSurface,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 14,
        ),
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home_outlined,
              color: _selectedIndex == 0
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
            ),
            label: AppTranslationsDelegate.of(context).text("dashboard"),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.calendar_today_outlined,
              color: _selectedIndex == 1
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
            ),
            label: AppTranslationsDelegate.of(context).text("calendar"),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.grid_view_outlined,
              color: _selectedIndex == 2
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
            ),
            label: AppTranslationsDelegate.of(context).text("offerings"),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.menu,
              color: _selectedIndex == 3
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
            ),
            label: AppTranslationsDelegate.of(context).text("menu"),
          ),
        ],
        showUnselectedLabels: true,
      ),
    ),
  );
}
}
