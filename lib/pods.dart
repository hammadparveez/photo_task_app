import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_taking/src/controller/auth_controller.dart';
import 'package:photo_taking/src/controller/file_controller.dart';
import 'package:photo_taking/src/controller/otp_receiver_controller.dart';

final authController = ChangeNotifierProvider((ref) => AuthController());
final otpReceiverController =
    ChangeNotifierProvider((ref) => OTPreceiver(ref.read(authController)));
final fileController = ChangeNotifierProvider((ref) => FileController());
