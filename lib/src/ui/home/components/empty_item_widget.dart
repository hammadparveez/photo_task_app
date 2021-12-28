
import 'package:flutter/material.dart';

class EmptyItemWidget extends StatelessWidget {
  const EmptyItemWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
}
