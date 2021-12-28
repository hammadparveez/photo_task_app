import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:photo_taking/pods.dart';
import 'package:photo_taking/src/controller/auth_controller.dart';
import 'package:photo_taking/src/resources/constants.dart';
import 'package:photo_taking/src/resources/helper.dart';
import 'package:photo_taking/src/resources/routes.dart';
import 'package:photo_taking/src/ui/home/home_view.dart';

class AuthView extends ConsumerStatefulWidget {
  const AuthView({Key? key}) : super(key: key);

  @override
  ConsumerState<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends ConsumerState<AuthView> {
  late TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();
  final _russianNumberFormat = MaskTextInputFormatter(
      mask: '+7 (###) ###-##-##', filter: {"#": RegExp(r'[0-9]')});

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (isValid) {
      ref.read(authController).verifyPhoneNumber(_controller.text);
    }
  }

  String? _phoneFieldValidator(String? value) {
    var totalCharInField = 19;
    if (value!.length != totalCharInField) {
      print("$value");
      return 'Please Enter a valid number';
    }
  }

  _attachEventListener() {
    ref.listen<AuthController>(authController, (previousState, nextState) {
      switch (nextState.status) {
        case AuthStatus.loading:
          showLodaerDialog(context, 'Sending OTP Code...');
          break;
        case AuthStatus.error:
          closeLoader(context);
          showSimpleDialog(context, nextState.errorMsg!);
          break;
        case AuthStatus.unAuthenticated:
          if (Navigator.canPop(context)) closeLoader(context);

          break;
        case AuthStatus.codeSent:
          closeLoader(context);
          Navigator.pushReplacementNamed(context, otpScreenRoute);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _attachEventListener();

    final textTheme = Theme.of(context).textTheme;
    final authStatus = ref.watch(authController).status;

    if (authStatus == AuthStatus.authenticating) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    } else if (authStatus == AuthStatus.success) {
      return const HomeView();
    }

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(AppStrings.enterPhNo, style: textTheme.headline5),
            const SizedBox(height: 10),
            _buildNumField(),
            ElevatedButton(onPressed: _onTap, child: Text('Sign In')),
          ],
        ),
      ),
    );
  }

  Widget _buildNumField() {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: TextFormField(
          keyboardType: TextInputType.phone,
          controller: _controller,
          validator: _phoneFieldValidator,
          inputFormatters: [_russianNumberFormat],
        ),
      ),
    );
  }
}
