
import 'package:flutter/material.dart';

class CustomFloatingActionButtons extends StatelessWidget {
  const CustomFloatingActionButtons({
    Key? key,
    required this.onDeleteTap,
    required this.onPhotoTap,
    this.isItemEmpty=false,
  }) : super(key: key);
  final VoidCallback onDeleteTap, onPhotoTap;
  final bool isItemEmpty ;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isItemEmpty)
          FloatingActionButton(
              heroTag: 'delete-tag',
              onPressed: onDeleteTap,
              child: const Icon(Icons.delete)),
        const SizedBox(height: 10),
        FloatingActionButton(
          heroTag: 'photo-tag',
          onPressed: onPhotoTap,
          child: const Icon(Icons.add_a_photo),
        ),
      ],
    );
  }
}
