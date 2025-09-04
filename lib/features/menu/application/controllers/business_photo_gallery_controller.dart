import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/api_provider.dart';
import 'package:bookit_mobile_app/core/services/active_business_service.dart';

class GalleryPhoto {
  final String? id;
  final String? imageUrl;
  final File? localFile;
  final bool hasImage;
  final bool isUploading;
  
  GalleryPhoto({
    this.id,
    this.imageUrl,
    this.localFile,
    required this.hasImage,
    this.isUploading = false,
  });

  GalleryPhoto copyWith({
    String? id,
    String? imageUrl,
    File? localFile,
    bool? hasImage,
    bool? isUploading,
  }) {
    return GalleryPhoto(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      localFile: localFile ?? this.localFile,
      hasImage: hasImage ?? this.hasImage,
      isUploading: isUploading ?? this.isUploading,
    );
  }
}

class BusinessPhotoGalleryController extends ChangeNotifier {
  final ImagePicker _imagePicker = ImagePicker();
  final ActiveBusinessService _activeBusinessService = ActiveBusinessService();
  
  List<GalleryPhoto> _photos = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<GalleryPhoto> get photos => _photos;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> initialize() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _fetchGalleryPhotos();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchGalleryPhotos() async {
    try {
      final businessId = await _activeBusinessService.getActiveBusiness();
      if (businessId == null) {
        throw Exception('No active business found');
      }

      final response = await APIRepository.getBusinessGalleryPhotos(businessId.toString());
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == true && data['data'] != null) {
          final List<dynamic> photosData = data['data']['photos'] ?? [];
          
          _photos = photosData.map((photo) => GalleryPhoto(
            id: photo['id']?.toString(),
            imageUrl: photo['image_url'],
            hasImage: true,
          )).toList();
          
          // Add empty slots if needed (up to 8 photos)
          while (_photos.length < 8) {
            _photos.add(GalleryPhoto(hasImage: false));
          }
        } else {
          // Initialize with empty slots
          _photos = List.generate(8, (index) => GalleryPhoto(hasImage: false));
        }
      } else {
        // Initialize with empty slots on error
        _photos = List.generate(8, (index) => GalleryPhoto(hasImage: false));
      }
    } catch (e) {
      // Initialize with empty slots on error
      _photos = List.generate(8, (index) => GalleryPhoto(hasImage: false));
      debugPrint('Error fetching gallery photos: $e');
    }
  }

  Future<void> addPhotoFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1200,
        maxHeight: 1200,
      );
      
      if (image != null) {
        await _uploadPhoto(File(image.path));
      }
    } catch (e) {
      _errorMessage = 'Error selecting photo: $e';
      notifyListeners();
    }
  }

  Future<void> addPhotoFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1200,
        maxHeight: 1200,
      );
      
      if (image != null) {
        await _uploadPhoto(File(image.path));
      }
    } catch (e) {
      _errorMessage = 'Error taking photo: $e';
      notifyListeners();
    }
  }

  Future<void> _uploadPhoto(File imageFile) async {
    // Find first empty slot
    final emptyIndex = _photos.indexWhere((photo) => !photo.hasImage);
    if (emptyIndex == -1) {
      _errorMessage = 'Gallery is full (maximum 8 photos)';
      notifyListeners();
      return;
    }

    // Update UI to show uploading state
    _photos[emptyIndex] = GalleryPhoto(
      localFile: imageFile,
      hasImage: true,
      isUploading: true,
    );
    notifyListeners();

    try {
      final businessId = await _activeBusinessService.getActiveBusiness();
      if (businessId == null) {
        throw Exception('No active business found');
      }

      final response = await APIRepository.uploadBusinessGalleryPhoto(
        businessId: businessId.toString(),
        imageFile: imageFile,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data['status'] == true && data['data'] != null) {
          // Update with server response
          _photos[emptyIndex] = GalleryPhoto(
            id: data['data']['id']?.toString(),
            imageUrl: data['data']['image_url'],
            hasImage: true,
            isUploading: false,
          );
        } else {
          throw Exception('Failed to upload photo');
        }
      } else {
        throw Exception('Upload failed with status: ${response.statusCode}');
      }
    } catch (e) {
      // Revert to empty slot on error
      _photos[emptyIndex] = GalleryPhoto(hasImage: false);
      _errorMessage = 'Upload failed: $e';
    }
    
    notifyListeners();
  }

  Future<void> deletePhoto(String photoId) async {
    final photoIndex = _photos.indexWhere((photo) => photo.id == photoId);
    if (photoIndex == -1) return;

    try {
      final response = await APIRepository.deleteBusinessGalleryPhoto(photoId);
      
      if (response.statusCode == 200) {
        // Replace with empty slot
        _photos[photoIndex] = GalleryPhoto(hasImage: false);
        notifyListeners();
      } else {
        throw Exception('Failed to delete photo');
      }
    } catch (e) {
      _errorMessage = 'Delete failed: $e';
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}