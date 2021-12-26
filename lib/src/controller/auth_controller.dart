import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:photo_taking/src/model/user_model.dart';
import 'package:photo_taking/src/repository/auth_repository.dart';

enum AuthStatus { loading, success, error }

class AuthController extends ChangeNotifier {
  final _firebaseAuth = FirebaseAuth.instance;
  final AuthRepository _authRepository = AuthRepository();

  String? _errorMsg;
  String? get errorMsg => _errorMsg;

  AuthStatus? _status;
  AuthStatus? get status => _status;
  set _setAuthStatus(AuthStatus value) {
    _status = value;
    notifyListeners();
  }

  void verifyPhoneNumber(String number) {
    _setAuthStatus = AuthStatus.loading;
    _firebaseAuth.verifyPhoneNumber(
      forceResendingToken: 1,
      phoneNumber: number,
      verificationFailed: _onErrorOccured,
      codeAutoRetrievalTimeout: (verificationId) {},
      verificationCompleted: (credendtial) {},
      codeSent: _whenCodeSent,
    );
  }

  void _whenCodeSent(String verificationId, int? resendToken) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId, smsCode: '123456');
    try {
      await _authenticate(credential);
    } on FirebaseAuthException catch (e) {
      _errorMsg = e.message;
      _setAuthStatus = AuthStatus.error;
    }
  }

  _authenticate(PhoneAuthCredential  credential) async {
    final user = await _firebaseAuth.signInWithCredential(credential);
    final createdAt = user.user!.metadata.creationTime!.toString();
    final lastSignedIn = user.user!.metadata.lastSignInTime!.toString();
    await _authRepository.addUser(UserModel(
        phoneNumber: user.user!.phoneNumber!,
        uid: user.user!.uid,
        createdAt: createdAt,
        lastSignIn: lastSignedIn));
    _setAuthStatus = AuthStatus.success;
  }

  void _onErrorOccured(FirebaseAuthException error) {
    _errorMsg = error.message;
    _setAuthStatus = AuthStatus.error;
  }
}
