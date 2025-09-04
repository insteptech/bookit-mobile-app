# Image Upload Backend Implementation Guide

This document outlines the backend implementation requirements for handling image uploads from the mobile app using Express.js and AWS S3.

## Overview

The mobile app now sends images along with form data using `multipart/form-data` for three main features:
1. **Staff Profile Images** - Profile photos for staff/coaches
2. **Class Images** - Images for fitness classes
3. **Business Gallery Photos** - Gallery photos for business profiles

## Prerequisites

- Express.js server
- AWS S3 bucket configured
- Multer middleware for handling multipart/form-data
- AWS SDK for S3 operations

## Required Dependencies

```bash
npm install multer multer-s3 aws-sdk uuid
```

## S3 Configuration

```javascript
const AWS = require('aws-sdk');
const multer = require('multer');
const multerS3 = require('multer-s3');
const { v4: uuidv4 } = require('uuid');

// Configure AWS
AWS.config.update({
  accessKeyId: process.env.AWS_ACCESS_KEY_ID,
  secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
  region: process.env.AWS_REGION
});

const s3 = new AWS.S3();

// Multer S3 configuration
const upload = multer({
  storage: multerS3({
    s3: s3,
    bucket: process.env.S3_BUCKET_NAME,
    acl: 'public-read',
    key: function (req, file, cb) {
      const uniqueName = `${Date.now()}_${uuidv4()}_${file.originalname}`;
      cb(null, `${file.fieldname}/${uniqueName}`);
    }
  }),
  limits: {
    fileSize: 10 * 1024 * 1024, // 10MB limit
  },
  fileFilter: (req, file, cb) => {
    // Accept only image files
    if (file.mimetype.startsWith('image/')) {
      cb(null, true);
    } else {
      cb(new Error('Only image files are allowed!'), false);
    }
  }
});
```

## API Endpoints Implementation

### 1. Staff Profile with Image

#### Endpoint: `POST /profile/staff/add`

**Description:** Creates staff profile with optional profile image

**Request Format:**
- Content-Type: `multipart/form-data`
- Fields: `staffProfiles` (JSON string)
- Files: `profile_image_0`, `profile_image_1`, etc.

```javascript
app.post('/profile/staff/add', 
  upload.array('profile_image', 10), // Allow up to 10 profile images
  async (req, res) => {
    try {
      // Parse staff profiles data
      const staffProfiles = JSON.parse(req.body.staffProfiles);
      
      // Map uploaded files to staff profiles
      const filesMap = {};
      req.files.forEach(file => {
        const index = file.fieldname.split('_').pop(); // Extract index from profile_image_0
        filesMap[index] = {
          url: file.location,
          key: file.key
        };
      });
      
      // Process each staff profile
      const results = [];
      for (let i = 0; i < staffProfiles.length; i++) {
        const profile = staffProfiles[i];
        
        // Add profile image URL if uploaded
        if (filesMap[i]) {
          profile.profile_photo_url = filesMap[i].url;
          profile.profile_photo_key = filesMap[i].key; // Store S3 key for deletion
        }
        
        // Save to database
        const savedProfile = await saveStaffProfile(profile);
        results.push(savedProfile);
      }
      
      res.status(201).json({
        status: true,
        message: 'Staff profiles created successfully',
        data: results
      });
      
    } catch (error) {
      console.error('Error creating staff profiles:', error);
      res.status(500).json({
        status: false,
        message: 'Failed to create staff profiles',
        error: error.message
      });
    }
  }
);
```

### 2. Staff with Schedule and Image

#### Endpoint: `POST /profile/staff/add-with-schedule`

**Description:** Creates staff profile with schedule and optional profile image

**Request Format:**
- Content-Type: `multipart/form-data`
- Fields: All staff and schedule data as form fields
- Files: `profile_image`

```javascript
app.post('/profile/staff/add-with-schedule',
  upload.single('profile_image'),
  async (req, res) => {
    try {
      // Extract form data
      const staffData = {
        name: req.body.name,
        email: req.body.email,
        phone_number: req.body.phone_number,
        gender: req.body.gender,
        category_id: JSON.parse(req.body.category_id),
        location_id: JSON.parse(req.body.location_id),
        for_class: req.body.for_class === 'true',
        business_id: req.body.business_id,
      };
      
      // Add profile image if uploaded
      if (req.file) {
        staffData.profile_photo_url = req.file.location;
        staffData.profile_photo_key = req.file.key;
      }
      
      // Parse schedule data
      const schedules = JSON.parse(req.body.schedules);
      
      // Save staff with schedule
      const result = await saveStaffWithSchedule(staffData, schedules);
      
      res.status(201).json({
        status: true,
        message: 'Staff and schedule created successfully',
        data: result
      });
      
    } catch (error) {
      console.error('Error creating staff with schedule:', error);
      res.status(500).json({
        status: false,
        message: 'Failed to create staff with schedule',
        error: error.message
      });
    }
  }
);
```

### 3. Class with Image

#### Endpoint: `POST /classes/with-schedule`

**Description:** Creates class with schedule and optional class image

**Request Format:**
- Content-Type: `multipart/form-data`
- Fields: `payload` (JSON string)
- Files: `class_image`

```javascript
app.post('/classes/with-schedule',
  upload.single('class_image'),
  async (req, res) => {
    try {
      // Parse class data
      const payload = JSON.parse(req.body.payload);
      
      // Add class image if uploaded
      if (req.file) {
        // Add image to service_detail
        payload[0].service_detail.media_url = req.file.location;
        payload[0].service_detail.media_key = req.file.key;
      }
      
      // Save class and schedule
      const result = await saveClassAndSchedule(payload[0]);
      
      res.status(201).json({
        status: true,
        message: 'Class created successfully',
        data: result
      });
      
    } catch (error) {
      console.error('Error creating class:', error);
      res.status(500).json({
        status: false,
        message: 'Failed to create class',
        error: error.message
      });
    }
  }
);
```

### 4. Business Gallery Photos

#### Get Gallery Photos: `GET /business/:businessId/gallery`

```javascript
app.get('/business/:businessId/gallery', async (req, res) => {
  try {
    const { businessId } = req.params;
    
    // Fetch photos from database
    const photos = await getBusinessGalleryPhotos(businessId);
    
    res.json({
      status: true,
      message: 'Gallery photos fetched successfully',
      data: {
        photos: photos
      }
    });
    
  } catch (error) {
    console.error('Error fetching gallery photos:', error);
    res.status(500).json({
      status: false,
      message: 'Failed to fetch gallery photos',
      error: error.message
    });
  }
});
```

#### Upload Gallery Photo: `POST /business/gallery/upload`

```javascript
app.post('/business/gallery/upload',
  upload.single('image'),
  async (req, res) => {
    try {
      const { business_id } = req.body;
      
      if (!req.file) {
        return res.status(400).json({
          status: false,
          message: 'No image file provided'
        });
      }
      
      // Save photo record to database
      const photoRecord = {
        business_id: business_id,
        image_url: req.file.location,
        image_key: req.file.key,
        uploaded_at: new Date()
      };
      
      const savedPhoto = await saveGalleryPhoto(photoRecord);
      
      res.status(201).json({
        status: true,
        message: 'Photo uploaded successfully',
        data: savedPhoto
      });
      
    } catch (error) {
      console.error('Error uploading gallery photo:', error);
      res.status(500).json({
        status: false,
        message: 'Failed to upload photo',
        error: error.message
      });
    }
  }
);
```

#### Delete Gallery Photo: `DELETE /business/gallery/:photoId`

```javascript
app.delete('/business/gallery/:photoId', async (req, res) => {
  try {
    const { photoId } = req.params;
    
    // Get photo record from database
    const photo = await getGalleryPhotoById(photoId);
    
    if (!photo) {
      return res.status(404).json({
        status: false,
        message: 'Photo not found'
      });
    }
    
    // Delete from S3
    if (photo.image_key) {
      await s3.deleteObject({
        Bucket: process.env.S3_BUCKET_NAME,
        Key: photo.image_key
      }).promise();
    }
    
    // Delete from database
    await deleteGalleryPhoto(photoId);
    
    res.json({
      status: true,
      message: 'Photo deleted successfully'
    });
    
  } catch (error) {
    console.error('Error deleting gallery photo:', error);
    res.status(500).json({
      status: false,
      message: 'Failed to delete photo',
      error: error.message
    });
  }
});
```

## Database Schema Updates

### Staff Table
```sql
ALTER TABLE staff ADD COLUMN profile_photo_url VARCHAR(500);
ALTER TABLE staff ADD COLUMN profile_photo_key VARCHAR(200);
```

### Classes/Services Table
```sql
ALTER TABLE classes ADD COLUMN media_url VARCHAR(500);
ALTER TABLE classes ADD COLUMN media_key VARCHAR(200);
```

### Business Gallery Table
```sql
CREATE TABLE business_gallery (
  id INT PRIMARY KEY AUTO_INCREMENT,
  business_id INT NOT NULL,
  image_url VARCHAR(500) NOT NULL,
  image_key VARCHAR(200) NOT NULL,
  uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (business_id) REFERENCES businesses(id)
);
```

## Error Handling

```javascript
// Global error handler for multer errors
app.use((error, req, res, next) => {
  if (error instanceof multer.MulterError) {
    if (error.code === 'LIMIT_FILE_SIZE') {
      return res.status(400).json({
        status: false,
        message: 'File too large. Maximum size is 10MB.'
      });
    }
    if (error.code === 'LIMIT_FILE_COUNT') {
      return res.status(400).json({
        status: false,
        message: 'Too many files. Maximum allowed is 10.'
      });
    }
  }
  
  res.status(500).json({
    status: false,
    message: 'Internal server error',
    error: error.message
  });
});
```

## Environment Variables

```bash
# AWS Configuration
AWS_ACCESS_KEY_ID=your_access_key
AWS_SECRET_ACCESS_KEY=your_secret_key
AWS_REGION=us-east-1
S3_BUCKET_NAME=your-bucket-name

# File Upload Limits
MAX_FILE_SIZE=10485760  # 10MB in bytes
MAX_FILES=10
```

## Security Considerations

1. **File Type Validation:** Only allow image files (JPEG, PNG, GIF)
2. **File Size Limits:** Implement reasonable file size limits (10MB recommended)
3. **Authentication:** Ensure all endpoints require proper authentication
4. **Rate Limiting:** Implement rate limiting for upload endpoints
5. **Virus Scanning:** Consider adding virus scanning for uploaded files
6. **CORS:** Configure CORS properly for mobile app requests

## Testing

Use tools like Postman to test the endpoints:

1. Set Content-Type to `multipart/form-data`
2. Add form fields as specified
3. Add file attachments with correct field names
4. Include proper authentication headers

## Mobile App Integration

The mobile app sends requests in this format:

```javascript
// FormData structure
const formData = new FormData();
formData.append('staffProfiles', JSON.stringify(profilesData));
formData.append('profile_image_0', imageFile, 'profile.jpg');
```

This documentation should provide your backend team with everything needed to implement the image upload functionality to work seamlessly with the mobile app.