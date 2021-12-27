import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_taking/src/controller/auth_controller.dart';
import 'package:photo_taking/src/controller/file_controller.dart';

final authController = ChangeNotifierProvider((ref) => AuthController());
final otpReceiverController =
    ChangeNotifierProvider((ref) => OTPreceiver(ref.watch(authController)));
final fileController = ChangeNotifierProvider((ref) => FileController());
