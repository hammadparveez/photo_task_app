import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_taking/src/resources/constants.dart';
import 'package:photo_taking/src/resources/routes.dart';
import 'package:photo_taking/src/ui/auth/auth_view.dart';
import 'package:photo_taking/src/ui/home/home_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: AppStrings.appTitle,
        home: const AuthView(),
        routes: routes,
      ),
    );
  }
}
