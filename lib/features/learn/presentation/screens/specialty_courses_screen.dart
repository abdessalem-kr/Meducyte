import 'package:meducyte_app/export.dart';

class SpecialtyCoursesScreen extends ConsumerWidget {
  final String specialtyName;

  const SpecialtyCoursesScreen({super.key, required this.specialtyName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //Legacy screen-UI is now unified in the new Learn hub
    return Scaffold(
      appBar: AppBar(title: Text(specialtyName)),
      body: const Center(child: Text('Coming Soon in the new Learn Hub')),
    );
  }
}
