import 'package:meducyte_app/export.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: Scaffold(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.black
            : Colors.white,
        body: OnBoarding(),
      ),
      tablet: AnimatedScreen(screen: OnBoarding()),
      desktop: AnimatedScreen(screen: OnBoarding()),
    );
  }
}

class OnBoarding extends StatelessWidget {
  const OnBoarding({super.key});

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          //Image section
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
                child: Image.asset(
                  'assets/images/onboard.png',
                  fit: BoxFit.cover,
                  height: MediaQuery.of(context).size.height * 0.6,
                  width: double.infinity,
                ),
              ),
              //Gradient overlay
              Positioned.fill(
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.center,
                      colors: [
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.black
                            : Colors.white,
                        AppColors.accentLight.withOpacity(0),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          //Text section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Column(
              children: [
                Text(
                  tr.onBoardingTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    //color:Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  tr.onBoardingDescription,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                OnboardingButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingButton extends ConsumerWidget {
  const OnboardingButton({super.key});

  Future<void> _completeOnboarding(BuildContext context, WidgetRef ref) async {
    // ✅Use the notifier’s built-in method
    await ref.read(onboardingProvider.notifier).completeOnboarding();

    // ✅Then navigate to authentication
    if (context.mounted) context.go('/auth');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 400,
        height: 60,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () => _completeOnboarding(context, ref),
          child: Text(
            AppLocalizations.of(context)!.onBoardingConinueBtn,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
      ),
    );
  }
}
