import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:smart_expens/models/user_model.dart';
import 'package:smart_expens/providers/user_provider.dart';

class PersonalDetailsScreen extends StatefulWidget {
  const PersonalDetailsScreen({super.key});

  @override
  State<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _localImageXFile;
  bool _isImageUploading = false;

  Future<void> _pickAndUploadImage(UserProvider userProvider) async {
    if (_isImageUploading) {
      debugPrint('PersonalDetailsScreen: Blocked image picker tap, upload already in progress.');
      return;
    }

    final uid = userProvider.currentUid;
    if (uid == null || uid.trim().isEmpty) {
      debugPrint('PersonalDetailsScreen: Blocked image upload flow. Current user UID is null or empty.');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to upload image: You must be logged in to update your profile picture.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (pickedFile == null) {
        debugPrint('PersonalDetailsScreen: User canceled image selection.');
        return;
      }

      debugPrint('PersonalDetailsScreen: User selected image path: ${pickedFile.path}');
      debugPrint('PersonalDetailsScreen: User UID: $uid');

      // Guard setState after async gap
      if (!mounted) return;
      setState(() {
        _localImageXFile = pickedFile;
        _isImageUploading = true;
      });

      debugPrint('PersonalDetailsScreen: Initiating profile image upload via UserProvider.');
      // Pass XFile directly — works on Web + Mobile + Desktop
      await userProvider.uploadProfileImage(pickedFile);

      debugPrint('PersonalDetailsScreen: Profile image upload completed successfully.');

      if (mounted) {
        setState(() {
          _isImageUploading = false;
          _localImageXFile = null; // Clear local to reload photoURL from userProvider
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('PersonalDetailsScreen: Error occurred during pick and upload flow: $e');
      if (mounted) {
        setState(() {
          _isImageUploading = false;
          _localImageXFile = null;
        });

        final cleanErrorMessage = e.toString()
            .replaceAll('Exception: ', '')
            .replaceAll('Failed to upload image: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload image: $cleanErrorMessage'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final currentUser = userProvider.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Personal Details'),
        centerTitle: true,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Centered Profile Image Section
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.green, width: 2),
                      color: Colors.grey.shade100,
                    ),
                    child: ClipOval(
                      child: _isImageUploading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Colors.green,
                              ),
                            )
                          : _localImageXFile != null
                              ? FutureBuilder<Uint8List>(
                                  future: _localImageXFile!.readAsBytes(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      return Image.memory(
                                        snapshot.data!,
                                        fit: BoxFit.cover,
                                        width: 120,
                                        height: 120,
                                      );
                                    }
                                    return const Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.green,
                                      ),
                                    );
                                  },
                                )
                              : currentUser?.profileImage != null &&
                                      currentUser!.profileImage!.isNotEmpty
                                  ? Image.network(
                                      currentUser.profileImage!,
                                      fit: BoxFit.cover,
                                      width: 120,
                                      height: 120,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return const Center(
                                          child: CircularProgressIndicator(
                                            color: Colors.green,
                                          ),
                                        );
                                      },
                                      errorBuilder: (context, error, stackTrace) =>
                                          const Icon(Icons.person, size: 60, color: Colors.grey),
                                    )
                                  : const Icon(Icons.person, size: 60, color: Colors.grey),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        if (currentUser == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please wait until user data loads.')),
                          );
                          return;
                        }
                        if (_isImageUploading) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Profile picture upload is already in progress.'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }
                        _pickAndUploadImage(userProvider);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _isImageUploading ? Colors.grey : Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          color: _isImageUploading ? Colors.white70 : Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            buildItem(
              'Name',
              currentUser?.name ?? 'Loading...',
              Icons.person,
              onEdit: currentUser != null
                  ? () =>
                        _showEditNameDialog(context, currentUser, userProvider)
                  : null,
            ),
            buildItem(
              'Email',
              currentUser?.email ?? 'Loading...',
              Icons.email,
              onEdit: currentUser != null
                  ? () =>
                        _showEditEmailDialog(context, currentUser, userProvider)
                  : null,
            ),
            buildItem(
              'Password',
              '********',
              Icons.lock,
              onEdit: currentUser != null
                  ? () => _showEditPasswordDialog(context, userProvider)
                  : null,
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (currentUser == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please wait until user data loads.'),
                      ),
                    );
                    return;
                  }
                  if (_isImageUploading) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please wait for the image upload to complete.'),
                      ),
                    );
                    return;
                  }
                  _showEditNameDialog(context, currentUser, userProvider);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // green button
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Edit Name',
                  style: TextStyle(color: Colors.white), // white text
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildItem(
    String title,
    String value,
    IconData icon, {
    VoidCallback? onEdit,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.black,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.black),
              const SizedBox(width: 10),
              Expanded(
                child: Text(value, style: const TextStyle(color: Colors.black)),
              ),
              if (onEdit != null)
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.green),
                  onPressed: onEdit,
                ),
            ],
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  void _showEditNameDialog(
    BuildContext context,
    UserModel currentUser,
    UserProvider userProvider,
  ) {
    final nameController = TextEditingController(text: currentUser.name);

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          scrollable: true,
          title: const Text('Update Name'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newName = nameController.text.trim();
                if (newName.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Name cannot be empty')),
                  );
                  return;
                }
                final navigator = Navigator.of(context);
                final messenger = ScaffoldMessenger.of(context);

                // Wait for image upload to complete if still in progress
                if (_isImageUploading) {
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Waiting for image upload to complete...'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  while (_isImageUploading) {
                    await Future.delayed(const Duration(milliseconds: 100));
                  }
                }

                try {
                  await userProvider.updateProfile(displayName: newName);
                  await userProvider.refreshUserData();
                  if (!mounted) return;
                  navigator.pop();
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Profile updated successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Update failed: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showEditEmailDialog(
    BuildContext context,
    UserModel currentUser,
    UserProvider userProvider,
  ) {
    final emailController = TextEditingController(text: currentUser.email);

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          scrollable: true,
          title: const Text('Update Email'),
          content: SingleChildScrollView(
            child: TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newEmail = emailController.text.trim();
                if (newEmail.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Email cannot be empty')),
                  );
                  return;
                }
                final navigator = Navigator.of(context);
                final messenger = ScaffoldMessenger.of(context);
                try {
                  await userProvider.updateEmail(newEmail);
                  if (!mounted) return;
                  navigator.pop();
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Email updated successfully')),
                  );
                } catch (e) {
                  if (!mounted) return;
                  messenger.showSnackBar(
                    SnackBar(content: Text('Update failed: $e')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showEditPasswordDialog(
    BuildContext context,
    UserProvider userProvider,
  ) {
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          scrollable: true,
          title: const Text('Update Password'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'New Password',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirm Password',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newPassword = passwordController.text.trim();
                final confirmPassword = confirmPasswordController.text.trim();
                if (newPassword.isEmpty || confirmPassword.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill both password fields'),
                    ),
                  );
                  return;
                }
                if (newPassword != confirmPassword) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Passwords do not match')),
                  );
                  return;
                }
                final navigator = Navigator.of(context);
                final messenger = ScaffoldMessenger.of(context);
                try {
                  await userProvider.updatePassword(newPassword);
                  if (!mounted) return;
                  navigator.pop();
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Password updated successfully'),
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;
                  messenger.showSnackBar(
                    SnackBar(content: Text('Update failed: $e')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
