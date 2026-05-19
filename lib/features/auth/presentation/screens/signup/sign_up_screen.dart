import 'package:meducyte_app/export.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: const SignUpScreenMobile(),
      tablet: const AnimatedScreen(screen: SignUpScreenMobile()),
      desktop: const AnimatedScreen(screen: SignUpScreenMobile()),
    );
  }
}
