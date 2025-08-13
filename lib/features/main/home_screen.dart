import 'package:bookit_mobile_app/features/calendar/presentation/calendar_screen.dart';
import 'package:bookit_mobile_app/features/dashboard/presentation/dashboard_screen.dart';
import 'package:bookit_mobile_app/features/menu/presentation/menu_screen.dart';
import 'package:bookit_mobile_app/features/offerings/presentation/offerings_screen.dart';
import 'package:flutter/material.dart';
import 'package:bookit_mobile_app/shared/components/atoms/bottom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  final bool refresh;
  const HomeScreen({super.key, this.refresh = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Screens for each tab
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      DashboardScreen(refresh: widget.refresh),
      CalendarScreen(),
      OfferingsScreen(),
      MenuScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: _screens[_selectedIndex],
    bottomNavigationBar: BookitBottomNavBar(
      selectedIndex: _selectedIndex,
      onTap: _onItemTapped,
    ),
  );
}
}
