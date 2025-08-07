import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
    final theme = Theme.of(context);

    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: theme.colorScheme.surface,
                  backgroundImage:
                      profileImage != null ? FileImage(profileImage!) : null,
                  child:
                      profileImage == null
                          ? const Icon(Icons.person, size: 32)
                          : null,
                ),
                if(profileImage == null)
                Positioned(
                  bottom: 12,
                  right: 0,
                  left: 0,
                  child: Center(
                    child: Text(
                      "Photo",
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                if(profileImage == null)
                Positioned(
                  top: 11,
                  right: 0,
                  left: 0,
                  child: Icon(
                    Icons.upload_outlined,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}