import 'package:meducyte_app/export.dart';

class LiquidBackground extends StatelessWidget {
  const LiquidBackground({
    super.key,
    required this.gradientController,
    required this.pulseController,
    required this.element,
  });

  final AnimationController gradientController;
  final AnimationController pulseController;

  final Widget element;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ///BACKGROUND:layered random gradients
        Stack(
          children: [
            //Layer 1
            ColorBall(
              gradientController: gradientController,
              addcos: 0.2,
              addsin: 0.1,
              darkcolor: AppColors.accentDark,
              lightcolor: AppColors.accentLight,
              darkopacity: 1,
              lightopacity: 1,
              radius: 1.2,
            ),
            //Layer 2
            ColorBall(
              gradientController: gradientController,
              addcos: 0.4,
              addsin: 0.3,
              darkcolor: AppColors.primary,
              lightcolor: AppColors.primaryDark,
              lightopacity: 1,
              darkopacity: 1,
            ),
            //Layer 3
            ColorBall(
              gradientController: gradientController,
              addcos: 0.6,
              addsin: 0.5,
              darkcolor: AppColors.primaryDark,
              lightcolor: Colors.blue,
              lightopacity: 1,
              darkopacity: 1,
            ),
            //Layer 4
            ColorBall(
              gradientController: gradientController,
              addcos: 0.8,
              addsin: 0.7,
              darkcolor: AppColors.accentDark,

              lightcolor: AppColors.accentLight,
              darkopacity: 0.4,
              lightopacity: 0.6,
            ),
            //Layer 5
            ColorBall(
              gradientController: gradientController,
              addcos: 0,
              addsin: 0,
              darkcolor: Colors.transparent,
              lightcolor: Colors.transparent,
              darkopacity: 1,
              radius: 0.0,
            ),
          ],
        ),

        ///ANIMATED GRID on top of gradients
        CustomPaint(
          isComplex: true,
          painter: GridPainter(animation: gradientController.value),
          size: Size.infinite,
        ),

        ///FOREGROUND:logo+text
        element,
      ],
    );
  }
}
