import 'dart:io';
import 'package:meducyte_app/export.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'question_share_card.dart';
import 'quiz_share_card.dart';
import '../../domain/models/share_theme.dart';
import 'package:gal/gal.dart';

class QuizExportBottomSheet extends StatefulWidget {
  final Question? question;
  final String? category;
  final int? accuracy;
  final int? correct;
  final int? incorrect;
  final int? total;
  final String? quizTitle;

  const QuizExportBottomSheet({
    super.key,
    this.question,
    this.category,
    this.accuracy,
    this.correct,
    this.incorrect,
    this.total,
    this.quizTitle,
  });

  @override
  State<QuizExportBottomSheet> createState() => _QuizExportBottomSheetState();
}

class _QuizExportBottomSheetState extends State<QuizExportBottomSheet> {
  ShareTheme _selectedTheme = ShareTheme.classic;
  bool _showAnswers = true;
  final double _quality = 100.0;
  bool _isExporting = false;
  bool _isSaving = false;
  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    if (widget.question == null) {
      _selectedTheme = ShareTheme.indigo;
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Export Settings',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          //Preview Area(Hidden,captures are done from widget directly)

          //Theme Selector
          Text(
            'Style',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildThemeOption(
                ShareTheme.classic,
                'Classic',
                Colors.white,
                Colors.black,
              ),
              _buildThemeOption(
                ShareTheme.dark,
                'Dark',
                const Color(0xFF1E1E1E),
                Colors.white,
              ),
              _buildThemeOption(
                ShareTheme.medical,
                'Medical',
                const Color(0xFFF0F7FF),
                const Color(0xFF0F172A),
              ),
              _buildThemeOption(
                ShareTheme.indigo,
                'Indigo',
                primaryColor,
                Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 24),

          if (widget.question != null) ...[
            //Answers Toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Show Correct Answer',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                Switch.adaptive(
                  value: _showAnswers,
                  onChanged: (val) => setState(() => _showAnswers = val),
                  activeColor: primaryColor,
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          const SizedBox(height: 32),

          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: primaryColor.withOpacity(0.2)),
                ),
                child: _isSaving
                    ? const Center(
                        child: SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : IconButton(
                        onPressed: _isExporting ? null : _handleSaveToGallery,
                        icon: const Icon(
                          Iconsax.document_download,
                          color: AppColors.primary,
                        ),
                        tooltip: 'Save to Gallery',
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isExporting || _isSaving ? null : _handleExport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isExporting
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'SHARE AS IMAGE',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    ShareTheme theme,
    String label,
    Color bg,
    Color text,
  ) {
    final isSelected = _selectedTheme == theme;
    return GestureDetector(
      onTap: () => setState(() => _selectedTheme = theme),
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: bg,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey[300]!,
                width: isSelected ? 3 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Center(
              child: Text(
                'Aa',
                style: TextStyle(
                  color: text,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleExport() async {
    setState(() => _isExporting = true);
    try {
      final pngBytes = await _screenshotController.captureFromWidget(
        Material(
          color: Colors.transparent,
          child: widget.question != null
              ? QuestionShareCard(
                  question: widget.question!,
                  category: widget.category,
                  showAnswers: _showAnswers,
                  theme: _selectedTheme,
                )
              : QuizShareCard(
                  accuracy: widget.accuracy ?? 0,
                  correct: widget.correct ?? 0,
                  incorrect: widget.incorrect ?? 0,
                  total: widget.total ?? 0,
                  quizTitle: widget.quizTitle,
                  theme: _selectedTheme,
                ),
        ),
        delay: const Duration(milliseconds: 300),
        pixelRatio: 3.0,
        context: context,
      );

      if (pngBytes.isEmpty) throw Exception("Failed to capture screenshot");

      //Convert PNG to JPG using image package
      final image = img.decodeImage(pngBytes);
      if (image == null) throw Exception("Failed to decode image");

      final jpgBytes = img.encodeJpg(image, quality: _quality.toInt());

      final tempDir = await getTemporaryDirectory();
      final fileName = widget.question != null
          ? 'question_${widget.question!.id}_${DateTime.now().millisecondsSinceEpoch}.jpg'
          : 'quiz_result_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final file = await File('${tempDir.path}/$fileName').create();
      await file.writeAsBytes(jpgBytes);

      if (mounted) {
        await Share.shareXFiles(
          [XFile(file.path)],
          text: widget.question != null
              ? 'Can you answer this medical question? 🧠🩺 #Meducyte#MedicalStudent'
              : 'I just completed a quiz on Meducyte! 🎓 #Meducyte#MedicalStudent',
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Export Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error exporting: $e')));
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _handleSaveToGallery() async {
    setState(() => _isSaving = true);
    try {
      final pngBytes = await _screenshotController.captureFromWidget(
        Material(
          color: Colors.transparent,
          child: widget.question != null
              ? QuestionShareCard(
                  question: widget.question!,
                  category: widget.category,
                  showAnswers: _showAnswers,
                  theme: _selectedTheme,
                )
              : QuizShareCard(
                  accuracy: widget.accuracy ?? 0,
                  correct: widget.correct ?? 0,
                  incorrect: widget.incorrect ?? 0,
                  total: widget.total ?? 0,
                  quizTitle: widget.quizTitle,
                  theme: _selectedTheme,
                ),
        ),
        delay: const Duration(milliseconds: 300),
        pixelRatio: 3.0,
        context: context,
      );

      if (pngBytes.isEmpty) throw Exception("Failed to capture screenshot");

      final image = img.decodeImage(pngBytes);
      if (image == null) throw Exception("Failed to decode image");

      final jpgBytes = img.encodeJpg(image, quality: 100);

      final tempDir = await getTemporaryDirectory();
      final fileName = widget.question != null
          ? 'question_${widget.question!.id}_${DateTime.now().millisecondsSinceEpoch}.jpg'
          : 'quiz_result_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final file = await File('${tempDir.path}/$fileName').create();
      await file.writeAsBytes(jpgBytes);

      await Gal.putImage(file.path);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image saved to gallery!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Save Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
