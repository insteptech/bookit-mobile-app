import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:flutter/material.dart';

class AddServiceScreen extends StatefulWidget {
  final String? categoryId;
  final String? categoryName;

  const AddServiceScreen({
    super.key,
    this.categoryId,
    this.categoryName,
  });

  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  String? get decodedCategoryName {
    if (widget.categoryName == null) return null;
    return Uri.decodeComponent(widget.categoryName!);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with consistent styling
              Padding(
                padding: const EdgeInsets.fromLTRB(34, 70, 34, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back, size: 32),
                    ),
                    const SizedBox(height: 9),
                    Text(
                      "Add ${decodedCategoryName ?? 'Service'}",
                      style: AppTypography.headingLg,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              // Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 34),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (decodedCategoryName != null) ...[
                      Text(
                        "Category: $decodedCategoryName",
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Category ID: ${widget.categoryId}",
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                    Text(
                      "Add your service details here",
                      style: AppTypography.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    // TODO: Add service form fields here
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text("Service form will go here"),
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}