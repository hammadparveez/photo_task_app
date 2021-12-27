import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:photo_taking/src/controller/auth_controller.dart';
import 'package:photo_taking/src/model/image_model.dart';

enum FileUploadStatus { none, uploading, success, error, deleting,deleted }

class FileController extends ChangeNotifier {
  final FileUploadRepository _fileUploadRepo = FileUploadRepository();

  FileUploadStatus _fileUploadStatus = FileUploadStatus.none;
  FileUploadStatus get fileUploadStatus => _fileUploadStatus;
  set _setFileUploadStatus(FileUploadStatus status) {
    _fileUploadStatus = status;
    notifyListeners();
  }

  Stream<List<ImageUploadModel>> imageSnapshots() {
    return _fileUploadRepo.imageSnapshots();
  }

  uploadImage(XFile image) {
    _setFileUploadStatus = FileUploadStatus.uploading;
    final uniqueID = DateTime.now().millisecondsSinceEpoch.toString();
    final fileRenamed = uniqueID + path.extension(image.path);

    _fileUploadRepo
        .storeFileToStorage(fileRenamed, image.path)
        .listen((event) async {
      if (event.state == TaskState.success) {
        await _fileUploadRepo.uploadOnSuccess(fileRenamed, event.ref);
        _setFileUploadStatus = FileUploadStatus.success;
      } else if (event.state == TaskState.error) {
        _setFileUploadStatus = FileUploadStatus.error;
      } else {
        _setFileUploadStatus = FileUploadStatus.none;
      }
    });
  }

  deleteFile(ImageUploadModel image) async {
    _setFileUploadStatus = FileUploadStatus.deleting;
    final isDeleted = await _fileUploadRepo.deleteFile(image);
    if(isDeleted){
       _setFileUploadStatus = FileUploadStatus.deleted;
       }
    else {
_setFileUploadStatus = FileUploadStatus.error;
    }
  }
}

class FileUploadRepository {
  final _firestore = FirebaseFirestore.instance;
  final _firebaseStorage = FirebaseStorage.instance;

  Stream<List<ImageUploadModel>> imageSnapshots() {
    final snapshots = FirebaseFirestore.instance
        .collection('user')
        .doc('yHPWHO3fb4SNx7TgdK4c')
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
    final fileReference = "yHPWHO3fb4SNx7TgdK4c/images/$imageName";
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
        .doc('yHPWHO3fb4SNx7TgdK4c')
        .collection('files')
        .add(fileMappedModel);
  }

  Future<bool> deleteFile(ImageUploadModel image) async {
    await _firebaseStorage.ref(image.imageRefrence!).delete();
    final querySnapshot = await _firestore
        .collection('user')
        .doc('yHPWHO3fb4SNx7TgdK4c')
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
      doc.reference.delete();
      return true;
    } catch (e) {
      return false;
    }
  }
}
