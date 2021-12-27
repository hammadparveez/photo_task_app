import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:photo_taking/src/model/image_model.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  _onPhotoTap(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text('Upload a Photo'),
            actions: [
              TextButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close),
                  label: Text('Close')),
            ],
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton.icon(
                    onPressed: _onGallerySelect,
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Upload from Gallery')),
                TextButton.icon(
                    onPressed: _onCameraSelect,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Upload from Camera'))
              ],
            ),
          );
        });
  }

  _onDeleteTap(BuildContext context) {}

  _onGallerySelect() async {
    final imagePicker = ImagePicker();
    final image = await imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      String? fileUri;
      final uniqueID = DateTime.now().millisecondsSinceEpoch.toString();
      final fileRenamed = uniqueID + path.extension(image.path);

      final storageRefence = FirebaseStorage.instance.ref(
          "${FirebaseAuth.instance.currentUser!.uid}/images/${fileRenamed}");

      UploadTask task = storageRefence.putFile(File(image.path));

      task.snapshotEvents.listen((TaskSnapshot event) async {
        if (event.bytesTransferred == event.totalBytes) {
          fileUri = await storageRefence.getDownloadURL();
        }
      });
      FirebaseFirestore.instance
          .collection('user')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('files')
          .add(ImageUploadModel(
                  imageName: fileRenamed,
                  imageUri: fileUri!,
                  uploadedAt: FieldValue.serverTimestamp())
              .toMap());
    }
  }

  _onCameraSelect() {
    final imagePicker = ImagePicker();
    imagePicker.pickImage(source: ImageSource.camera);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      drawer: Drawer(
        child: Container(
          child: Column(
            children: [
              ListTile(title: Text("User")),
              Spacer(),
              ListTile(
                  title: Text("Exit App"),
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushReplacementNamed(context, "/");
                  }),
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
              heroTag: 'delete-tag',
              onPressed: () => _onDeleteTap(context),
              child: const Icon(Icons.delete)),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'photo-tag',
            onPressed: () => _onPhotoTap(context),
            child: const Icon(Icons.add_a_photo),
          ),
        ],
      ),
      body: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10),
          itemCount: 10,
          itemBuilder: (_, index) {
            return Text("Hi");
          }),
    );
  }
}
