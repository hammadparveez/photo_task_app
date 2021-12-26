import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_taking/src/controller/auth_controller.dart';

final authController = ChangeNotifierProvider((ref) => AuthController());
