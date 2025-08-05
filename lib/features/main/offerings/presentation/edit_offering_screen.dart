import 'package:bookit_mobile_app/core/services/remote_services/network/api_provider.dart';
import 'package:bookit_mobile_app/features/main/offerings/widgets/offerings_add_service_scaffold.dart';
import 'package:flutter/material.dart';

class EditOfferingScreen extends StatefulWidget {
  final bool? isClass;
  final String serviceId;
  const EditOfferingScreen({super.key, this.isClass, required this.serviceId});

  @override
  State<EditOfferingScreen> createState() => _EditOfferingScreenState();
}

class _EditOfferingScreenState extends State<EditOfferingScreen> {

  @override
  void initState(){
    _fetchServiceDetails();
    super.initState();
  }

    Future<void> _fetchServiceDetails() async {
    try {
      await APIRepository.getServiceDetailsById(widget.serviceId);

    } catch (e) {
      debugPrint("Error fetching service details: $e");
    }
  }
  @override
  Widget build(BuildContext context) {
    return OfferingsAddServiceScaffold(
      title: "Edit class", 
      body: const Placeholder(),
    );
  }
}