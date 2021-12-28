import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:photo_taking/pods.dart';
import 'package:photo_taking/src/controller/auth_controller.dart';
import 'package:photo_taking/src/controller/file_controller.dart';
import 'package:photo_taking/src/model/image_model.dart';
import 'package:photo_taking/src/resources/helper.dart';
import 'package:photo_taking/src/ui/home/components/custom_drawer.dart';
import 'package:photo_taking/src/ui/home/components/custom_floating_action_btns.dart';
import 'package:photo_taking/src/ui/home/components/empty_item_widget.dart';
import 'package:photo_taking/src/ui/home/components/gallery_image.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  bool hasLongTapped = false;

  List<ImageUploadModel> items = [];
  _onPhotoTap() {
    showDialog(
        context: context,
        builder: (_) {
          return _buildCameraTapDialog();
        });
  }

  _onDeleteTap() {
    showSimpleDialog(context, 'Do you want to delete it?', actions: [
      TextButton(
          onPressed: () async {
            Navigator.pop(context);
            await ref.read(fileController).deleteFile(items.first);
          },
          child: Text('Yes')),
      TextButton(onPressed: () => Navigator.pop(context), child: Text('No')),
    ]);
  }

  _onGallerySelect() async {
    Navigator.pop(context);
    final image = await _onImagePicker(ImageSource.gallery);
    if (image != null) {
      ref.read(fileController).uploadImage(image);
    }
  }

  void _onCameraSelect() async {
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
    ref.listen<AuthController>(authController, (previous, nextState) {
      if (nextState.status == AuthStatus.authenticating) {
        showLodaerDialog(context, 'Signing out');
      }
    });

    ref.listen<FileController>(fileController, (previousState, nextState) {
      switch (nextState.fileUploadStatus) {
        case FileUploadStatus.uploading:
          showLodaerDialog(context, 'Uploading an Image...');
          break;
        case FileUploadStatus.success:
          closeLoader(context);
          //  showSimpleDialog(context, 'File Uploaded Successfully');
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
          //showSimpleDialog(context, 'Image successfully deleted!');
          break;
        default:
      }
      _unSelectImage();
    });
  }

  _unSelectImage() {
    setState(() {
      items.clear();
    });
  }

  _unSelectItem(ImageUploadModel image) {
    if (items.length > 0 && !items.contains(image)) {
      showSimpleDialog(context, 'Selection of Multiple Items is disabled');
      //items.add(image);
    } else {
      items.remove(image);
    }
    setState(() {});
  }

  Future<bool> _onBackPress() async {
    if (items.isNotEmpty) {
      _unSelectImage();
      return false;
    } else {
      exitAppDialog(context);
      return false;
    }
  }

  _onLongTap(ImageUploadModel image) {
    setState(() {
      items.add(image);
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
        floatingActionButton: CustomFloatingActionButtons(
          onDeleteTap: _onDeleteTap,
          onPhotoTap: _onPhotoTap,
          isItemEmpty: items.isNotEmpty,
        ),
        body: _buildBody(),
      ),
    );
  }

  StreamBuilder<List<ImageUploadModel>> _buildBody() {
    return StreamBuilder<List<ImageUploadModel>>(
        stream: ref.watch(fileController).imageSnapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final images = snapshot.data!;

            if (images.isEmpty) {
              return const EmptyItemWidget();
            }
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, crossAxisSpacing: 30, mainAxisSpacing: 30),
              itemCount: images.length,
              itemBuilder: (_, index) {
                return GalleryGridView(
                    key: ValueKey('$index'),
                    onLongTap: () => _onLongTap(images[index]),
                    onTap: () => _unSelectItem(images[index]),
                    isSelected: items.contains(images[index]),
                    image: images[index]);
              },
            );
          } else if (snapshot.hasError) {
            return Text("Something wrong ${snapshot.error}");
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
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
  }
}
