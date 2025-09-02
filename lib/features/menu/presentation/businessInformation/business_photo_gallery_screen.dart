import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:bookit_mobile_app/features/menu/widgets/menu_screens_scaffold.dart';
import 'package:bookit_mobile_app/app/theme/app_colors.dart';
import 'package:bookit_mobile_app/app/theme/app_constants.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/shared/components/atoms/secondary_button.dart';
import 'dart:ui';

class GalleryPhoto {
  final String id;
  final String? imageUrl;
  final bool hasImage;
  
  GalleryPhoto({required this.id, this.imageUrl, required this.hasImage});
}

class BusinessPhotoGalleryScreen extends StatefulWidget {
  const BusinessPhotoGalleryScreen({super.key});

  @override
  State<BusinessPhotoGalleryScreen> createState() => _BusinessPhotoGalleryScreenState();
}

class _BusinessPhotoGalleryScreenState extends State<BusinessPhotoGalleryScreen> {
  // Dummy data - can be toggled between empty and with photos
  List<GalleryPhoto> photos = [];
  
  // Toggle between empty and populated state for demo
  bool showDemoPhotos = true;
  
  // Delete mode state
  bool isDeleteMode = false;
  String? selectedPhotoForDelete;
  
  @override
  void initState() {
    super.initState();
    _initializePhotos();
  }
  
  void _initializePhotos() {
    if (showDemoPhotos) {
      photos = [
        GalleryPhoto(id: '1', hasImage: true, imageUrl: 'https://picsum.photos/148/148?random=1'),
        GalleryPhoto(id: '2', hasImage: false),
        GalleryPhoto(id: '3', hasImage: false),
        GalleryPhoto(id: '4', hasImage: false),
        GalleryPhoto(id: '5', hasImage: false),
        GalleryPhoto(id: '6', hasImage: false),
        GalleryPhoto(id: '7', hasImage: false),
        GalleryPhoto(id: '8', hasImage: false),
      ];
    } else {
      photos = [];
    }
  }
  
  void _toggleDemoState() {
    setState(() {
      showDemoPhotos = !showDemoPhotos;
      _initializePhotos();
    });
  }
  
  void _addPhoto() {
    // Simulate adding a photo
    setState(() {
      if (photos.isEmpty) {
        // Add initial photos structure
        photos = List.generate(8, (index) => 
          GalleryPhoto(id: '${index + 1}', hasImage: index == 0));
      } else {
        // Find first empty slot and add image
        final emptyIndex = photos.indexWhere((photo) => !photo.hasImage);
        if (emptyIndex != -1) {
          photos[emptyIndex] = GalleryPhoto(
            id: photos[emptyIndex].id, 
            hasImage: true, 
            imageUrl: 'https://picsum.photos/148/148?random=${emptyIndex + 2}'
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasPhotos = photos.isNotEmpty;
    
    return Stack(
      children: [
        MenuScreenScaffold(
          title: "Photo gallery",
          subtitle: "Showcase your space! Upload a few photos so clients can get a glimpse and feel confident when they book.",
          content: hasPhotos ? _buildGalleryContent(theme) : _buildEmptyState(theme),
          buttonText: "Toggle Demo State", // For demo purposes
          onButtonPressed: _toggleDemoState,
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
  }
  
  Widget _buildEmptyState(ThemeData theme) {
    return Column(
      children: [
        const Spacer(),
        // Center content matching Figma empty state
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Share icon - using purple color from Figma
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
            
            SizedBox(height: AppConstants.sectionSpacing), // 24px gap from Figma
            
            // Message text
            Text(
              "Let's make your profile shine! Your photos will make it pop and look amazing.",
              style: AppTypography.bodyMedium.copyWith(
                color: theme.colorScheme.onSurface,
                height: 1.25, // Line height from Figma
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
        // Add photos button
        _buildAddPhotosButton(),
        
        SizedBox(height: AppConstants.contentSpacing), // 16px gap from Figma
        
        // Photo grid
        _buildPhotoGrid(theme),
      ],
    );
  }
  
  Widget _buildAddPhotosButton() {
    return SecondaryButton(
        onPressed: _addPhoto,
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
    const spacing = 27.0; // 175px - 148px = 27px from Figma calculations
    // Photo size is 148px from Figma design
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: 24.0, // 172px vertical spacing from Figma
        childAspectRatio: 1.0,
      ),
      itemCount: photos.length,
      itemBuilder: (context, index) {
        final photo = photos[index];
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
    setState(() {
      final index = photos.indexWhere((photo) => photo.id == photoId);
      if (index != -1) {
        photos[index] = GalleryPhoto(id: photoId, hasImage: false);
      }
      isDeleteMode = false;
      selectedPhotoForDelete = null;
    });
  }
  
  GalleryPhoto? _getSelectedPhoto() {
    if (selectedPhotoForDelete == null) return null;
    return photos.firstWhere((photo) => photo.id == selectedPhotoForDelete, orElse: () => photos.first);
  }
  
  Widget _buildPhotoItem(GalleryPhoto photo, ThemeData theme) {
    return GestureDetector(
      onLongPress: photo.hasImage ? () => _enterDeleteMode(photo.id) : null,
      child: Container(
        decoration: BoxDecoration(
          color: photo.hasImage ? AppColors.secondary2 : AppColors.secondary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: photo.hasImage && photo.imageUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
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
                onTap: _addPhoto,
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