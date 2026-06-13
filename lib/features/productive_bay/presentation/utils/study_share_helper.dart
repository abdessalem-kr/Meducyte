import 'dart:io';
import 'package:meducyte_app/export.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import '../widgets/study_invite_card.dart';

class StudyShareHelper {
  static final ScreenshotController _screenshotController = ScreenshotController();

  static Future<void> shareInviteCard(BuildContext context, StudyGroup group) async {
    // Show a loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  "Génération du Pass d'Étude...",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final pngBytes = await _screenshotController.captureFromWidget(
        Material(
          color: Colors.transparent,
          child: StudyInviteCard(group: group),
        ),
        delay: const Duration(milliseconds: 300),
        pixelRatio: 3.0,
        context: context,
      );

      // Pop the loading dialog
      if (context.mounted) {
        Navigator.pop(context);
      }

      if (pngBytes.isEmpty) throw Exception("Failed to capture card");

      // Convert PNG to JPG using image package for smaller size and better sharing compatibility
      final image = img.decodeImage(pngBytes);
      if (image == null) throw Exception("Failed to decode image");
      final jpgBytes = img.encodeJpg(image, quality: 95);

      final tempDir = await getTemporaryDirectory();
      final fileName = 'meducyte_pass_${group.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final file = await File('${tempDir.path}/$fileName').create();
      await file.writeAsBytes(jpgBytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: "Rejoins mon groupe d'étude Meducyte \"${group.title}\" avec le code d'invitation: ${group.id} ! 🧠📚 #Meducyte #StudyGroup",
      );
    } catch (e) {
      // Safely pop the loading dialog if it's still showing
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du partage : $e')),
        );
      }
    }
  }
}
