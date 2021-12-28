
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:photo_taking/src/model/image_model.dart';

class FileUploadRepository {
  final _firestore = FirebaseFirestore.instance;
  final _firebaseStorage = FirebaseStorage.instance;
  final _firebaseAuth = FirebaseAuth.instance;
  Stream<List<ImageUploadModel>> imageSnapshots() {
    final currentUser = _firebaseAuth.currentUser;

    final snapshots = _firestore
        .collection('user')
        .doc(currentUser!.uid)
        .collection('files')
        .orderBy('serverTime', descending: true)
        .snapshots();
    final parsedItems = snapshots.map((event) {
      final docs = event.docs;
      final items = docs.map((item) {
        final data = item.data();
        return ImageUploadModel.fromMap(data);
      }).toList();
      return items;
    });
    return parsedItems;
  }

  Stream<TaskSnapshot> storeFileToStorage(String imageName, String imagePath) {
    final fileReference = "${_firebaseAuth.currentUser!.uid}/images/$imageName";
    final storageRefence = _firebaseStorage.ref(fileReference);
    UploadTask task = storageRefence.putFile(File(imagePath));
    return task.snapshotEvents;
  }

  Future<void> uploadOnSuccess(
      String imageName, Reference fileReference) async {
    final fileUri = await fileReference.getDownloadURL();
    final imageModel = ImageUploadModel(
            imageName: imageName,
            imageUri: fileUri,
            imageRefrence: fileReference.fullPath,
            serverTime: FieldValue.serverTimestamp())
        .toMap();
    await _storeFileData(imageModel);
  }

  Future<void> _storeFileData(Map<String, dynamic> fileMappedModel) async {
    await _firestore
        .collection('user')
        .doc(_firebaseAuth.currentUser!.uid)
        .collection('files')
        .add(fileMappedModel);
  }

  Future<bool> deleteFile(ImageUploadModel image) async {
    await _firebaseStorage.ref(image.imageRefrence!).delete();
    final querySnapshot = await _firestore
        .collection('user')
        .doc(_firebaseAuth.currentUser!.uid)
        .collection('files')
        .get();
    try {
      final doc = querySnapshot.docs.firstWhere((doc) {
        final model = ImageUploadModel.fromMap(doc.data());
        if (model.imageRefrence == image.imageRefrence) {
          return true;
        }
        return false;
      });
      await doc.reference.delete();
      return true;
    } catch (e) {
      return false;
    }
  }
}
