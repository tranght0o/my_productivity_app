import 'package:cloud_firestore/cloud_firestore.dart';

// User model for the app
// Helps store and retrieve user info from Firestore
class AppUser {
  final String uid; // Firebase UID, unique per user
  final String name; // User's display name
  final String email; // User's email
  final String? photoUrl; //  profile picture URL
  final DateTime? createdAt; //  when the user was created

  // Constructor
  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    this.createdAt,
  });

  // Convert AppUser object to a Map for saving in Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'photoUrl': photoUrl ?? '', // empty string if null
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(), // Firestore sets timestamp if null
    };
  }

  // Create AppUser object from Firestore Map
  factory AppUser.fromMap(Map<String, dynamic> map, String uid) {
    return AppUser(
      uid: uid,
      name: map['name'] ?? '', // fallback if missing
      email: map['email'] ?? '',
      photoUrl: map['photoUrl'],
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
    );
  }


  @override
  String toString() {
    return 'AppUser(uid: $uid, name: $name, email: $email, photoUrl: $photoUrl, createdAt: $createdAt)';
  }
}
