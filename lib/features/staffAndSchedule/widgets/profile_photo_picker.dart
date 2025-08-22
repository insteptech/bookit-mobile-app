import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bookit_mobile_app/app/theme/app_colors.dart';

class ProfilePhotoPicker extends StatefulWidget {
  final VoidCallback? onImageChanged;
  
  const ProfilePhotoPicker({super.key, this.onImageChanged});

  @override
  State<ProfilePhotoPicker> createState() => ProfilePhotoPickerState();
}

class ProfilePhotoPickerState extends State<ProfilePhotoPicker> {
  File? profileImage;

  /// Public getter for profile image
  File? get selectedImage => profileImage;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        profileImage = File(pickedFile.path);
      });
      widget.onImageChanged?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: _pickImage,
        child: Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: AssetImage('assets/images/profile_picker_background.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: profileImage != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Image.file(
                  profileImage!,
                  fit: BoxFit.cover,
                  width: 56,
                  height: 56,
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/icons/actions/share.svg',
                    width: 18,
                    height: 18,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Photo",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Campton',
                    ),
                  ),
                ],
              ),
        ),
      ),
    );
  }
}