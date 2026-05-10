/// Represents a single expense category stored in Firestore.
///
/// Firestore path: categories/{id}
class CategoryModel {
  /// The Firestore document ID (e.g. "food", "bills").
  final String id;

  /// Human-readable display name (e.g. "Food", "Bills").
  final String name;

  /// Asset path or URL of the category icon/image.

  const CategoryModel({required this.id, required this.name});

  // ─── Serialisation ────────────────────────────────────────────────────────

  /// Converts this model to a [Map] suitable for Firestore writes.
  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name};
  }

  /// Creates a [CategoryModel] from a Firestore document [map].
  ///
  /// Falls back to empty strings if a field is missing, so no null-safety
  /// issues arise when reading legacy documents.
  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: (map['id'] as String?) ?? '',
      name: (map['name'] as String?) ?? '',
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  /// Returns a copy of this model with the given fields replaced.
  CategoryModel copyWith({String? id, String? name, String? image}) {
    return CategoryModel(id: id ?? this.id, name: name ?? this.name);
  }

  @override
  String toString() => 'CategoryModel(id: $id, name: $name)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryModel && other.id == id && other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;

  // ─── Predefined categories ────────────────────────────────────────────────

  /// The complete, ordered list of application categories.
  ///
  /// The [image] field stores the asset path used throughout the app.
  /// If you switch to network images, update these paths accordingly.
  static const List<CategoryModel> predefined = [
    CategoryModel(id: 'bills', name: 'Bills'),
    CategoryModel(id: 'drink', name: 'Drink'),
    CategoryModel(id: 'entertainment', name: 'Entertainment'),
    CategoryModel(id: 'food', name: 'Food'),
    CategoryModel(id: 'health', name: 'Health'),
    CategoryModel(id: 'shopping', name: 'Shopping'),
    CategoryModel(id: 'transport', name: 'Transport'),
  ];
}
