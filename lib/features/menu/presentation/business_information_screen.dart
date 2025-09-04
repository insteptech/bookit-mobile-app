import 'package:bookit_mobile_app/features/menu/widgets/menu_screens_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:bookit_mobile_app/features/menu/widgets/menu_item.dart';
import 'package:go_router/go_router.dart';

class BusinessInformationScreen extends StatefulWidget {
  const BusinessInformationScreen({super.key});

  @override
  State<BusinessInformationScreen> createState() => _BusinessInformationScreenState();
}

class _BusinessInformationScreenState extends State<BusinessInformationScreen> {
  @override
  Widget build(BuildContext context) {
    return MenuScreenScaffold(
      title: "Business Information",
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
              MenuItem(
                title: "Name, email, phone",
                onTap: () {
                  context.push('/business-information/name-email-phone');
                },
              ),
              MenuItem(
                title: "Addresses",
                onTap: () {
                  context.push('/business-information/addresses');
                },
              ),
              MenuItem(
                title: "Business hours",
                onTap: () {
                  context.push('/business-information/business-hours');
                },
              ),
              MenuItem(
                title: "Photo gallery",
                onTap: () {
                  context.push('/business-information/photo-gallery');
                },
              ),
              MenuItem(
                title: "Booking & cancellation policy",
                onTap: () {},
              ),
              MenuItem(
                title: "Client payment method",
                onTap: () {},
              ),
            ],
          ),
    );
  }
}