import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/core/models/user_model.dart';
import 'package:bookit_mobile_app/core/services/auth_service.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/auth_api_service.dart';
import 'package:bookit_mobile_app/features/main/menu/widgets/menu_screens_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MembershipStatusScreen extends StatefulWidget {
  const MembershipStatusScreen({super.key});

  @override
  State<MembershipStatusScreen> createState() => _MembershipStatusScreenState();
}

class _MembershipStatusScreenState extends State<MembershipStatusScreen> {
  final AuthStorageService _authStorageService = AuthStorageService();
  UserModel? userData;
  bool isLoading = false;

  void _initializeData() async {
    setState(() {
      isLoading = true;
    });
    
    try {
      var user = await _authStorageService.getUserDetails();
      setState(() {
        userData = user;
        isLoading = false;
      });
    } catch (e) {
      // If no user details found in storage, fetch from API
      try {
        await UserService().fetchUserDetails();
        var user = await _authStorageService.getUserDetails();
        setState(() {
          userData = user;
          isLoading = false;
        });
      } catch (fetchError) {
        setState(() {
          isLoading = false;
        });
        print("Error fetching user data: $fetchError");
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  Widget build(BuildContext context) {
    return MenuScreenScaffold(
      title: "Membership", 
      content: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (userData == null) {
      return Text(
        'No user data found',
        style: AppTypography.bodyMedium,
      );
    }

    final createdAt = userData!.createdAt;
    final formattedDate = createdAt != null 
        ? DateFormat('MMMM dd, yyyy').format(createdAt)
        : 'Unknown';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "You have been a member of BookIt since $formattedDate",
          style: AppTypography.bodyMedium,
        ),
      ],
    );
  }
}
