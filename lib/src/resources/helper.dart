import 'package:flutter/material.dart';
import 'package:photo_taking/src/resources/constants.dart';

void showLodaerDialog(BuildContext ctx, [String? text]) {
  showDialog(
      context: ctx,
      builder: (_) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 10),
              Text(text ?? AppStrings.loading)
            ],
          ),
        );
      });
}

void showSimpleDialog(BuildContext ctx, String title, {List<Widget>? actions}) {
  showDialog(
      context: ctx,
      builder: (_) {
        return AlertDialog(
          content: Text(title),
          actions: actions ??
              [
                TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                    },
                    child: Text('Close'))
              ],
        );
      });
}

void closeLoader(BuildContext context) => Navigator.pop(context);
