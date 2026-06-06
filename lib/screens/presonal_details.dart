import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_expens/models/user_model.dart';
import 'package:smart_expens/providers/user_provider.dart';

class PersonalDetailsScreen extends StatefulWidget {
  const PersonalDetailsScreen({super.key});

  @override
  State<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final currentUser = userProvider.currentUser;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Personal Details'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
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
                  _showEditNameDialog(context, currentUser, userProvider);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // زرار أخضر
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Edit Name',
                  style: TextStyle(color: Colors.white), // الكلام أبيض
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
            color: Colors.white, // خلفية غامقة عشان الأبيض يبان
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.black, // الحواف سوداء
              width: 1.5, // سمك البوردر (تقدر تزوده أو تقلله)
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
                try {
                  await userProvider.updateProfile(displayName: newName);
                  if (!mounted) return;
                  navigator.pop();
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Profile updated successfully'),
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
