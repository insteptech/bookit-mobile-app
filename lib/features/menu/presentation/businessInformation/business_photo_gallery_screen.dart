import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:bookit_mobile_app/features/menu/widgets/menu_screens_scaffold.dart';
import 'package:bookit_mobile_app/app/theme/app_colors.dart';
import 'package:bookit_mobile_app/app/theme/app_constants.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/shared/components/atoms/secondary_button.dart';
import 'package:bookit_mobile_app/features/menu/application/controllers/business_photo_gallery_controller.dart';
import 'dart:ui';

class BusinessPhotoGalleryScreen extends StatefulWidget {
  const BusinessPhotoGalleryScreen({super.key});

  @override
  State<BusinessPhotoGalleryScreen> createState() => _BusinessPhotoGalleryScreenState();
}

class _BusinessPhotoGalleryScreenState extends State<BusinessPhotoGalleryScreen> {
  late BusinessPhotoGalleryController _controller;
  
  // Delete mode state
  bool isDeleteMode = false;
  String? selectedPhotoForDelete;
  
  @override
  void initState() {
    super.initState();
    _controller = BusinessPhotoGalleryController();
    _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _controller.addPhotoFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _controller.addPhotoFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel),
                title: const Text('Cancel'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        if (_controller.isLoading) {
          return MenuScreenScaffold(
            title: "Photo gallery",
            subtitle: "Showcase your space! Upload a few photos so clients can get a glimpse and feel confident when they book.",
            content: const Center(child: CircularProgressIndicator()),
          );
        }

        final hasPhotos = _controller.photos.any((photo) => photo.hasImage);
        
        return Stack(
          children: [
            MenuScreenScaffold(
              title: "Photo gallery",
              subtitle: "Showcase your space! Upload a few photos so clients can get a glimpse and feel confident when they book.",
              content: hasPhotos ? _buildGalleryContent(theme) : _buildEmptyState(theme),
              buttonText: hasPhotos ? null : "Add Photos",
              onButtonPressed: hasPhotos ? null : _showPhotoOptions,
            ),
        
            // Blur overlay when in delete mode
            if (isDeleteMode)
              GestureDetector(
                onTap: _exitDeleteMode,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.3),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
              
            // Enlarged photo popup when in delete mode
            if (isDeleteMode && selectedPhotoForDelete != null)
              Positioned(
                left: 35,
                top: 454,
                child: Container(
                  width: 198,
                  height: 198,
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: _getSelectedPhoto() != null && _getSelectedPhoto()!.imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            _getSelectedPhoto()!.imageUrl!,
                            fit: BoxFit.cover,
                            width: 198,
                            height: 198,
                          ),
                        )
                      : null,
                ),
              ),
              
            // Delete button below the enlarged photo
            if (isDeleteMode && selectedPhotoForDelete != null)
              Positioned(
                left: 39,
                top: 342,
                child: Container(
                  width: 194,
                  padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
                  decoration: BoxDecoration(
                    color: AppColors.lightGrayBoxColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          "Delete",
                          style: AppTypography.bodyMedium.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _deletePhoto(selectedPhotoForDelete!),
                        child: SvgPicture.asset(
                          'assets/icons/actions/trash_medium.svg',
                          width: 16,
                          height: 16,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
  
  Widget _buildEmptyState(ThemeData theme) {
    return Column(
      children: [
        const Spacer(),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(24),
              ),
              child: SvgPicture.asset(
                'assets/icons/actions/share.svg',
                width: 28,
                height: 28,
              ),
            ),
            
            SizedBox(height: AppConstants.sectionSpacing),
            
            Text(
              "Let's make your profile shine! Your photos will make it pop and look amazing.",
              style: AppTypography.bodyMedium.copyWith(
                color: theme.colorScheme.onSurface,
                height: 1.25,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        const Spacer(),
      ],
    );
  }
  
  Widget _buildGalleryContent(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildAddPhotosButton(),
        SizedBox(height: AppConstants.contentSpacing),
        _buildPhotoGrid(theme),
      ],
    );
  }
  
  Widget _buildAddPhotosButton() {
    return SecondaryButton(
      onPressed: _showPhotoOptions,
      text: "Add photos",
      textWeight: FontWeight.w600,
      prefix: Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.primary,
            width: 1.35,
          ),
        ),
        child: const Icon(
          Icons.add,
          size: 12,
          color: AppColors.primary,
        ),
      ),
    );
  }
  
  Widget _buildPhotoGrid(ThemeData theme) {
    const crossAxisCount = 2;
    const spacing = 27.0;
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: 24.0,
        childAspectRatio: 1.0,
      ),
      itemCount: _controller.photos.length,
      itemBuilder: (context, index) {
        final photo = _controller.photos[index];
        return _buildPhotoItem(photo, theme);
      },
    );
  }
  
  void _enterDeleteMode(String photoId) {
    setState(() {
      isDeleteMode = true;
      selectedPhotoForDelete = photoId;
    });
  }
  
  void _exitDeleteMode() {
    setState(() {
      isDeleteMode = false;
      selectedPhotoForDelete = null;
    });
  }
  
  void _deletePhoto(String photoId) {
    _controller.deletePhoto(photoId);
    setState(() {
      isDeleteMode = false;
      selectedPhotoForDelete = null;
    });
  }
  
  GalleryPhoto? _getSelectedPhoto() {
    if (selectedPhotoForDelete == null) return null;
    return _controller.photos.firstWhere(
      (photo) => photo.id == selectedPhotoForDelete, 
      orElse: () => _controller.photos.first
    );
  }
  
  Widget _buildPhotoItem(GalleryPhoto photo, ThemeData theme) {
    return GestureDetector(
      onLongPress: photo.hasImage && photo.id != null ? () => _enterDeleteMode(photo.id!) : null,
      child: Container(
        decoration: BoxDecoration(
          color: photo.hasImage ? AppColors.secondary2 : AppColors.secondary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: photo.isUploading
            ? const Center(child: CircularProgressIndicator())
            : photo.hasImage && (photo.imageUrl != null || photo.localFile != null)
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: photo.localFile != null
                        ? Image.file(
                            photo.localFile!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          )
                        : Image.network(
                            photo.imageUrl!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: AppColors.secondary2,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              );
                            },
                          ),
                  )
                : InkWell(
                    onTap: _showPhotoOptions,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.add_photo_alternate_outlined,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                  ),
      ),
    );
  }
}