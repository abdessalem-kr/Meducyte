import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:meducyte_app/features/learn/presentation/utils/lesson_pdf_generator.dart';
import 'package:meducyte_app/features/quiz/domain/models/highlight_model.dart';
import 'package:flutter/material.dart' show Color;

void main() {
  group('LessonPdfGenerator Helper Tests', () {
    final mockRegularFont = pw.Font.helvetica();
    final mockBoldFont = pw.Font.helveticaBold();

    test('should strip Quill JSON string format gracefully', () {
      // Valid quill delta — extracts plain text
      expect(
        LessonPdfGenerator.stripQuillJson('[{"insert": "Hello\\n"}]'),
        'Hello',
      );
      // Plain text — returned as-is
      expect(LessonPdfGenerator.stripQuillJson('Plain text note'), 'Plain text note');
    });

    test('should build text spans correctly without highlights', () {
      final spans = LessonPdfGenerator.buildTextSpans(
        'Normal clinical content.',
        [],
        true,
        12.0,
        PdfColors.yellow,
        mockRegularFont,
      );

      expect(spans.length, 1);
      expect((spans.first as pw.TextSpan).text, 'Normal clinical content.');
    });

    test('should build text spans correctly with highlights included', () {
      final highlights = [
        HighlightModel(
          id: '1',
          text: 'clinical',
          start: 7,
          end: 15,
          color: const Color(0xFFFFCC00),
        ),
      ];

      final spans = LessonPdfGenerator.buildTextSpans(
        'Normal clinical content.',
        highlights,
        true,
        12.0,
        PdfColors.yellow,
        mockRegularFont,
      );

      expect(spans.length, 3);
      expect((spans[0] as pw.TextSpan).text, 'Normal ');
      expect((spans[1] as pw.TextSpan).text, 'clinical');
      expect((spans[1] as pw.TextSpan).style!.background, isNotNull);
      expect((spans[2] as pw.TextSpan).text, ' content.');
    });

    test('should parse paragraph content into separate segments', () {
      const content = 'Text segment.\n'
          '| Column A | Column B |\n'
          '|---|---|\n'
          '| Value A | Value B |\n'
          '![Alt Text](https://example.com/image.png)';

      final segments = parsePdfSegments(content);

      expect(segments.length, 3);
      expect(segments[0].type, 'text');
      expect(segments[1].type, 'table');
      expect(segments[2].type, 'image');
    });

    test('should build a structured table widget from markdown', () {
      const markdown = '| Col 1 | Col 2 |\n'
          '|---|---|\n'
          '| Val 1 | Val 2 |';

      final tableWidget = LessonPdfGenerator.buildPdfTable(
        markdown,
        12.0,
        PdfColors.teal,
        regularFont: mockRegularFont,
        boldFont: mockBoldFont,
      );

      expect(tableWidget, isA<pw.Table>());
    });

    test('should support compact table layout option and custom tint', () {
      const markdown = '| Col 1 | Col 2 |\n'
          '|---|---|\n'
          '| Val 1 | Val 2 |';

      final tableWidget = LessonPdfGenerator.buildPdfTable(
        markdown,
        12.0,
        PdfColors.teal,
        compactTables: true,
        tableRowTint: PdfColors.amber50,
        regularFont: mockRegularFont,
        boldFont: mockBoldFont,
      );

      expect(tableWidget, isA<pw.Table>());
    });
  });
}
