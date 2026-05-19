// ------------------ROUNDED SECTION CONTAINER------------------
import 'package:flutter/material.dart';

class SectionContainer extends StatelessWidget {
  final List<Widget> children;
  const SectionContainer({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        //color:AppColors.primaryLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }
}
