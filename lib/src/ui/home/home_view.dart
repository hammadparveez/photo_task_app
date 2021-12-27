import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:photo_taking/pods.dart';
import 'package:photo_taking/src/controller/file_controller.dart';
import 'package:photo_taking/src/model/image_model.dart';
import 'package:photo_taking/src/resources/helper.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
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
                    onPressed: () => _onGallerySelect(context),
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

  _onGallerySelect(BuildContext context) async {
    Navigator.pop(context);
    final image = await _onImagePicker(ImageSource.gallery);
    if (image != null) {
      ref.read(fileController).uploadImage(image);
    }
  }

  _onCameraSelect() async {
    Navigator.pop(context);
    final image = await _onImagePicker(ImageSource.camera);
    if (image != null) {
      ref.read(fileController).uploadImage(image);
    }
  }

  Future<XFile?> _onImagePicker(ImageSource source) async {
    final imagePicker = ImagePicker();
    final image = await imagePicker.pickImage(source: source);
    return image;
  }

  _attachEventListener() {
    ref.listen<FileController>(fileController, (previousState, nextState) {
      switch (nextState.fileUploadStatus) {
        case FileUploadStatus.uploading:
          showLodaerDialog(context, 'Uploading an Image...');
          break;
        case FileUploadStatus.success:
          closeLoader(context);
          showSimpleDialog(context, 'File Uploaded Successfully');
          break;
        case FileUploadStatus.error:
          closeLoader(context);
          showSimpleDialog(context, 'There was an error while Uploading!');
          break;
        default:
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _attachEventListener();
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
      body: StreamBuilder<List<ImageUploadModel>>(
          stream: ref.watch(fileController).imageSnapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final images = snapshot.data!;
              return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 30,
                      mainAxisSpacing: 30),
                  itemCount: images.length,
                  itemBuilder: (_, index) {
                    return Image.network(images[index].imageUri,
                        fit: BoxFit.cover);
                  });
            } else if (snapshot.connectionState != ConnectionState.done) {
              return CircularProgressIndicator();
            }
            return Text("Something wrong ${snapshot.error}");
          }),
    );
  }
}
