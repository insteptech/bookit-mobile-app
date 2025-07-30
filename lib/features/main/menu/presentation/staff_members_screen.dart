import 'package:bookit_mobile_app/features/main/menu/widgets/menu_screens_scaffold.dart';
import 'package:flutter/material.dart';

class StaffMembersScreen extends StatefulWidget {
  const StaffMembersScreen({super.key});

  @override
  State<StaffMembersScreen> createState() => _StaffMembersScreenState();
}

class _StaffMembersScreenState extends State<StaffMembersScreen> {
  @override
  Widget build(BuildContext context) {
    return MenuScreenScaffold(
      title: "Staff Members",
      content: Center(
        child: Text(
          "Staff Members Screen",
        ),
      )
    );
  }
}