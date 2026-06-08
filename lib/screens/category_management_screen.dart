import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:smart_expens/models/category_model.dart';
import 'package:smart_expens/providers/category_provider.dart';
import 'package:smart_expens/services/category_service.dart';
import 'package:smart_expens/core/errors/app_exception.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() =>
      _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  final _categoryService = CategoryService();
  final _auth = FirebaseAuth.instance;
  final _nameController = TextEditingController();
  String? _editingCategoryId;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String get _uid => _auth.currentUser?.uid ?? '';

  /// Show add/edit category dialog
  void _showCategoryDialog({CategoryModel? category}) {
    _nameController.text = category?.name ?? '';
    _editingCategoryId = category?.id;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(category == null ? 'Add Category' : 'Edit Category'),
        content: TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            hintText: 'Category name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = _nameController.text.trim();
              if (name.isEmpty) {
                Navigator.pop(dialogContext);
                _showSnackBar('Category name cannot be empty');
                return;
              }
              Navigator.pop(dialogContext);
              _saveCategoryCategory(name, category);
            },
            child: Text(category == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  /// Save new or updated category
  void _saveCategoryCategory(
    String name,
    CategoryModel? existingCategory,
  ) async {
    try {
      if (existingCategory == null) {
        // Add new category
        await _categoryService.addUserCategory(uid: _uid, name: name);
        if (mounted) {
          _showSnackBar(' Category added');
        }
      } else {
        // Update existing category
        await _categoryService.updateUserCategory(
          uid: _uid,
          categoryId: existingCategory.id,
          newName: name,
        );
        if (mounted) {
          _showSnackBar(' Category updated');
        }
      }
    } on AppException catch (e) {
      if (mounted) {
        _showSnackBar(' ${e.message}');
      }
    }
  }

  /// Delete category with confirmation
  void _deleteCategory(CategoryModel category) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Category?'),
        content: Text('Are you sure you want to delete "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await _categoryService.deleteUserCategory(
                  uid: _uid,
                  categoryId: category.id,
                );
                if (mounted) {
                  _showSnackBar(' Category deleted');
                }
              } on AppException catch (e) {
                if (mounted) {
                  _showSnackBar(' ${e.message}');
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// Show snackbar safely
  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Categories'),
        backgroundColor: const Color(0xff0A6C3F),
      ),
      body: Consumer<CategoryProvider>(
        builder: (context, categoryProvider, _) {
          if (categoryProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (categoryProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    'Error: ${categoryProvider.errorMessage}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
            );
          }

          final categories = categoryProvider.categories;

          if (categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.inbox_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'No categories yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => _showCategoryDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text('Add First Category'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff0A6C3F),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(
                    category.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text('ID: ${category.id}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Edit button
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () =>
                            _showCategoryDialog(category: category),
                        tooltip: 'Edit category',
                      ),
                      // Delete button
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteCategory(category),
                        tooltip: 'Delete category',
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryDialog(),
        backgroundColor: const Color(0xff0A6C3F),
        child: const Icon(Icons.add),
      ),
    );
  }
}
