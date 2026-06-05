import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:smart_expens/core/constants/app_constants.dart';
import 'package:smart_expens/core/errors/app_exception.dart';
import 'package:smart_expens/models/category_model.dart';

/// Handles Firestore operations for the predefined category collection.
///
/// **Important:** categories are statically defined in [CategoryModel.predefined].
/// Firestore is used only as a remote source of truth (e.g. future server-driven
/// changes). The [addAllCategories] method is intentionally NOT called at app
/// startup because it requires an authenticated user per the security rules.
///
/// Call [addAllCategories] from a trusted admin flow or a Cloud Function instead.
class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ─── Private helpers ───────────────────────────────────────────────────────

  AppException _mapFirebase(FirebaseException e, String op) {
    debugPrint('🔥 CategoryService[$op] code=${e.code} msg=${e.message}');
    final code = AppException.codeFromFirestore(e.code);
    return AppException(
      message: AppException.messageFor(code),
      code: code,
      cause: e,
    );
  }

  // ─── Write ────────────────────────────────────────────────────────────────

  /// Seeds all predefined categories into Firestore using a batch write.
  ///
  /// ⚠️ Requires an authenticated user — do NOT call from [main()].
  /// Safe to call multiple times; existing documents are merged (not replaced).
  Future<void> addAllCategories() async {
    try {
      final batch = _firestore.batch();
      for (final cat in CategoryModel.predefined) {
        final ref = _firestore
            .collection(AppConstants.categoriesCollection)
            .doc(cat.id);
        batch.set(ref, cat.toMap(), SetOptions(merge: true));
      }
      await batch.commit();
      debugPrint(
        '✅ CategoryService: seeded ${CategoryModel.predefined.length} '
        'categories.',
      );
    } on FirebaseException catch (e) {
      throw _mapFirebase(e, 'addAllCategories');
    } catch (e) {
      debugPrint('💥 CategoryService.addAllCategories unexpected: $e');
      throw AppException(
        message: AppException.messageFor(AppErrorCode.unknown),
        code: AppErrorCode.unknown,
        cause: e,
      );
    }
  }

  // ─── Read ─────────────────────────────────────────────────────────────────

  /// One-time fetch of all categories from Firestore.
  ///
  /// Falls back to [CategoryModel.predefined] if the collection is empty,
  /// so the app always has categories available.
  Future<List<CategoryModel>> getAllCategories() async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.categoriesCollection)
          .get();

      if (snapshot.docs.isEmpty) {
        debugPrint(
          '⚠️  CategoryService.getAllCategories: collection empty, '
          'returning predefined list.',
        );
        return CategoryModel.predefined;
      }

      return snapshot.docs.map((d) => CategoryModel.fromMap(d.data())).toList();
    } on FirebaseException catch (e) {
      throw _mapFirebase(e, 'getAllCategories');
    } catch (e) {
      debugPrint('💥 CategoryService.getAllCategories unexpected: $e');
      throw AppException(
        message: AppException.messageFor(AppErrorCode.unknown),
        code: AppErrorCode.unknown,
        cause: e,
      );
    }
  }

  /// Fetches a single category by [categoryId]. Returns `null` if not found.
  Future<CategoryModel?> getCategoryById(String categoryId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.categoriesCollection)
          .doc(categoryId)
          .get();

      if (!doc.exists) {
        // Fallback: look up in local predefined list.
        return CategoryModel.predefined.cast<CategoryModel?>().firstWhere(
          (c) => c?.id == categoryId,
          orElse: () => null,
        );
      }

      return CategoryModel.fromMap(doc.data()!);
    } on FirebaseException catch (e) {
      throw _mapFirebase(e, 'getCategoryById');
    } catch (e) {
      debugPrint('💥 CategoryService.getCategoryById unexpected: $e');
      throw AppException(
        message: AppException.messageFor(AppErrorCode.unknown),
        code: AppErrorCode.unknown,
        cause: e,
      );
    }
  }

  /// Real-time stream of all categories, ordered by document ID.
  Stream<List<CategoryModel>> categoriesStream() {
    return _firestore
        .collection(AppConstants.categoriesCollection)
        .orderBy(FieldPath.documentId)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => CategoryModel.fromMap(d.data())).toList(),
        );
  }

  /// Stream of user's custom categories: users/{uid}/categories
  Stream<List<CategoryModel>> getUserCategoriesStream(String uid) {
    return _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .collection('categories')
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => CategoryModel.fromMap(d.data())).toList(),
        );
  }

  // ─── User Category Management ──────────────────────────────────────────────

  /// Add a new custom category for user [uid]
  Future<String> addUserCategory({
    required String uid,
    required String name,
  }) async {
    try {
      debugPrint('📝 CategoryService.addUserCategory → uid=$uid name=$name');
      final categoryId = _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .collection('categories')
          .doc()
          .id;

      final category = CategoryModel(id: categoryId, name: name);

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .collection('categories')
          .doc(categoryId)
          .set(category.toMap());

      debugPrint('✅ CategoryService.addUserCategory done → id=$categoryId');
      return categoryId;
    } on FirebaseException catch (e) {
      throw _mapFirebase(e, 'addUserCategory');
    } catch (e) {
      debugPrint('💥 CategoryService.addUserCategory unexpected: $e');
      throw AppException(
        message: AppException.messageFor(AppErrorCode.unknown),
        code: AppErrorCode.unknown,
        cause: e,
      );
    }
  }

  /// Update an existing custom category for user [uid]
  Future<void> updateUserCategory({
    required String uid,
    required String categoryId,
    required String newName,
  }) async {
    try {
      debugPrint(
        '✏️ CategoryService.updateUserCategory → uid=$uid id=$categoryId name=$newName',
      );
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .collection('categories')
          .doc(categoryId)
          .update({'name': newName});

      debugPrint('✅ CategoryService.updateUserCategory done → id=$categoryId');
    } on FirebaseException catch (e) {
      throw _mapFirebase(e, 'updateUserCategory');
    } catch (e) {
      debugPrint('💥 CategoryService.updateUserCategory unexpected: $e');
      throw AppException(
        message: AppException.messageFor(AppErrorCode.unknown),
        code: AppErrorCode.unknown,
        cause: e,
      );
    }
  }

  /// Delete a custom category for user [uid]
  Future<void> deleteUserCategory({
    required String uid,
    required String categoryId,
  }) async {
    try {
      debugPrint(
        '🗑️ CategoryService.deleteUserCategory → uid=$uid id=$categoryId',
      );
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .collection('categories')
          .doc(categoryId)
          .delete();

      debugPrint('✅ CategoryService.deleteUserCategory done → id=$categoryId');
    } on FirebaseException catch (e) {
      throw _mapFirebase(e, 'deleteUserCategory');
    } catch (e) {
      debugPrint('💥 CategoryService.deleteUserCategory unexpected: $e');
      throw AppException(
        message: AppException.messageFor(AppErrorCode.unknown),
        code: AppErrorCode.unknown,
        cause: e,
      );
    }

