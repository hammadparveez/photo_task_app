import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:photo_taking/src/model/user_model.dart';
import 'package:photo_taking/src/repository/auth_repository.dart';

enum AuthStatus {
  loading,
  success,
  error,
  codeSent,
  authenticating,
  unAuthenticated
}

abstract class AuthBaseController extends ChangeNotifier {
  final firebaseAuth = FirebaseAuth.instance;
  final AuthRepository authRepository = AuthRepository();

  String? _verificationID;
  String? get verificationID => _verificationID;
  set verificationID(value) {
    _verificationID = value;
  }

  String? _errorMsg;
  String? get errorMsg => _errorMsg;
  set errorMsg(value) {
    _errorMsg = value;
  }

  AuthStatus? _status;
  AuthStatus? get status => _status;
  @protected
  set setAuthStatus(AuthStatus? value) {
    _status = value;
    notifyListeners();
  }
}

class AuthController extends AuthBaseController {
  AuthController() {
    firebaseAuth.authStateChanges().listen((user) async {
      setAuthStatus = AuthStatus.authenticating;
      await Future.delayed(const Duration(seconds: 2));
      if (user != null) {
        setAuthStatus = AuthStatus.success;
        return;
      }
      setAuthStatus = AuthStatus.unAuthenticated;
    });
  }
  User? get user =>  firebaseAuth.currentUser;
  

  void verifyPhoneNumber(String number) {
    setAuthStatus = AuthStatus.loading;
    firebaseAuth.verifyPhoneNumber(
      phoneNumber: number,
      verificationFailed: _onErrorOccured,
      codeAutoRetrievalTimeout: _onTimedOut,
      verificationCompleted: (credendtial) {},
      codeSent: _whenCodeSent,
    );
  }

  void _whenCodeSent(String verificationId, int? resendToken) async {
    verificationID = verificationId;
    setAuthStatus = AuthStatus.codeSent;
  }

  void _onErrorOccured(FirebaseAuthException error) {
    errorMsg = error.message;
    setAuthStatus = AuthStatus.error;
  }

  _onTimedOut(String verificationID) {
    //Code.....
  }

  Future<bool> signOut() async {
    await firebaseAuth.signOut();

    return true;
  }
}
