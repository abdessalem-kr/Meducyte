import 'package:flutter_test/flutter_test.dart';
import 'package:meducyte_app/features/learn/presentation/screens/course_reader_screen.dart';
import 'package:meducyte_app/features/learn/domain/models/course.dart';

void main() {
  group('parseParagraphContent Tests', () {
    test('should parse plain text into TextSegment', () {
      final segments = parseParagraphContent('This is a plain prose paragraph.');
      expect(segments.length, 1);
      expect(segments[0], isA<TextSegment>());
      expect((segments[0] as TextSegment).text, 'This is a plain prose paragraph.');
    });

    test('should parse markdown block elements into MarkdownBlockSegment', () {
      const markdown = '# Heading 1\n'
          '## Heading 2\n'
          '- Bullet item 1\n'
          '- Bullet item 2\n'
          '1. Numbered item 1\n'
          '> Blockquote line\n'
          '```dart\n'
          'void main() {}\n'
          '```';

      final segments = parseParagraphContent(markdown);
      expect(segments.length, 1);
      expect(segments[0], isA<MarkdownBlockSegment>());
      expect(
        (segments[0] as MarkdownBlockSegment).markdown,
        markdown,
      );
    });

    test('should separate plain text and markdown blocks', () {
      const content = 'Plain paragraph start.\n\n'
          '# Heading block\n'
          '- List item\n\n'
          'Plain paragraph end.';

      final segments = parseParagraphContent(content);
      expect(segments.length, 3);
      expect(segments[0], isA<TextSegment>());
      expect(segments[1], isA<MarkdownBlockSegment>());
      expect(segments[2], isA<TextSegment>());

      expect((segments[0] as TextSegment).text, 'Plain paragraph start.\n');
      expect(
        (segments[1] as MarkdownBlockSegment).markdown,
        '# Heading block\n- List item\n',
      );
      expect((segments[2] as TextSegment).text, 'Plain paragraph end.');
    });

    test('should correctly parse tables and images', () {
      const content = '| Header A | Header B |\n'
          '|---|---|\n'
          '| Val A | Val B |\n'
          '![Alt text](https://example.com/image.png)';

      final segments = parseParagraphContent(content);
      expect(segments.length, 2);
      expect(segments[0], isA<TableSegment>());
      expect(segments[1], isA<ImageSegment>());

      expect((segments[0] as TableSegment).markdownTable, '| Header A | Header B |\n|---|---|\n| Val A | Val B |');
      expect((segments[1] as ImageSegment).altText, 'Alt text');
      expect((segments[1] as ImageSegment).imageUrl, 'https://example.com/image.png');
    });
  });

  group('LearnParagraph.fromJson Serialization Tests', () {
    test('should merge separate tables and images into paragraph content', () {
      final json = {
        'id': '123',
        'title': 'Paragraph Title',
        'content': 'Paragraph intro content.',
        'order': 1,
        'has_quiz': true,
        'tables': [
          {'markdown': '| Col 1 | Col 2 |\n|---|---|\n| A | B |'}
        ],
        'images': [
          {'url': 'https://example.com/img1.png', 'alt': 'Alt Info'}
        ],
        'my_highlights': '[]'
      };

      final paragraph = LearnParagraph.fromJson(json);
      expect(paragraph.id, '123');
      expect(paragraph.title, 'Paragraph Title');
      expect(paragraph.order, 1);
      expect(paragraph.hasQuiz, true);

      // Verify that content got successfully combined with table and image markup
      expect(paragraph.content, contains('Paragraph intro content.'));
      expect(paragraph.content, contains('| Col 1 | Col 2 |'));
      expect(paragraph.content, contains('![Alt Info](https://example.com/img1.png)'));

      // Validate parsed segments
      final segments = parseParagraphContent(paragraph.content);
      expect(segments.length, 3);
      expect(segments[0], isA<TextSegment>());
      expect(segments[1], isA<TableSegment>());
      expect(segments[2], isA<ImageSegment>());
    });

    test('should handle missing tables/images safely', () {
      final json = {
        'id': '124',
        'content': 'Just text.',
        'order': 2,
      };

      final paragraph = LearnParagraph.fromJson(json);
      expect(paragraph.content, 'Just text.');
      final segments = parseParagraphContent(paragraph.content);
      expect(segments.length, 1);
      expect(segments[0], isA<TextSegment>());
    });
  });
}
