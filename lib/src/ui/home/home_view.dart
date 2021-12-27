import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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

  _onGallerySelect() {
    final imagePicker = ImagePicker();
    imagePicker.pickImage(source: ImageSource.gallery);
  }

  _onCameraSelect() {
    final imagePicker = ImagePicker();
    imagePicker.pickImage(source: ImageSource.camera);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: ListView.builder(
          itemCount: 10,
          itemBuilder: (_, index) {
            return Text("Hi");
          }),
    );
  }
}
