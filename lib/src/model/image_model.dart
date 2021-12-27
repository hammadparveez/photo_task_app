import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class ImageUploadModel {
  final String imageName;
  final String imageUri;
  final String? imageRefrence;
  Timestamp? uploadedAt;
  FieldValue? serverTime;
  ImageUploadModel({
    required this.imageName,
    required this.imageUri,
    this.imageRefrence,
    this.uploadedAt,
    this.serverTime,
  });
 
 

  ImageUploadModel copyWith({
    String? imageName,
    String? imageUri,
    String? imageRefrence,
    Timestamp? uploadedAt,
    FieldValue? serverTime,
  }) {
    return ImageUploadModel(
      imageName: imageName ?? this.imageName,
      imageUri: imageUri ?? this.imageUri,
      imageRefrence: imageRefrence ?? this.imageRefrence,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      serverTime: serverTime ?? this.serverTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'imageName': imageName,
      'imageUri': imageUri,
      'imageRefrence': imageRefrence,
      'serverTime': serverTime,
    };
  }

  factory ImageUploadModel.fromMap(Map<String, dynamic> map) {
    return ImageUploadModel(
      imageName: map['imageName'] ?? '',
      imageUri: map['imageUri'] ?? '',
      imageRefrence: map['imageRefrence'],
      uploadedAt: map['serverTime'] ,
    );
  }

  String toJson() => json.encode(toMap());

  factory ImageUploadModel.fromJson(String source) => ImageUploadModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'ImageUploadModel(imageName: $imageName, imageUri: $imageUri, imageRefrence: $imageRefrence, uploadedAt: $uploadedAt, serverTime: $serverTime)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is ImageUploadModel &&
      other.imageName == imageName &&
      other.imageUri == imageUri &&
      other.imageRefrence == imageRefrence &&
      other.uploadedAt == uploadedAt &&
      other.serverTime == serverTime;
  }

  @override
  int get hashCode {
    return imageName.hashCode ^
      imageUri.hashCode ^
      imageRefrence.hashCode ^
      uploadedAt.hashCode ^
      serverTime.hashCode;
  }
}
