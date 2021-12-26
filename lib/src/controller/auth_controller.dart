import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

enum AuthStatus { loading, success, error }

class AuthController extends ChangeNotifier {
  final _firebaseAuth = FirebaseAuth.instance;

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
    await _firebaseAuth.signInWithCredential(credential);
    _setAuthStatus = AuthStatus.success;
  }

  void _onErrorOccured(FirebaseAuthException error) {
    _errorMsg = error.message;
    _setAuthStatus = AuthStatus.error;
  }
}
