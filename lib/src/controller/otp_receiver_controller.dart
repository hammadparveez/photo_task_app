import 'package:firebase_auth/firebase_auth.dart';
import 'package:photo_taking/src/controller/auth_controller.dart';
import 'package:photo_taking/src/model/user_model.dart';

class OTPreceiver extends AuthBaseController {
  final AuthBaseController baseController;
  OTPreceiver(this.baseController);

  authenticate(String otpCode) async {
    setAuthStatus = AuthStatus.loading;
    try {
      _throwIfVerificationFails();

      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: baseController.verificationID!, smsCode: otpCode);

      final user = await firebaseAuth.signInWithCredential(credential);
      final createdAt = user.user!.metadata.creationTime!.toString();
      final lastSignedIn = user.user!.metadata.lastSignInTime!.toString();
      await authRepository.addUser(UserModel(
          phoneNumber: user.user!.phoneNumber!,
          uid: user.user!.uid,
          createdAt: createdAt,
          lastSignIn: lastSignedIn));
      setAuthStatus = AuthStatus.success;
    } on FirebaseAuthException catch (e) {
      errorMsg = e.message;
      setAuthStatus = AuthStatus.error;
    } catch (e) {
      errorMsg = "Something went wrong!";
      setAuthStatus = AuthStatus.error;
    }
  }

  _throwIfVerificationFails() {
    if (baseController.verificationID == null) {
      throw Exception("Verification Code failed");
    }
  }
}
