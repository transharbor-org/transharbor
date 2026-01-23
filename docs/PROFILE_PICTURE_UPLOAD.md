# Profile Picture Upload Feature

## Overview
Users can now upload and update their profile pictures directly from the Profile screen. The feature integrates with PocketBase's file storage system.

## Implementation Details

### User Model Updates
- Added `avatar` field to store the filename of the uploaded profile picture
- Updated `fromJson`, `fromPocketBase`, and `toJson` methods to handle avatar field

### PocketBase Service Methods
- `updateUserProfile()` - Update user profile fields (displayName, bio, pronouns)
- `uploadUserAvatar(String filePath)` - Upload profile picture file
- `getAvatarUrl(String userId, String? avatarFilename)` - Get the full URL for avatar display

### Profile Screen
The Profile screen now includes:
- **Avatar Display**: Shows profile picture if available, otherwise displays default icon
- **Camera Button**: Floating button overlaying the avatar to trigger image picker
- **Image Picker**: Uses `image_picker` package with the following constraints:
  - Max dimensions: 512x512 pixels
  - Image quality: 85%
  - Source: Gallery only (can be extended to include camera)
- **Loading State**: Displays progress indicator while uploading
- **User Feedback**: Shows success/error messages via SnackBar

### AuthProvider Updates
- Added `refreshUser()` method to reload user data after avatar upload
- Ensures the UI updates immediately after successful upload

## Dependencies Added
- `image_picker: ^1.0.7` - For selecting images from device
- `http: ^1.2.0` - For MultipartFile support in PocketBase uploads

## PocketBase Schema
The `avatar` field in the users collection is configured as:
- Type: `file`
- Max size: 5MB
- Allowed formats: JPEG, PNG, GIF, WebP
- Thumbnails: 100x100, 300x300

## Usage Flow
1. User navigates to Profile screen
2. Taps camera icon button on avatar
3. Selects image from gallery
4. Image is automatically resized and uploaded
5. User data is refreshed
6. Avatar displays the new profile picture

## Future Enhancements
- Allow camera capture in addition to gallery selection
- Image cropping before upload
- Avatar removal option
- Different avatar sizes for different contexts
- Avatar preview before upload

## Testing Considerations
- Test with various image sizes and formats
- Test network error handling
- Test with no gallery permissions
- Verify avatar persists across app restarts
- Check avatar display in all user contexts (posts, comments, etc.)
