import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class ImageUploadModel {
  
  final String imageName;
  final String imageUri;
  final FieldValue uploadedAt;
  ImageUploadModel({
    required this.imageName,
    required this.imageUri,
    required this.uploadedAt,
  });

  ImageUploadModel copyWith({
    String? imageName,
    String? imageUri,
    FieldValue? uploadedAt,
  }) {
    return ImageUploadModel(
      imageName: imageName ?? this.imageName,
      imageUri: imageUri ?? this.imageUri,
      uploadedAt: uploadedAt ?? this.uploadedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'imageName': imageName,
      'imageUri': imageUri,
      'uploadedAt': uploadedAt,
    };
  }

  factory ImageUploadModel.fromMap(Map<String, dynamic> map) {
    return ImageUploadModel(
      imageName: map['imageName'] ?? '',
      imageUri: map['imageUri'] ?? '',
      uploadedAt: map['uploadedAt'],
    );
  }

  String toJson() => json.encode(toMap());

  factory ImageUploadModel.fromJson(String source) => ImageUploadModel.fromMap(json.decode(source));

  @override
  String toString() => 'ImageUploadModel(imageName: $imageName, imageUri: $imageUri, uploadedAt: $uploadedAt)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is ImageUploadModel &&
      other.imageName == imageName &&
      other.imageUri == imageUri &&
      other.uploadedAt == uploadedAt;
  }

  @override
  int get hashCode => imageName.hashCode ^ imageUri.hashCode ^ uploadedAt.hashCode;
}
