import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Uploads a profile image to Firebase Storage at the path:
  /// `users/{uid}/profile.jpg`
  /// Accepts XFile so it works on ALL platforms (Web, Android, iOS, Desktop).
  /// Uses putData(bytes) which is fully cross-platform.
  /// Returns the public download URL.
  Future<String> uploadProfileImage({
    required String uid,
    required XFile imageFile,
  }) async {
    final bucketName = _storage.app.options.storageBucket;
    try {
      debugPrint('StorageService: --- Starting Profile Image Upload Flow ---');
      debugPrint('StorageService: Selected image path: ${imageFile.path}');
      debugPrint('StorageService: Current user UID: $uid');
      debugPrint('StorageService: Target storage bucket: $bucketName');
      debugPrint('StorageService: Running on Web: $kIsWeb');

      if (uid.trim().isEmpty) {
        debugPrint('StorageService: Error - UID is empty.');
        throw Exception('Invalid user ID: UID cannot be empty.');
      }

      // readAsBytes() works on ALL platforms including Web (blob URLs)
      debugPrint('StorageService: Reading image bytes from XFile...');
      final bytes = await imageFile.readAsBytes();
      debugPrint('StorageService: Image bytes read. Size: ${bytes.length} bytes');

      if (bytes.isEmpty) {
        throw Exception('The selected image file is empty or could not be read.');
      }

      final ref = _storage
          .ref()
          .child('users')
          .child(uid.trim())
          .child('profile.jpg');
      debugPrint('StorageService: Target storage reference path: ${ref.fullPath}');

      final metadata = SettableMetadata(contentType: 'image/jpeg');

      debugPrint('StorageService: Starting upload task via putData (cross-platform)...');

      // putData works on ALL platforms including Web
      final uploadTask = ref.putData(bytes, metadata);

      // Listen to progress events
      final subscription = uploadTask.snapshotEvents.listen(
        (TaskSnapshot snapshot) {
          final bytesTransferred = snapshot.bytesTransferred;
          final totalBytes = snapshot.totalBytes;
          if (totalBytes > 0) {
            final double progress = (bytesTransferred / totalBytes) * 100;
            debugPrint(
              'StorageService: Upload progress for $uid: ${progress.toStringAsFixed(2)}% '
              '($bytesTransferred of $totalBytes bytes)',
            );
          } else {
            debugPrint(
              'StorageService: Upload progress for $uid: $bytesTransferred bytes transferred.',
            );
          }
        },
        onError: (dynamic e) {
          debugPrint('StorageService: Upload stream error: $e');
        },
        cancelOnError: false,
      );

      try {
        debugPrint('StorageService: Awaiting upload task completion...');
        final TaskSnapshot snapshot = await uploadTask;
        debugPrint('StorageService: Upload finished. Final TaskState: ${snapshot.state}');

        if (snapshot.state == TaskState.success) {
          debugPrint('StorageService: Requesting download URL...');
          final downloadUrl = await snapshot.ref.getDownloadURL();
          debugPrint('StorageService: Generated download URL: $downloadUrl');
          return downloadUrl;
        } else {
          debugPrint('StorageService: Upload failed. Task state: ${snapshot.state}');
          throw Exception('Upload failed with state: ${snapshot.state}');
        }
      } finally {
        await subscription.cancel();
      }
    } on FirebaseException catch (e) {
      String userFriendlyMessage;
      switch (e.code) {
        case 'object-not-found':
          userFriendlyMessage =
              'Storage bucket not found. Please ensure Firebase Storage is initialized in the Firebase Console.';
          break;
        case 'unauthorized':
          userFriendlyMessage =
              'Permission denied. Please verify your storage security rules.';
          break;
        case 'quota-exceeded':
          userFriendlyMessage = 'Storage quota exceeded. Please contact support.';
          break;
        case 'canceled':
          userFriendlyMessage = 'Upload was canceled.';
          break;
        case 'unauthenticated':
          userFriendlyMessage = 'User is not authenticated. Please log in again.';
          break;
        case 'invalid-checksum':
          userFriendlyMessage = 'File checksum mismatch. Please try again.';
          break;
        default:
          userFriendlyMessage = e.message ?? 'Unknown storage error occurred.';
      }
      debugPrint(
        'StorageService: FirebaseException (${e.code}): $userFriendlyMessage',
      );
      throw Exception('Failed to upload image: $userFriendlyMessage');
    } catch (e) {
      debugPrint('StorageService: Unexpected error during upload: $e');
      throw Exception('Failed to upload image: $e');
    }
  }
}
