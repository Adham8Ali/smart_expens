import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a single expense document stored in Firestore.
///
/// Firestore path: users/{uid}/expenses/{expenseId}
class ExpenseModel {
  /// Auto-generated Firestore document ID. Empty string before first save.
  final String id;

  /// UID of the owning user.
  final String uid;

  /// Amount in the user's local currency.
  final double amount;

  /// References a document ID in the top-level [categories] collection.
  final String categoryId;

  /// Date the expense was incurred (time component ignored in UI).
  final DateTime date;

  /// Optional free-text note.
  final String? note;

  /// Server-side creation timestamp (set by Firestore on first write).
  final DateTime createdAt;

  const ExpenseModel({
    required this.id,
    required this.uid,
    required this.amount,
    required this.categoryId,
    required this.date,
    this.note,
    required this.createdAt,
  });

  // ─── Serialisation ────────────────────────────────────────────────────────

  /// Converts this model to a [Map] for Firestore writes.
  ///
  /// [date] and [createdAt] are stored as Firestore [Timestamp]s so they are
  /// time-zone–agnostic and can be sorted server-side.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'amount': amount,
      'categoryId': categoryId,
      'date': Timestamp.fromDate(date),
      'note': note,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Creates an [ExpenseModel] from a Firestore document [map].
  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: (map['id'] as String?) ?? '',
      uid: (map['uid'] as String?) ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      categoryId: (map['categoryId'] as String?) ?? '',
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      note: map['note'] as String?,
      createdAt:
          (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Creates an [ExpenseModel] from a Firestore [DocumentSnapshot].
  factory ExpenseModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ExpenseModel.fromMap(data);
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  ExpenseModel copyWith({
    String? id,
    String? uid,
    double? amount,
    String? categoryId,
    DateTime? date,
    String? note,
    DateTime? createdAt,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() =>
      'ExpenseModel(id: $id, uid: $uid, amount: $amount, '
      'categoryId: $categoryId, date: $date, note: $note)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExpenseModel && other.id == id && other.uid == uid;
  }

  @override
  int get hashCode => id.hashCode ^ uid.hashCode;
}
