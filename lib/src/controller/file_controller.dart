import 'dart:io';


import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

import 'package:photo_taking/src/model/image_model.dart';
import 'package:photo_taking/src/repository/file_upload_repo.dart';

enum FileUploadStatus { none, uploading, success, error, deleting, deleted }

class FileController extends ChangeNotifier {
  final FileUploadRepository _fileUploadRepo = FileUploadRepository();
  List<ImageUploadModel> _items = [];
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

  Future<void> deleteFile(ImageUploadModel image) async {
    try {
      
      _setFileUploadStatus = FileUploadStatus.deleting;
          await _fileUploadRepo.deleteFile(image);
      _setFileUploadStatus = FileUploadStatus.deleted;
    } catch (e) {
      _setFileUploadStatus = FileUploadStatus.error;
    }
  }
}
