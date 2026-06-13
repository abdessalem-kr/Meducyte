import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:meducyte_app/features/learn/domain/models/course.dart';
import 'package:meducyte_app/features/quiz/domain/models/highlight_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

enum PdfColorTheme {
  teal,
  navy,
  emerald,
  amber,
  charcoal,
}

enum PdfFontSize {
  small,
  medium,
  large,
}

enum PdfTypography {
  sansSerif,
  serif,
}

enum PdfLayoutColumns {
  single,
  double,
}

class LessonPdfGenerator {
  static Future<void> printLesson(
    LearnLesson lesson, {
    PdfColorTheme theme = PdfColorTheme.teal,
    PdfFontSize fontSize = PdfFontSize.medium,
    PdfTypography typography = PdfTypography.sansSerif,
    PdfLayoutColumns layoutColumns = PdfLayoutColumns.single,
    bool includeNotes = true,
    bool includeHighlights = true,
    bool includeCoverPage = true,
    bool useGutterMargin = false,
    bool compactTables = false,
  }) async {
    // 1. Fetch all image bytes in parallel before starting PDF generation
    final Map<String, Uint8List> imageBytesMap = {};
    final dio = Dio();
    
    // Parse paragraphs for image URLs
    final List<String> imageUrls = [];
    for (final paragraph in lesson.paragraphs ?? []) {
      for (final segment in parsePdfSegments(paragraph.content)) {
        if (segment is PdfImageSegment) {
          imageUrls.add(segment.imageUrl);
        }
      }
    }

    if (imageUrls.isNotEmpty) {
      try {
        final List<Future<void>> downloadTasks = imageUrls.map((url) async {
          try {
            final response = await dio.get<List<int>>(
              url,
              options: Options(responseType: ResponseType.bytes),
            );
            if (response.data != null) {
              imageBytesMap[url] = Uint8List.fromList(response.data!);
            }
          } catch (_) {
            // Silent fallback to placeholder
          }
        }).toList();
        await Future.wait(downloadTasks);
      } catch (_) {
        // Fallback for global failures
      }
    }

    // 2. Define Theme Colors
    PdfColor primaryColor;
    PdfColor accentColor;
    PdfColor noteBgColor;
    PdfColor highlightBgColor;
    PdfColor tableRowTint;

    switch (theme) {
      case PdfColorTheme.teal:
        primaryColor = PdfColor.fromHex('#0F9F90');
        accentColor = PdfColor.fromHex('#0B7C70');
        noteBgColor = PdfColor.fromHex('#F0FDF4');
        highlightBgColor = PdfColor.fromHex('#CCEAE7');
        tableRowTint = PdfColor.fromHex('#F4FBFB');
        break;
      case PdfColorTheme.navy:
        primaryColor = PdfColor.fromHex('#1E3A8A');
        accentColor = PdfColor.fromHex('#1D4ED8');
        noteBgColor = PdfColor.fromHex('#F0F9FF');
        highlightBgColor = PdfColor.fromHex('#D6E4FF');
        tableRowTint = PdfColor.fromHex('#F0F4FC');
        break;
      case PdfColorTheme.emerald:
        primaryColor = PdfColor.fromHex('#059669');
        accentColor = PdfColor.fromHex('#047857');
        noteBgColor = PdfColor.fromHex('#ECFDF5');
        highlightBgColor = PdfColor.fromHex('#D1FAE5');
        tableRowTint = PdfColor.fromHex('#F2FAF7');
        break;
      case PdfColorTheme.amber:
        primaryColor = PdfColor.fromHex('#D97706');
        accentColor = PdfColor.fromHex('#B45309');
        noteBgColor = PdfColor.fromHex('#FFFBEB');
        highlightBgColor = PdfColor.fromHex('#FEF3C7');
        tableRowTint = PdfColor.fromHex('#FDF8F0');
        break;
      case PdfColorTheme.charcoal:
        primaryColor = PdfColor.fromHex('#374151');
        accentColor = PdfColor.fromHex('#1F2937');
        noteBgColor = PdfColor.fromHex('#F9FAFB');
        highlightBgColor = PdfColor.fromHex('#E5E7EB');
        tableRowTint = PdfColor.fromHex('#F5F6F7');
        break;
    }

    // 3. Define Font Sizes
    double bodyFontSize;
    double titleFontSize;
    double noteFontSize;

    switch (fontSize) {
      case PdfFontSize.small:
        bodyFontSize = 10;
        titleFontSize = 18;
        noteFontSize = 9;
        break;
      case PdfFontSize.medium:
        bodyFontSize = 12;
        titleFontSize = 22;
        noteFontSize = 11;
        break;
      case PdfFontSize.large:
        bodyFontSize = 14;
        titleFontSize = 26;
        noteFontSize = 13;
        break;
    }

    // 4. Load Custom Typography
    pw.Font regularFont = pw.Font.helvetica();
    pw.Font boldFont = pw.Font.helveticaBold();
    pw.Font italicFont = pw.Font.helveticaOblique();

    try {
      if (typography == PdfTypography.serif) {
        regularFont = await PdfGoogleFonts.merriweatherRegular();
        boldFont = await PdfGoogleFonts.merriweatherBold();
        italicFont = await PdfGoogleFonts.merriweatherItalic();
      } else {
        regularFont = await PdfGoogleFonts.interRegular();
        boldFont = await PdfGoogleFonts.interBold();
        italicFont = await PdfGoogleFonts.interItalic();
      }
    } catch (_) {
      // Offline fallback: Helvetica
    }

    // Define Document format and margins
    final pageFormat = PdfPageFormat.a4;
    final baseMargin = useGutterMargin
        ? const pw.EdgeInsets.only(left: 60, right: 35, top: 48, bottom: 48)
        : const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 48);

    // 5. Generate PDF document with custom theme fonts
    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: regularFont,
        bold: boldFont,
        italic: italicFont,
      ),
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        margin: baseMargin,
        header: (pw.Context context) {
          if (includeCoverPage && context.pageNumber == 1) {
            return pw.SizedBox.shrink();
          }
          return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(bottom: 20),
            decoration: pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
              ),
            ),
            padding: const pw.EdgeInsets.only(bottom: 6),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  "Meducyte - Clinical Study Material",
                  style: pw.TextStyle(
                    font: boldFont,
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                pw.Text(
                  lesson.title,
                  style: pw.TextStyle(
                    font: regularFont,
                    fontSize: 8,
                    color: PdfColors.grey600,
                  ),
                ),
              ],
            ),
          );
        },
        footer: (pw.Context context) {
          if (includeCoverPage && context.pageNumber == 1) {
            return pw.SizedBox.shrink();
          }
          return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 20),
            padding: const pw.EdgeInsets.only(top: 6),
            decoration: pw.BoxDecoration(
              border: pw.Border(
                top: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  "Generated on ${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}",
                  style: pw.TextStyle(
                    font: regularFont,
                    fontSize: 8,
                    color: PdfColors.grey500,
                  ),
                ),
                pw.Text(
                  "Page ${context.pageNumber} of ${context.pagesCount}",
                  style: pw.TextStyle(
                    font: regularFont,
                    fontSize: 8,
                    color: PdfColors.grey500,
                  ),
                ),
              ],
            ),
          );
        },
        build: (pw.Context context) {
          final lessonHeader = pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  lesson.title.toUpperCase(),
                  style: pw.TextStyle(
                    font: boldFont,
                    fontSize: titleFontSize,
                    fontWeight: pw.FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                pw.SizedBox(height: 6),
                if (lesson.module != null)
                  pw.Text(
                    "Module: ${lesson.module!.name}",
                    style: pw.TextStyle(
                      font: boldFont,
                      fontSize: bodyFontSize,
                      color: PdfColors.grey700,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                pw.SizedBox(height: 12),
                pw.Container(
                  height: 3,
                  width: 80,
                  color: primaryColor,
                ),
              ],
            ),
          );

          if (layoutColumns == PdfLayoutColumns.double) {
            // One pw.Partitions row per paragraph pair so MultiPage can
            // paginate between pairs without TooManyPagesException.
            final paragraphs = lesson.paragraphs ?? [];
            final List<pw.Widget> pairRows = [];

            pw.SpanningWidget buildCol(LearnParagraph paragraph) {
              final segments = parsePdfSegments(paragraph.content);
              final activeHighlights = paragraph.highlights;
              final hasNote = paragraph.myNote != null && includeNotes;
              final hasTitle =
                  paragraph.title != null && paragraph.title!.trim().isNotEmpty;

              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  if (hasTitle) ...[
                    pw.SizedBox(height: 12),
                    pw.Text(
                      paragraph.title!,
                      style: pw.TextStyle(
                        font: boldFont,
                        fontSize: bodyFontSize + 2,
                        fontWeight: pw.FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    pw.SizedBox(height: 6),
                  ],
                  ..._buildParagraphSegments(
                    segments,
                    activeHighlights,
                    includeHighlights,
                    bodyFontSize,
                    highlightBgColor,
                    primaryColor,
                    imageBytesMap,
                    compactTables,
                    tableRowTint,
                    regularFont,
                    boldFont,
                    italicFont,
                  ),
                  if (hasNote)
                    _buildFullNoteBox(
                      paragraph.myNote!.text ?? '',
                      noteFontSize,
                      primaryColor,
                      accentColor,
                      noteBgColor,
                      regularFont,
                      boldFont,
                      italicFont,
                    ),
                  pw.SizedBox(height: 16),
                ],
              );
            }

            for (int i = 0; i < paragraphs.length; i += 2) {
              final left = buildCol(paragraphs[i]);
              final right = i + 1 < paragraphs.length
                  ? buildCol(paragraphs[i + 1])
                  : pw.Column(children: []) as pw.SpanningWidget;

              pairRows.add(
                pw.Partitions(
                  children: [
                    pw.Partition(flex: 5, child: left),
                    pw.Partition(width: 20, child: pw.Column()),
                    pw.Partition(flex: 5, child: right),
                  ],
                ),
              );
            }

            return [
              if (includeCoverPage) ...[
                _buildCoverPage(
                  lesson,
                  primaryColor,
                  accentColor,
                  regularFont,
                  boldFont,
                  bodyFontSize,
                ),
                pw.NewPage(),
              ],
              lessonHeader,
              ...pairRows,
            ];
          } else {
            final List<pw.Widget> paragraphWidgets = (lesson.paragraphs ?? []).map((paragraph) {
              final segments = parsePdfSegments(paragraph.content);
              final activeHighlights = paragraph.highlights;
              final hasNote = paragraph.myNote != null && includeNotes;
              final hasTitle = paragraph.title != null && paragraph.title!.trim().isNotEmpty;

              final paragraphContent = pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  if (hasTitle) ...[
                    pw.SizedBox(height: 12),
                    pw.Text(
                      paragraph.title!,
                      style: pw.TextStyle(
                        font: boldFont,
                        fontSize: bodyFontSize + 2,
                        fontWeight: pw.FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    pw.SizedBox(height: 6),
                  ],
                  ..._buildParagraphSegments(
                    segments,
                    activeHighlights,
                    includeHighlights,
                    bodyFontSize,
                    highlightBgColor,
                    primaryColor,
                    imageBytesMap,
                    compactTables,
                    tableRowTint,
                    regularFont,
                    boldFont,
                    italicFont,
                  ),
                ],
              );

              final pw.Widget buildWidget;
              if (hasNote) {
                buildWidget = pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Partitions(
                      children: [
                        pw.Partition(
                          flex: 3,
                          child: paragraphContent,
                        ),
                        pw.Partition(
                          width: 20,
                          child: pw.Column(),
                        ),
                        pw.Partition(
                          width: 140,
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              _buildSideNoteBox(
                                paragraph.myNote!.text ?? '',
                                noteFontSize,
                                primaryColor,
                                accentColor,
                                noteBgColor,
                                regularFont,
                                boldFont,
                                italicFont,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 16),
                  ],
                );
              } else {
                buildWidget = pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    paragraphContent,
                    pw.SizedBox(height: 16),
                  ],
                );
              }

              return buildWidget;
            }).toList();

            return [
              if (includeCoverPage) ...[
                _buildCoverPage(
                  lesson,
                  primaryColor,
                  accentColor,
                  regularFont,
                  boldFont,
                  bodyFontSize,
                ),
                pw.NewPage(),
              ],
              lessonHeader,
              ...paragraphWidgets,
            ];
          }
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: '${lesson.title}.pdf',
    );
  }

  static List<pw.Widget> _buildParagraphSegments(
    List<PdfParagraphSegment> segments,
    List<HighlightModel> activeHighlights,
    bool includeHighlights,
    double fontSize,
    PdfColor highlightColor,
    PdfColor primaryColor,
    Map<String, Uint8List> imageBytesMap,
    bool compactTables,
    PdfColor tableRowTint,
    pw.Font regularFont,
    pw.Font boldFont,
    pw.Font italicFont,
  ) {
    final List<pw.Widget> widgets = [];
    for (int i = 0; i < segments.length; i++) {
      final segment = segments[i];
      if (segment is PdfTextSegment) {
        final segmentHighlights = activeHighlights
            .where((h) => h.start >= segment.startOffset && h.end <= segment.startOffset + segment.text.length)
            .map((h) => HighlightModel(
                  id: h.id,
                  text: h.text,
                  color: h.color,
                  start: h.start - segment.startOffset,
                  end: h.end - segment.startOffset,
                  note: h.note,
                ))
            .toList();

        widgets.add(
          pw.RichText(
            text: pw.TextSpan(
              children: buildTextSpans(
                segment.text,
                segmentHighlights,
                includeHighlights,
                fontSize,
                highlightColor,
                regularFont,
              ),
            ),
          ),
        );
      } else if (segment is PdfTableSegment) {
        widgets.add(
          buildPdfTable(
            segment.markdownTable,
            fontSize,
            primaryColor,
            compactTables: compactTables,
            tableRowTint: tableRowTint,
            regularFont: regularFont,
            boldFont: boldFont,
          ),
        );
      } else if (segment is PdfImageSegment) {
        final imageBytes = imageBytesMap[segment.imageUrl];
        widgets.add(
          _buildPdfImage(
            segment,
            imageBytes,
            fontSize,
            primaryColor,
            regularFont,
            italicFont,
          ),
        );
      }

      if (i < segments.length - 1) {
        widgets.add(pw.SizedBox(height: 12));
      }
    }
    return widgets;
  }

  static List<pw.InlineSpan> buildTextSpans(
    String text,
    List<HighlightModel> highlights,
    bool includeHighlights,
    double fontSize,
    PdfColor highlightColor,
    pw.Font regularFont,
  ) {
    if (!includeHighlights || highlights.isEmpty) {
      return [
        pw.TextSpan(
          text: text.replaceAll('\r', ''),
          style: pw.TextStyle(
            font: regularFont,
            fontSize: fontSize,
            height: 1.5,
            color: PdfColors.grey900,
          ),
        )
      ];
    }

    final sortedHighlights = List<HighlightModel>.from(highlights)
      ..sort((a, b) => a.start.compareTo(b.start));

    final List<pw.InlineSpan> spans = [];
    int currentIndex = 0;

    for (final highlight in sortedHighlights) {
      if (highlight.start >= text.length) continue;

      if (highlight.start > currentIndex) {
        spans.add(pw.TextSpan(
          text: text.substring(currentIndex, highlight.start).replaceAll('\r', ''),
          style: pw.TextStyle(
            font: regularFont,
            fontSize: fontSize,
            height: 1.5,
            color: PdfColors.grey900,
          ),
        ));
      }

      final end = highlight.end.clamp(0, text.length);
      if (end > highlight.start) {
        spans.add(pw.TextSpan(
          text: text.substring(highlight.start, end).replaceAll('\r', ''),
          style: pw.TextStyle(
            font: regularFont,
            fontSize: fontSize,
            height: 1.5,
            color: PdfColors.grey900,
            background: pw.BoxDecoration(
              color: highlightColor,
            ),
          ),
        ));
      }
      currentIndex = end;
    }

    if (currentIndex < text.length) {
      spans.add(pw.TextSpan(
        text: text.substring(currentIndex).replaceAll('\r', ''),
        style: pw.TextStyle(
          font: regularFont,
          fontSize: fontSize,
          height: 1.5,
          color: PdfColors.grey900,
        ),
      ));
    }

    return spans;
  }

  @visibleForTesting
  static pw.Widget buildPdfTable(
    String tableMarkdown,
    double fontSize,
    PdfColor primaryColor, {
    bool compactTables = false,
    PdfColor? tableRowTint,
    required pw.Font regularFont,
    required pw.Font boldFont,
  }) {
    final lines = tableMarkdown.trim().split('\n');
    final List<pw.TableRow> rows = [];
    final rowTint = tableRowTint ?? PdfColor.fromHex('#F9FAFB');

    final padding = compactTables
        ? const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 3)
        : const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6);

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.trim().isEmpty) continue;

      if (line.contains('---') || line.contains('-:-')) continue;

      final cells = line.split('|').map((c) => c.trim()).toList();

      if (cells.first.isEmpty) cells.removeAt(0);
      if (cells.isNotEmpty && cells.last.isEmpty) cells.removeLast();

      final isHeader = i == 0;

      rows.add(
        pw.TableRow(
          decoration: isHeader
              ? pw.BoxDecoration(color: primaryColor)
              : pw.BoxDecoration(
                  color: i % 2 == 0 ? rowTint : PdfColors.white,
                ),
          children: cells.map((cellText) {
            return pw.Padding(
              padding: padding,
              child: pw.Text(
                cellText,
                style: pw.TextStyle(
                  font: isHeader ? boldFont : regularFont,
                  fontSize: fontSize - 2,
                  fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
                  color: isHeader ? PdfColors.white : PdfColor.fromHex('#1F2937'),
                ),
              ),
            );
          }).toList(),
        ),
      );
    }

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      children: rows,
    );
  }

  static pw.Widget _buildPdfImage(
    PdfImageSegment segment,
    Uint8List? imageBytes,
    double fontSize,
    PdfColor primaryColor,
    pw.Font regularFont,
    pw.Font italicFont,
  ) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          if (imageBytes != null)
            pw.Image(
              pw.MemoryImage(imageBytes),
              height: 180,
              fit: pw.BoxFit.contain,
            )
          else
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              color: PdfColors.grey100,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(
                    "📷 ",
                    style: pw.TextStyle(font: regularFont, fontSize: fontSize),
                  ),
                  pw.Text(
                    segment.altText.isNotEmpty ? segment.altText : "Image not available",
                    style: pw.TextStyle(
                      font: italicFont,
                      fontSize: fontSize - 2,
                      fontStyle: pw.FontStyle.italic,
                      color: PdfColors.grey600,
                    ),
                  ),
                ],
              ),
            ),
          if (imageBytes != null && segment.altText.isNotEmpty)
            pw.Container(
              padding: const pw.EdgeInsets.all(6),
              color: PdfColors.grey50,
              child: pw.Text(
                segment.altText,
                style: pw.TextStyle(
                  font: italicFont,
                  fontSize: fontSize - 3,
                  fontStyle: pw.FontStyle.italic,
                  color: PdfColors.grey700,
                ),
                textAlign: pw.TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  static pw.Widget _buildFullNoteBox(
    String content,
    double fontSize,
    PdfColor primaryColor,
    PdfColor accentColor,
    PdfColor noteBgColor,
    pw.Font regularFont,
    pw.Font boldFont,
    pw.Font italicFont,
  ) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(
        left: 16,
        top: 8,
        bottom: 16,
      ),
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: noteBgColor,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border(
          left: pw.BorderSide(color: primaryColor, width: 4),
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            "Study Note:",
            style: pw.TextStyle(
              font: boldFont,
              fontSize: fontSize - 1,
              fontWeight: pw.FontWeight.bold,
              color: accentColor,
            ),
          ),
          pw.SizedBox(height: 6),
          _buildQuillRichContent(
            content,
            regularFont,
            boldFont,
            italicFont,
            fontSize: fontSize,
            defaultColor: PdfColors.grey800,
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSideNoteBox(
    String content,
    double fontSize,
    PdfColor primaryColor,
    PdfColor accentColor,
    PdfColor noteBgColor,
    pw.Font regularFont,
    pw.Font boldFont,
    pw.Font italicFont,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: noteBgColor,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
        border: pw.Border(
          left: pw.BorderSide(color: primaryColor, width: 3),
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            "Note",
            style: pw.TextStyle(
              font: boldFont,
              fontSize: fontSize - 2,
              fontWeight: pw.FontWeight.bold,
              color: accentColor,
            ),
          ),
          pw.SizedBox(height: 4),
          _buildQuillRichContent(
            content,
            regularFont,
            boldFont,
            italicFont,
            fontSize: fontSize - 1,
            defaultColor: PdfColors.grey800,
          ),
        ],
      ),
    );
  }

  /// Parses a note string which may be plain text or a Quill JSON delta.
  /// Returns a [pw.Column] of styled text lines ready for PDF embedding.
  static pw.Widget _buildQuillRichContent(
    String content,
    pw.Font regularFont,
    pw.Font boldFont,
    pw.Font italicFont, {
    double fontSize = 11,
    PdfColor defaultColor = PdfColors.grey800,
  }) {
    final trimmed = content.trim();
    if (trimmed.isEmpty) return pw.SizedBox.shrink();

    // Plain text fast-path
    if (!trimmed.startsWith('[') && !trimmed.startsWith('{')) {
      return pw.Text(
        trimmed.replaceAll('\r', ''),
        style: pw.TextStyle(
          font: regularFont,
          fontSize: fontSize,
          color: defaultColor,
        ),
      );
    }

    try {
      final List<dynamic> deltaJson = jsonDecode(trimmed);
      final doc = quill.Document.fromJson(deltaJson);
      final List<pw.Widget> lines = [];

      for (final node in doc.root.children) {
        if (node is quill.Line) {
          lines.add(
            _buildQuillLine(
              node,
              regularFont,
              boldFont,
              italicFont,
              fontSize,
              defaultColor,
            ),
          );
        } else if (node is quill.Block) {
          for (final child in node.children) {
            if (child is quill.Line) {
              lines.add(
                _buildQuillLine(
                  child,
                  regularFont,
                  boldFont,
                  italicFont,
                  fontSize,
                  defaultColor,
                  isListItem: true,
                ),
              );
            }
          }
        }
      }

      if (lines.isEmpty) return pw.SizedBox.shrink();
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: lines,
      );
    } catch (_) {
      // Fallback: strip and show plain text
      return pw.Text(
        stripQuillJson(trimmed),
        style: pw.TextStyle(
          font: regularFont,
          fontSize: fontSize,
          color: defaultColor,
        ),
      );
    }
  }

  static pw.Widget _buildQuillLine(
    quill.Line line,
    pw.Font regularFont,
    pw.Font boldFont,
    pw.Font italicFont,
    double baseFontSize,
    PdfColor defaultColor, {
    bool isListItem = false,
  }) {
    final attrs = line.style.attributes;
    double currentFontSize = baseFontSize;
    pw.Font currentBaseFont = regularFont;

    if (attrs.containsKey('header')) {
      final level = attrs['header']!.value;
      if (level == 1) {
        currentFontSize = baseFontSize * 1.4;
        currentBaseFont = boldFont;
      } else if (level == 2) {
        currentFontSize = baseFontSize * 1.2;
        currentBaseFont = boldFont;
      } else if (level == 3) {
        currentFontSize = baseFontSize * 1.1;
        currentBaseFont = boldFont;
      }
    }

    final spans = <pw.TextSpan>[];
    for (final leaf in line.children) {
      if (leaf is quill.Leaf) {
        final leafAttrs = leaf.style.attributes;
        final isBold = leafAttrs.containsKey('bold');
        final isItalic = leafAttrs.containsKey('italic');
        final text = leaf.toPlainText().replaceAll('\r', '');
        if (text.isEmpty) continue;
        spans.add(
          pw.TextSpan(
            text: text,
            style: pw.TextStyle(
              font: isBold
                  ? boldFont
                  : (isItalic ? italicFont : currentBaseFont),
              fontSize: currentFontSize,
              fontStyle:
                  isItalic ? pw.FontStyle.italic : pw.FontStyle.normal,
              color: defaultColor,
            ),
          ),
        );
      }
    }

    if (spans.isEmpty) return pw.SizedBox(height: 4);

    final richText = pw.RichText(
      text: pw.TextSpan(children: spans),
    );

    if (isListItem || attrs.containsKey('list')) {
      return pw.Padding(
        padding: const pw.EdgeInsets.only(left: 12, bottom: 2, top: 2),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              '• ',
              style: pw.TextStyle(font: boldFont, fontSize: currentFontSize),
            ),
            pw.Expanded(child: richText),
          ],
        ),
      );
    }

    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: richText,
    );
  }

  static pw.Widget _buildCoverPage(
    LearnLesson lesson,
    PdfColor primaryColor,
    PdfColor accentColor,
    pw.Font font,
    pw.Font boldFont,
    double baseFontSize,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 80),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(height: 60),
          // Clinical Header Tag
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: pw.BoxDecoration(
              color: primaryColor,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
            ),
            child: pw.Text(
              "MEDUCYTE COURSE READER",
              style: pw.TextStyle(
                font: boldFont,
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
            ),
          ),
          pw.SizedBox(height: 24),
          // Massive elegant title
          pw.Text(
            lesson.title,
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 32,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey900,
            ),
          ),
          pw.SizedBox(height: 16),
          // Decorative divider band
          pw.Container(
            height: 4,
            width: 120,
            color: primaryColor,
          ),
          pw.SizedBox(height: 32),
          // Clinical metadata details
          if (lesson.module != null) ...[
            pw.Text(
              "Study Module",
              style: pw.TextStyle(
                font: boldFont,
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey500,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              lesson.module!.name,
              style: pw.TextStyle(
                font: boldFont,
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey800,
              ),
            ),
            pw.SizedBox(height: 24),
          ],
          pw.Text(
            "Document Details",
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey500,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            "Export date: ${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}",
            style: pw.TextStyle(
              font: font,
              fontSize: 14,
              color: PdfColors.grey700,
            ),
          ),
          pw.SizedBox(height: 180),
          // Footer citation / watermark
          pw.Container(
            padding: const pw.EdgeInsets.only(top: 16),
            decoration: pw.BoxDecoration(
              border: pw.Border(
                top: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  "Confidential - Professional Use Only",
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 8,
                    fontStyle: pw.FontStyle.italic,
                    color: PdfColors.grey500,
                  ),
                ),
                pw.Text(
                  "© Meducyte Learning Systems",
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 8,
                    color: PdfColors.grey500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Strips Quill JSON delta and returns a human-readable placeholder.
  /// Used as a fallback in unit tests and edge cases.
  @visibleForTesting
  static String stripQuillJson(String content) {
    final trimmed = content.trim();
    if (trimmed.startsWith('[') || trimmed.startsWith('{')) {
      try {
        final List<dynamic> deltaJson = jsonDecode(trimmed);
        final doc = quill.Document.fromJson(deltaJson);
        final plain = doc.toPlainText().replaceAll('\r', '').trim();
        return plain.isNotEmpty ? plain : "[Rich Text Note Content]";
      } catch (_) {
        return "[Rich Text Note Content]";
      }
    }
    return content.replaceAll('\r', '');
  }
}

// Internal segments for PDF content parser
abstract class PdfParagraphSegment {
  final int startOffset;
  PdfParagraphSegment(this.startOffset);

  String get type;
}

class PdfTextSegment extends PdfParagraphSegment {
  final String text;
  PdfTextSegment(this.text, int startOffset) : super(startOffset);

  @override
  String get type => 'text';
}

class PdfTableSegment extends PdfParagraphSegment {
  final String markdownTable;
  PdfTableSegment(this.markdownTable, int startOffset) : super(startOffset);

  @override
  String get type => 'table';
}

class PdfImageSegment extends PdfParagraphSegment {
  final String altText;
  final String imageUrl;
  PdfImageSegment({
    required this.altText,
    required this.imageUrl,
    required int startOffset,
  }) : super(startOffset);

  @override
  String get type => 'image';
}

@visibleForTesting
List<PdfParagraphSegment> parsePdfSegments(String content) {
  final List<PdfParagraphSegment> segments = [];
  final lines = content.split('\n');

  int currentPos = 0;
  List<String> textBuffer = [];
  int textStartOffset = 0;

  List<String> tableBuffer = [];
  int tableStartOffset = 0;

  void flushText() {
    if (textBuffer.isNotEmpty) {
      final text = textBuffer.join('\n');
      segments.add(PdfTextSegment(text, textStartOffset));
      textBuffer.clear();
    }
  }

  void flushTable() {
    if (tableBuffer.isNotEmpty) {
      final table = tableBuffer.join('\n');
      segments.add(PdfTableSegment(table, tableStartOffset));
      tableBuffer.clear();
    }
  }

  for (int i = 0; i < lines.length; i++) {
    final line = lines[i];
    final trimmed = line.trim();

    final imageRegex = RegExp(r'^!\[(.*?)\]\((.*?)\)$');
    final imageMatch = imageRegex.firstMatch(trimmed);

    if (imageMatch != null) {
      flushTable();
      flushText();

      segments.add(PdfImageSegment(
        altText: imageMatch.group(1) ?? '',
        imageUrl: imageMatch.group(2) ?? '',
        startOffset: currentPos,
      ));
    } else {
      final isTableRow = trimmed.startsWith('|') && trimmed.endsWith('|') && trimmed.contains('|');

      if (isTableRow) {
        flushText();
        if (tableBuffer.isEmpty) {
          tableStartOffset = currentPos;
        }
        tableBuffer.add(line);
      } else {
        flushTable();
        if (textBuffer.isEmpty) {
          textStartOffset = currentPos;
        }
        textBuffer.add(line);
      }
    }

    currentPos += line.length + 1;
  }

  flushTable();
  flushText();

  return segments;
}
