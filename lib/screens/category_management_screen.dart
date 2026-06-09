import 'package:flutter/material.dart';
import 'package:smart_expens/models/category_model.dart';

class CategoryManagementScreen extends StatelessWidget {
  const CategoryManagementScreen({super.key});

  Color _getCategoryColor(String id) {
    final lower = id.toLowerCase().trim();
    if (lower == 'food') {
      return const Color(0xFF1B873F); // Green (Food & Dining)
    } else if (lower == 'transport') {
      return const Color(0xFF2A75E6); // Blue (Transportation)
    } else if (lower == 'entertainment') {
      return const Color(0xFF9C27B0); // Purple (Entertainment)
    } else if (lower == 'shopping') {
      return const Color(0xFFFD8A36); // Orange (Shopping)
    } else if (lower == 'health') {
      return const Color(0xFFD32F2F); // Red (Healthcare)
    } else if (lower == 'bills') {
      return const Color(0xFF673AB7); // Deep Purple
    } else if (lower == 'drink') {
      return const Color(0xFFE91E63); // Pink
    }
    return const Color(0xFF115E38); // Fallback Green
  }

  String _getCategoryDisplayName(CategoryModel category) {
    final lower = category.id.toLowerCase();
    if (lower == 'food') {
      return 'Food & Dining';
    } else if (lower == 'transport') {
      return 'Transportation';
    } else if (lower == 'health') {
      return 'Healthcare';
    }
    return category.name;
  }

  @override
  Widget build(BuildContext context) {
    // The 7 predefined system categories
    final categories = CategoryModel.predefined;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Custom Header Row matching the UI
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Category Management',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Section Title
              const Text(
                'Current Categories',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),

              // Categories Display
              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 12,
                    children: categories.map((category) {
                      return Container(
                        decoration: BoxDecoration(
                          color: _getCategoryColor(category.id),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _getCategoryDisplayName(category),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
