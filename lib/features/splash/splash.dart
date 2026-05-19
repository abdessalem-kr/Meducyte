import 'package:meducyte_app/export.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _gradientController;

  @override
  void initState() {
    super.initState();

    //Pulse animation for logo
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    //Gradient animation
    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _gradientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: SplashView(
        pulseController: _pulseController,
        gradientController: _gradientController,
      ),
      tablet: SplashView(
        pulseController: _pulseController,
        gradientController: _gradientController,
      ),
      desktop: SplashView(
        pulseController: _pulseController,
        gradientController: _gradientController,
      ),
    );
  }
}

class SplashView extends StatelessWidget {
  final AnimationController pulseController;
  final AnimationController gradientController;

  const SplashView({
    super.key,
    required this.pulseController,
    required this.gradientController,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSplash(
      gradientController: gradientController,
      pulseController: pulseController,
    );
  }
}

class AnimatedSplash extends StatelessWidget {
  const AnimatedSplash({
    super.key,
    required this.gradientController,
    required this.pulseController,
  });

  final AnimationController gradientController;
  final AnimationController pulseController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: gradientController,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.black
              : Colors.white,
          body: LiquidBackground(
            gradientController: gradientController,
            pulseController: pulseController,
            element: SplashScreenElements(pulseController: pulseController),
          ),
        );
      },
    );
  }
}

class SplashScreenElements extends StatelessWidget {
  const SplashScreenElements({super.key, required this.pulseController});

  final AnimationController pulseController;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: Tween(begin: 0.95, end: 1.05).animate(
              CurvedAnimation(parent: pulseController, curve: Curves.easeInOut),
            ),
            child: Hero(
              tag: "logo",
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.backgroundDark.withOpacity(0.3)
                          : AppColors.textSecondaryLight.withOpacity(0.6),
                      blurRadius: 40,
                      spreadRadius: 6,
                    ),
                  ],
                ),
                child: Image.asset("assets/images/logo.png", width: 150),
              ),
            ),
          ),
          const SizedBox(height: 25),
          Text(
            "Meducyte",
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.backgroundLight
                  : AppColors.primaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
