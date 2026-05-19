import 'package:flutter/material.dart';

class Responsive {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 800;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 800 &&
      MediaQuery.of(context).size.width < 1200;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200;

  static int getGridCrossAxisCount(BuildContext context, {int minColumns = 2}) {
    double width = MediaQuery.of(context).size.width;

    //Account for NavigationRail width on tablet/desktop displays
    final adjustedWidth = width > 800 ? width - 90 : width;

    if (adjustedWidth >= 1100) return 4;
    if (adjustedWidth >= 700) return 3;
    return minColumns;
  }
}
