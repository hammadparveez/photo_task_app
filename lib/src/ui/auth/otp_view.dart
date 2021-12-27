import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_taking/pods.dart';
import 'package:photo_taking/src/controller/auth_controller.dart';
import 'package:photo_taking/src/resources/constants.dart';
import 'package:photo_taking/src/resources/helper.dart';
import 'package:photo_taking/src/resources/routes.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class OtpView extends ConsumerStatefulWidget {
  const OtpView({Key? key}) : super(key: key);

  @override
  ConsumerState<OtpView> createState() => _OtpViewState();
}

class _OtpViewState extends ConsumerState<OtpView> {
  _attachEventListener() {
    ref.listen<OTPreceiver>(otpReceiverController, (previousState, nextState) {
      if (nextState.status == AuthStatus.error) {
        //Closing Loader
        Navigator.pop(context);
        showSimpleDialog(context, nextState.errorMsg!);
      } else if (nextState.status == AuthStatus.loading) {
        showLodaerDialog(context, 'Verifying OTP Code');
      } else if (nextState.status == AuthStatus.success) {
        Navigator.pop(context);
        Navigator.pushNamed(context, photoScreenRoute);
      } else {
        //Closing Loader
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _attachEventListener();
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Enter OTP Code', style: textTheme.headline5),
            FractionallySizedBox(
              widthFactor: .8,
              child: PinCodeTextField(
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  appContext: context,
                  length: 6,
                  onChanged: (value) {
                    if (value.length == 6) {
                      ref.read(otpReceiverController).authenticate(value);
                    }
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
