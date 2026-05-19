import 'package:meducyte_app/export.dart';

class GridPainter extends CustomPainter {
  final double animation;

  GridPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.013)
      ..strokeWidth = 1;

    const gridSize = 60;
    final offset = animation * gridSize;

    for (int x = -gridSize; x < size.width + gridSize; x += gridSize) {
      canvas.drawLine(
        Offset(x + offset, 0),
        Offset(x + offset, size.height),
        paint,
      );
    }

    for (int y = -gridSize; y < size.height + gridSize; y += gridSize) {
      canvas.drawLine(
        Offset(0, y + offset),
        Offset(size.width, y + offset),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant GridPainter oldDelegate) =>
      oldDelegate.animation != animation;
}
