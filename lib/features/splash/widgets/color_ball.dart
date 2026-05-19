import 'dart:math';
import 'dart:ui';
import 'package:meducyte_app/export.dart';

class ColorBall extends StatelessWidget {
  const ColorBall({
    super.key,
    required this.gradientController,
    this.radius = 1,
    this.addsin = 0.5,
    this.addcos = 0.5,
    this.darkopacity = 0.5,
    this.lightopacity = 0.5,
    this.darkcolor = AppColors.accentLight,
    this.lightcolor = AppColors.accentLight,
  });

  final AnimationController gradientController;
  final double radius;
  final double addsin;
  final double addcos;
  final double darkopacity;
  final double lightopacity;
  final Color darkcolor;
  final Color lightcolor;

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 100, sigmaY: 10),
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            tileMode: TileMode.clamp,
            center: Alignment(
              sin((gradientController.value + addsin) * 2 * pi),
              cos((gradientController.value + addcos) * 2 * pi),
            ),
            radius: radius,
            stops: [0.3, 0.7],
            colors: [
              Theme.of(context).brightness == Brightness.dark
                  ? darkcolor.withOpacity(darkopacity)
                  : lightcolor.withOpacity(lightopacity),
              Theme.of(context).brightness == Brightness.dark
                  ? Colors.black.withOpacity(0.2)
                  : Colors.white.withOpacity(0.2),
            ],
          ),
        ),
      ),
    );
  }
}
