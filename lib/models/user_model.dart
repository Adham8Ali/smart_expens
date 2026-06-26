// import 'package:cloud_firestore/cloud_firestore.dart';

// class UserModel {
//   final String uid;
//   final String name;
//   final String email;
//   final String? profileImage;
//   final DateTime createdAt;
//   final double? monthlyBudget;

//   UserModel({
//     required this.uid,
//     required this.name,
//     required this.email,
//     this.profileImage,
//     required this.createdAt,
//     this.monthlyBudget,
//   });

//   /// Convert UserModel to Map for Firestore
//   Map<String, dynamic> toMap() {
//     return {
//       'uid': uid,
//       'name': name,
//       'email': email,
//       'profileImage': profileImage,
//       'createdAt': createdAt,
//       'monthlyBudget': monthlyBudget,
//     };
//   }

//   /// Create UserModel from Firestore DocumentSnapshot
//   factory UserModel.fromMap(Map<String, dynamic> map) {
//     return UserModel(
//       uid: map['uid'] as String,
//       name: map['name'] as String,
//       email: map['email'] as String,
//       profileImage: (map['profileImage'] ?? map['image']) as String?,
//       createdAt: (map['createdAt'] as Timestamp).toDate(),
//       monthlyBudget: (map['monthlyBudget'] as num?)?.toDouble(),
//     );
//   }

//   /// Create UserModel from DocumentSnapshot
//   factory UserModel.fromDocument(DocumentSnapshot doc) {
//     final data = doc.data() as Map<String, dynamic>;
//     return UserModel.fromMap(data);
//   }

//   /// Create a copy of UserModel with modified fields
//   UserModel copyWith({
//     String? uid,
//     String? name,
//     String? email,
//     String? profileImage,
//     DateTime? createdAt,
//     double? monthlyBudget,
//   }) {
//     return UserModel(
//       uid: uid ?? this.uid,
//       name: name ?? this.name,
//       email: email ?? this.email,
//       profileImage: profileImage ?? this.profileImage,
//       createdAt: createdAt ?? this.createdAt,
//       monthlyBudget: monthlyBudget ?? this.monthlyBudget,
//     );
//   }

//   @override
//   String toString() {
//     return 'UserModel(uid: $uid, name: $name, email: $email, profileImage: $profileImage, createdAt: $createdAt)';
//   }

//   @override
//   bool operator ==(Object other) {
//     if (identical(this, other)) return true;

//     return other is UserModel &&
//         other.uid == uid &&
//         other.name == name &&
//         other.email == email &&
//         other.profileImage == profileImage &&
//         other.createdAt == createdAt;
//   }

//   @override
//   int get hashCode {
//     return uid.hashCode ^
//         name.hashCode ^
//         email.hashCode ^
//         profileImage.hashCode ^
//         createdAt.hashCode;
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? profileImage;
  final DateTime createdAt;
  final double? monthlyBudget;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.profileImage,
    required this.createdAt,
    this.monthlyBudget,
  });

  /// Convert UserModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'profileImage': profileImage,
      'createdAt': createdAt,
      'monthlyBudget':
          monthlyBudget, // أو 'budget': monthlyBudget ليتطابق مع الويب
    };
  }

  /// Create UserModel from Firestore DocumentSnapshot
  factory UserModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return UserModel(
      // استخدم docId لو حقل uid مش موجود (عشان حسابات الويب)
      uid: (map['uid'] ?? docId ?? '') as String,
      // تأمين قراءة الاسم والإيميل في حال كان أحدهما ناقصاً
      name: (map['name'] ?? 'Unknown User') as String,
      email: (map['email'] ?? 'No Email') as String,
      profileImage: (map['profileImage'] ?? map['image']) as String?,
      // تأمين قراءة التاريخ
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      // دعم قراءة monthlyBudget أو budget
      monthlyBudget: (map['monthlyBudget'] ?? map['budget'] as num?)
          ?.toDouble(),
    );
  }

  /// Create UserModel from DocumentSnapshot
  factory UserModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel.fromMap(data, docId: doc.id);
  }

  /// Create a copy of UserModel with modified fields
  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? profileImage,
    DateTime? createdAt,
    double? monthlyBudget,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt ?? this.createdAt,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
    );
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, name: $name, email: $email, profileImage: $profileImage, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel &&
        other.uid == uid &&
        other.name == name &&
        other.email == email &&
        other.profileImage == profileImage &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        name.hashCode ^
        email.hashCode ^
        profileImage.hashCode ^
        createdAt.hashCode;
  }
}
