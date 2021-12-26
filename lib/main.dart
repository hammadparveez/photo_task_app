import 'package:flutter/material.dart';
import 'package:photo_taking/src/resources/constants.dart';
import 'package:photo_taking/src/ui/auth/auth_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppStrings.appTitle,
      home: const AuthView(),
    );
  }
}
