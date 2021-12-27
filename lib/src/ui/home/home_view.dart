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
import 'package:photo_taking/src/ui/home/custom_drawer.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  bool hasLongTapped = false;
  ImageUploadModel? selectedItem;
  _onPhotoTap() {
    showDialog(
        context: context,
        builder: (_) {
          return _buildCameraTapDialog();
        });
  }

  _onDeleteTap() {
    if (selectedItem != null) {
      ref.read(fileController).deleteFile(selectedItem!);
    }
  }

  _onGallerySelect() async {
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
          showSimpleDialog(context, 'There was an error!');
          break;
        case FileUploadStatus.deleting:
          showLodaerDialog(context, 'Deleting an Image!');

          break;
        case FileUploadStatus.deleted:
          closeLoader(context);
          showSimpleDialog(context, 'Image successfully deleted!');
          break;
        default:
      }
      _unSelectImage();
    });
  }

  _unSelectImage() {
    if (hasLongTapped) {
      setState(() {
        hasLongTapped = false;
        selectedItem = null;
      });
    }
  }

  Future<bool> _onBackPress() async {
    if (hasLongTapped) {
      _unSelectImage();
      return false;
    } else {
      showSimpleDialog(context, 'Do you want to exit', actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel')),
        TextButton(
            onPressed: () => Navigator.of(context).pop(), child: Text('Exit')),
      ]);
      return false;
    }
  }

  _onLongTap(ImageUploadModel image) {
    setState(() {
      selectedItem = image;
      hasLongTapped = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    _attachEventListener();
    return WillPopScope(
      onWillPop: _onBackPress,
      child: Scaffold(
        appBar: AppBar(),
        drawer: const CustomDrawer(),
        floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasLongTapped)
              FloatingActionButton(
                  heroTag: 'delete-tag',
                  onPressed: _onDeleteTap,
                  child: const Icon(Icons.delete)),
            const SizedBox(height: 10),
            FloatingActionButton(
              heroTag: 'photo-tag',
              onPressed: _onPhotoTap,
              child: const Icon(Icons.add_a_photo),
            ),
          ],
        ),
        body: StreamBuilder<List<ImageUploadModel>>(
            stream: ref.watch(fileController).imageSnapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final images = snapshot.data!;
                if (images.isEmpty) {
                  return _buildEmptyItemWidget(context);
                }
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 30,
                      mainAxisSpacing: 30),
                  itemCount: images.length,
                  itemBuilder: (_, index) {
                    return GalleryGridView(
                        onLongTap: () => _onLongTap(images[index]),
                        onTap: _unSelectImage,
                        isSelected: hasLongTapped,
                        image: images[index]);
                  },
                );
              } else if (snapshot.hasError) {
                return Text("Something wrong ${snapshot.error}");
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            }),
      ),
    );
  }

  Center _buildEmptyItemWidget(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Oops! Sorry No Image uploaded',
              style: Theme.of(context).textTheme.headline6),
          const SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.camera_alt),
              const SizedBox(width: 10),
              Text('Tap on Camera to Upload Image')
            ],
          )
        ],
      ),
    );
  }

  AlertDialog _buildCameraTapDialog() {
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
              onPressed: () => _onGallerySelect(),
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text('Upload from Gallery')),
          TextButton.icon(
              onPressed: _onCameraSelect,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Upload from Camera'))
        ],
      ),
    );
  }
}

class GalleryGridView extends StatelessWidget {
  final VoidCallback onLongTap;
  final VoidCallback onTap;
  final bool isSelected;
  final ImageUploadModel image;
  const GalleryGridView({
    Key? key,
    required this.onLongTap,
    required this.onTap,
    required this.isSelected,
    required this.image,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongTap,
      onTap: onTap,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.network(image.imageUri,
                loadingBuilder: (_, widget, imageChunk) {
              if (imageChunk?.expectedTotalBytes ==
                  imageChunk?.cumulativeBytesLoaded) {
                return widget;
              }
              return const Center(child: CircularProgressIndicator());
            }, fit: BoxFit.cover),
          ),
          if (isSelected)
            Positioned.fill(
                child: ColoredBox(
              color: Colors.blue.withOpacity(.3),
            )),
        ],
      ),
    );
  }
}
