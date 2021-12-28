
import 'package:flutter/material.dart';
import 'package:photo_taking/src/model/image_model.dart';

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
