import 'package:bookit_mobile_app/core/services/remote_services/network/api_provider.dart';
import 'package:bookit_mobile_app/features/main/menu/widgets/menu_screens_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StaffMembersScreen extends StatefulWidget {
  const StaffMembersScreen({super.key});

  @override
  State<StaffMembersScreen> createState() => _StaffMembersScreenState();
}

class _StaffMembersScreenState extends State<StaffMembersScreen> {

  Future<void> _fetchStaffMembers() async {
    await APIRepository.getAllStaffList();
  }
  @override
  void initState() {
    super.initState();
    _fetchStaffMembers();
  }
  @override
  Widget build(BuildContext context) {
    return MenuScreenScaffold(
      title: "Staff Members",
      content: Center(
        child: Text(
          "Staff Members Screen",
        ),
      ),
      buttonText: "Add Member",
      onButtonPressed: () {
        context.push("/add_staff/?buttonMode=saveOnly");
      },
    );

  }
}