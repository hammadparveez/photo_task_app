import 'package:photo_taking/src/ui/auth/otp_view.dart';
import 'package:photo_taking/src/ui/home/home_view.dart';

const photoScreenRoute = "/photo-screen";
const otpScreenRoute = "/otp-screen";

final routes = {
  photoScreenRoute: (_) => const HomeView(),
  otpScreenRoute: (_) => const OtpView(),
};
