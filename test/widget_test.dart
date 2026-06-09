import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:smart_expens/models/category_model.dart';
import 'package:smart_expens/providers/category_provider.dart';
import 'package:smart_expens/screens/category_management_screen.dart';

class FakeCategoryProvider extends ChangeNotifier implements CategoryProvider {
  final List<CategoryModel> _fakeCategories;
  final bool _fakeLoading;
  final String? _fakeError;

  FakeCategoryProvider({
    List<CategoryModel> categories = const [],
    bool isLoading = false,
    String? errorMessage,
  })  : _fakeCategories = categories,
        _fakeLoading = isLoading,
        _fakeError = errorMessage;

  @override
  List<CategoryModel> get categories => _fakeCategories;

  @override
  bool get isLoading => _fakeLoading;

  @override
  String? get errorMessage => _fakeError;

  @override
  void startListening(String uid) {}

  @override
  void stopListening() {}
}

void main() {
  testWidgets('CategoryManagementScreen shows header, categories, and no add button', (WidgetTester tester) async {
    final categories = [
      const CategoryModel(id: 'food', name: 'Food & Dining'),
      const CategoryModel(id: 'transport', name: 'Transportation'),
      const CategoryModel(id: 'shopping', name: 'Shopping'),
    ];

    final fakeProvider = FakeCategoryProvider(
      categories: categories,
      isLoading: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<CategoryProvider>.value(
          value: fakeProvider,
          child: const CategoryManagementScreen(),
        ),
      ),
    );

    // Verify header title is present
    expect(find.text('Category Management'), findsOneWidget);
    // Verify "Current Categories" section title is present
    expect(find.text('Current Categories'), findsOneWidget);

    // Verify custom category chips are displayed
    expect(find.text('Food & Dining'), findsOneWidget);
    expect(find.text('Transportation'), findsOneWidget);
    expect(find.text('Shopping'), findsOneWidget);

    // Verify there is NO floating action button, no "add" icon or buttons
    expect(find.byType(FloatingActionButton), findsNothing);
    expect(find.text('Add Category'), findsNothing);
    expect(find.text('Add First Category'), findsNothing);
  });
}
