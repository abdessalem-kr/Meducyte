import 'dart:async';
import 'package:meducyte_app/export.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String email;
  final String type; // 'email_verification'or'password_reset'
  final bool isFromSignup;

  const OtpVerificationScreen({
    super.key,
    required this.email,
    required this.type,
    required this.isFromSignup,
  });

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final TextEditingController otpController = TextEditingController();
  bool isLoading = false;
  bool isResending = false;
  int countdown = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel(); //Cancel timer first
    //otpController.dispose(); //Then dispose controller
    super.dispose();
  }

  void startCountdown() {
    _timer?.cancel(); //Cancel existing timer

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // ✅Check if widget is still mounted
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (countdown > 0) {
        setState(() => countdown--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.type == 'email_verification'
              ? context.l10n.authVerifyEmail
              : context.l10n.authResetPassword,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Text(
              widget.type == 'email_verification'
                  ? context.l10n.authVerifyYourEmail
                  : context.l10n.authResetYourPassword,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.authEnterOtp,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              widget.email,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 40),

            //OTP Input Field
            PinCodeTextField(
              appContext: context,
              length: 6,
              controller: otpController,
              keyboardType: TextInputType.number,
              onChanged: (value) {},
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(8),
                fieldHeight: 50,
                fieldWidth: 45,
                activeFillColor: Colors.white,
                selectedColor: AppColors.primary,
                inactiveColor: Colors.grey[300]!,
              ),
              backgroundColor: Colors.transparent,
            ),

            const SizedBox(height: 24),

            //Resend OTP
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  context.l10n.authNoCode,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(width: 8),
                if (countdown > 0)
                  Text(
                    context.l10n.authResendIn(countdown.toString()),
                    style: const TextStyle(color: AppColors.primary),
                  )
                else
                  TextButton(
                    onPressed: isResending ? null : _resendOtp,
                    child: isResending
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(context.l10n.authResendOtp),
                  ),
              ],
            ),

            const SizedBox(height: 48),

            //Verify Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _verifyOtp,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : Text(
                        widget.type == 'email_verification'
                            ? context.l10n.authVerifyEmail
                            : context.l10n.authResetPassword,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _verifyOtp() async {
    if (otpController.text.length != 6) {
      AppSnackBars.error(context, context.l10n.authInvalidOtp);
      return;
    }

    if (!mounted) return; // ✅Add this

    setState(() => isLoading = true);

    try {
      final authController = ref.read(authControllerProvider.notifier);

      authController.setPendingVerification(widget.email, widget.type);

      await authController.verifyOtp(otpController.text);

      if (!mounted) return; // ✅Check after async

      if (widget.type == 'email_verification') {
        AppSnackBars.success(context, context.l10n.authEmailVerified);

        if (widget.isFromSignup) {
          await ref.read(authProvider.notifier).logIn();
          if (mounted) {
            //clear all old entries after send them to database
            ref.read(signUpProvider.notifier).reset();
            context.go(AppRoutes.welcome);
          }
        } else {
          if (mounted) {
            context.go(AppRoutes.welcome);
          }
        }
      } else {
        AppSnackBars.success(context, context.l10n.authOtpVerified);
        if (mounted) {
          context.go(
            AppRoutes.resetPassword,
            extra: {'email': widget.email, 'otp': otpController.text},
          );
        }
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = e.toString().replaceAll('Exception: ', '');
        AppSnackBars.error(context, errorMessage);
        // debugPrint(e);
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _resendOtp() async {
    if (!mounted) return; // ✅Add this

    setState(() => isResending = true);

    try {
      final authController = ref.read(authControllerProvider.notifier);

      authController.setPendingVerification(widget.email, widget.type);

      await authController.resendOtp();

      if (mounted) {
        AppSnackBars.success(context, context.l10n.authOtpSent);
        setState(() => countdown = 60);
        startCountdown();
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = e.toString().replaceAll('Exception: ', '');
        AppSnackBars.error(context, errorMessage);
        // debugPrint(e);
      }
    } finally {
      if (mounted) {
        setState(() => isResending = false);
      }
    }
  }
}

//  Future<void>_resendOtp()async{
//    setState(() {
//      isResending=true;
//      countdown=60;
//      startCountdown();
//     });

//    try{
//      final authController=ref.read(authControllerProvider.notifier);
//      await authController.resendOtp();

//      AppSnackBars.success(context, 'OTP sent successfully!');
//      startCountdown();
//     }catch(e) {
//      AppSnackBars.error(context,e.toString());
//       debugPrint(e);
//     }finally{
//      setState(() =>isResending=false);
//     }
//   }
// }
