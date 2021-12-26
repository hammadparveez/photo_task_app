import 'dart:convert';

class UserModel {
  final String phoneNumber;
  final String uid;
  final String createdAt;
  final String lastSignIn;
  UserModel({
    required this.phoneNumber,
    required this.uid,
    required this.createdAt,
    required this.lastSignIn,
  });

  UserModel copyWith({
    String? phoneNumber,
    String? uid,
    String? createdAt,
    String? lastSignIn,
  }) {
    return UserModel(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      uid: uid ?? this.uid,
      createdAt: createdAt ?? this.createdAt,
      lastSignIn: lastSignIn ?? this.lastSignIn,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'phoneNumber': phoneNumber,
      'uid': uid,
      'createdAt': createdAt,
      'lastSignIn': lastSignIn,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      phoneNumber: map['phoneNumber'] ?? '',
      uid: map['uid'] ?? '',
      createdAt: map['createdAt'] ?? '',
      lastSignIn: map['lastSignIn'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) => UserModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'UserModel(phoneNumber: $phoneNumber, uid: $uid, createdAt: $createdAt, lastSignIn: $lastSignIn)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is UserModel &&
      other.phoneNumber == phoneNumber &&
      other.uid == uid &&
      other.createdAt == createdAt &&
      other.lastSignIn == lastSignIn;
  }

  @override
  int get hashCode {
    return phoneNumber.hashCode ^
      uid.hashCode ^
      createdAt.hashCode ^
      lastSignIn.hashCode;
  }
}
