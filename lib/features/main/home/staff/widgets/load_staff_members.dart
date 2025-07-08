import 'package:flutter/material.dart';

class LoadStaffMembers extends StatefulWidget {
  const LoadStaffMembers({super.key});

  @override
  State<LoadStaffMembers> createState() => _LoadStaffMembersState();
}

class _LoadStaffMembersState extends State<LoadStaffMembers> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.person, size: 30, color: Colors.grey),
            )
          ],
        )
      ],
    );
  }
}