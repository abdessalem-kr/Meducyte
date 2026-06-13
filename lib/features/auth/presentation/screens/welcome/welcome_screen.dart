import 'dart:ui';
import 'package:meducyte_app/export.dart';

final dio = Dio();

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: const Welcome(),
      tablet: AnimatedScreen(screen: const Center(child: Welcome())),
      desktop: AnimatedScreen(screen: const Center(child: Welcome())),
    );
  }
}

class Welcome extends ConsumerStatefulWidget {
  const Welcome({super.key});

  @override
  ConsumerState<Welcome> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<Welcome> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  //login screen's login method
  Future<void> _login(BuildContext context, WidgetRef ref) async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final deviceId = await ref.read(deviceIdProvider.future);

    setState(() => _isLoading = true);

    try {
      await ref
          .read(authControllerProvider.notifier)
          .login(email, password, deviceId);

      //Login successful-update auth state and navigate to home
      ref.read(authProvider.notifier).logIn();
      if (!context.mounted) return;
      context.go(AppRoutes.home);
    } on EmailNotVerifiedException {
      if (!context.mounted) return;
      //Navigate to OTP verification for email verification
      context.go(
        AppRoutes.otpVerification,
        extra: {
          'email': email,
          'type': 'email_verification',
          'isFromSignup': false,
        },
      );
    } catch (e) {
      if (!context.mounted) return;
      AppSnackBars.error(context, 'Login failed: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          //Background Gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.primaryColor.withOpacity(0.08),
                    theme.primaryColor.withOpacity(0.02),
                    Colors.white,
                  ],
                ),
              ),
            ),
          ),
          //Subtle background pattern or circle
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.primaryColor.withOpacity(0.05),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Hero(
                      tag: 'app_logo',
                      child: Image.asset('assets/images/logo.png', height: 90),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      context.l10n.authWelcomeTitle,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: theme.primaryColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.l10n.authWelcomeSubtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(
                          0.6,
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    // ---Glassmorphism Card---
                    ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.5),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    labelText: context.l10n.authEmailLabel,
                                    hintText: context.l10n.authEmailHint,
                                    prefixIcon: const Icon(
                                      Iconsax.sms,
                                      size: 20,
                                    ),
                                    filled: true,
                                    fillColor: Colors.white.withOpacity(0.5),
                                  ),
                                  validator: (value) => value!.isEmpty
                                      ? context.l10n.authEmailLabel
                                      : null,
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: passwordController,
                                  obscureText: _obscurePassword,
                                  decoration: InputDecoration(
                                    labelText: context.l10n.authPasswordLabel,
                                    hintText: context.l10n.authPasswordHint,
                                    prefixIcon: const Icon(
                                      Iconsax.lock,
                                      size: 20,
                                    ),
                                    filled: true,
                                    fillColor: Colors.white.withOpacity(0.5),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Iconsax.eye_slash
                                            : Iconsax.eye,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                  ),
                                  validator: (value) => value!.isEmpty
                                      ? context.l10n.authPasswordLabel
                                      : null,
                                ),
                                const SizedBox(height: 12),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () => context.push(
                                      AppRoutes.forgotPassword,
                                      extra: {
                                        'email': emailController.text.trim(),
                                        'type': 'password_reset',
                                        'isFromSignup': false,
                                      },
                                    ),
                                    child: Text(
                                      context.l10n.authForgotPassword,
                                      style: TextStyle(
                                        color: theme.primaryColor,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // ---Sign In---
                                ElevatedButton(
                                  onPressed: _isLoading
                                      ? null
                                      : () async => await _login(context, ref),
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(
                                      double.infinity,
                                      56,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Text(
                                          context.l10n.authSignIn,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "${context.l10n.authNoAccount} ",
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        GestureDetector(
                          onTap: () => context.go(AppRoutes.signup),
                          child: Text(
                            context.l10n.authSignUp,
                            style: TextStyle(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
