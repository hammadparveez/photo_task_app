import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:photo_taking/src/model/user_model.dart';
import 'package:photo_taking/src/repository/auth_repository.dart';

enum AuthStatus { loading, success, error, unauthenticated, authenticated }

abstract class AuthBaseController extends ChangeNotifier {
  final _firebaseAuth = FirebaseAuth.instance;
  final AuthRepository _authRepository = AuthRepository();

  String? _verificationID;
  String? get verificationID => _verificationID;

  String? _errorMsg;
  String? get errorMsg => _errorMsg;



  AuthStatus? _status;
  AuthStatus? get status => _status;
  set _setAuthStatus(AuthStatus? value) {
    _status = value;
    notifyListeners();
  }
}

class AuthController extends AuthBaseController {
  AuthController() {
    _firebaseAuth.authStateChanges().listen((user) {
      if (user != null) {
        _setAuthStatus = AuthStatus.authenticated;
      } else {
        _setAuthStatus = AuthStatus.unauthenticated;
      }
      notifyListeners();
    });
  }

  Future<void> isAuthenticated() async {}

  void verifyPhoneNumber(String number) {
    _setAuthStatus = AuthStatus.loading;
    _firebaseAuth.verifyPhoneNumber(
      timeout: const Duration(seconds: 10),
      forceResendingToken: 4,
      phoneNumber: number,
      verificationFailed: _onErrorOccured,
      codeAutoRetrievalTimeout: (verificationId) {},
      verificationCompleted: (credendtial) {},
      codeSent: _whenCodeSent,
    );
  }

  void _whenCodeSent(String verificationId, int? resendToken) async {
    _verificationID = verificationId;
    _setAuthStatus = null;
  }

  void _onErrorOccured(FirebaseAuthException error) {
    _errorMsg = error.message;
    _setAuthStatus = AuthStatus.error;
  }
}

class OTPreceiver extends AuthBaseController {
  final AuthBaseController baseController;
  OTPreceiver(this.baseController);
  authenticate(String otpCode) async {
    _setAuthStatus = AuthStatus.loading;
    try {
      if (baseController.verificationID == null) {
        throw Exception("Verification Code failed");
      }
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: baseController.verificationID!, smsCode: otpCode);

      final user = await _firebaseAuth.signInWithCredential(credential);
      final createdAt = user.user!.metadata.creationTime!.toString();
      final lastSignedIn = user.user!.metadata.lastSignInTime!.toString();
      await _authRepository.addUser(UserModel(
          phoneNumber: user.user!.phoneNumber!,
          uid: user.user!.uid,
          createdAt: createdAt,
          lastSignIn: lastSignedIn));
      _setAuthStatus = AuthStatus.success;
    } on FirebaseAuthException catch (e) {
      _errorMsg = e.message;
      _setAuthStatus = AuthStatus.error;
    } catch (e) {
      _errorMsg = "Something went wrong!";
      _setAuthStatus = AuthStatus.error;
    }
  }
}
