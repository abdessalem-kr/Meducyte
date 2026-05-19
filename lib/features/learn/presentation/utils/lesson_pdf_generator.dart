import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:meducyte_app/features/learn/domain/models/course.dart';

class LessonPdfGenerator {
  static Future<void> printLesson(LearnLesson lesson) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text(
                lesson.title,
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 20),
            ...(lesson.paragraphs ?? []).map((paragraph) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(
                    margin: const pw.EdgeInsets.symmetric(vertical: 8),
                    child: pw.Text(
                      paragraph.content,
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                  ),
                  if (paragraph.myNote != null)
                    pw.Container(
                      margin: const pw.EdgeInsets.only(
                        left: 16,
                        top: 4,
                        bottom: 12,
                      ),
                      padding: const pw.EdgeInsets.all(8),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.amber50,
                        border: pw.Border(
                          left: pw.BorderSide(color: PdfColors.amber, width: 2),
                        ),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            "My Note:",
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.amber900,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            //Note:We are just stripping JSON if it is a quill note for simplicity in this basic PDF export.
                            //In a full implementation,we might want a quill-to-pdf converter.
                            _stripQuillJson(paragraph.myNote!.text ?? ''),
                            style: pw.TextStyle(
                              fontSize: 11,
                              fontStyle: pw.FontStyle.italic,
                              color: PdfColors.grey800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  pw.SizedBox(height: 12),
                ],
              );
            }),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: '${lesson.title}.pdf',
    );
  }

  static String _stripQuillJson(String content) {
    if (content.trim().startsWith('[') || content.trim().startsWith('{')) {
      //Basic heuristic:try to extract text from common quill delta ops
      //For a better implementation,use a proper parser.
      //This is a placeholder that basically says"Rich Text Content"
      return "[Rich Text Note Content]";
    }
    return content;
  }
}
