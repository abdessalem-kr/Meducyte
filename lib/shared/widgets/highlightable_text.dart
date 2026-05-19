import 'package:flutter/rendering.dart' show SelectedContent;
import 'package:meducyte_app/export.dart';
import 'package:flutter/gestures.dart'; //Required for TapGestureRecognizer

class HighlightableText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final List<HighlightModel> highlights;
  final Function(HighlightModel)? onHighlightTap;
  final Function(String selectedText)? onHighlight;
  final Function(String selectedText)? onNote;
  final VoidCallback? onTap;
  final TextAlign? textAlign;

  const HighlightableText({
    super.key,
    required this.text,
    required this.style,
    this.highlights = const [],
    this.onHighlightTap,
    this.onHighlight,
    this.onNote,
    this.onTap,
    this.textAlign,
  });

  @override
  State<HighlightableText> createState() => _HighlightableTextState();
}

class _HighlightableTextState extends State<HighlightableText> {
  SelectedContent? _lastSelection;
  final List<TapGestureRecognizer> _recognizers = [];
  List<InlineSpan>? _cachedSpans;
  String? _cachedText;
  List<HighlightModel>? _cachedHighlights;

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  void _disposeRecognizers() {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();
  }

  List<InlineSpan> _buildSpans() {
    //Basic caching to avoid rebuilding spans if input hasn't changed
    if (_cachedSpans != null &&
        _cachedText == widget.text &&
        _cachedHighlights == widget.highlights) {
      return _cachedSpans!;
    }

    _disposeRecognizers();
    final List<InlineSpan> spans = [];
    int currentPos = 0;

    final sortedHighlights = List<HighlightModel>.from(widget.highlights)
      ..sort((a, b) => a.start.compareTo(b.start));

    for (final highlight in sortedHighlights) {
      if (highlight.start > currentPos) {
        spans.add(
          TextSpan(text: widget.text.substring(currentPos, highlight.start)),
        );
      }

      if (highlight.end > currentPos) {
        final actualStart = highlight.start < currentPos
            ? currentPos
            : highlight.start;

        final recognizer = TapGestureRecognizer()
          ..onTap = () => widget.onHighlightTap?.call(highlight);
        _recognizers.add(recognizer);

        spans.add(
          TextSpan(
            text: widget.text.substring(actualStart, highlight.end),
            style: TextStyle(
              backgroundColor: highlight.color,
              decoration: highlight.note != null && highlight.note!.isNotEmpty
                  ? TextDecoration.underline
                  : null,
              decorationStyle: TextDecorationStyle.dashed,
            ),
            recognizer: recognizer,
          ),
        );
        currentPos = highlight.end;
      }
    }

    if (currentPos < widget.text.length) {
      spans.add(TextSpan(text: widget.text.substring(currentPos)));
    }

    _cachedSpans = spans;
    _cachedText = widget.text;
    _cachedHighlights = widget.highlights;
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.highlights.isEmpty && widget.onHighlight == null) {
      return Text(
        widget.text,
        style: widget.style,
        textAlign: widget.textAlign,
      );
    }

    final spans = _buildSpans();

    Widget textWidget = Text.rich(
      TextSpan(children: spans),
      style: widget.style,
      textAlign: widget.textAlign,
    );

    if (widget.onHighlight != null) {
      return SelectionArea(
        onSelectionChanged: (selection) => _lastSelection = selection,
        contextMenuBuilder: (context, selectableRegionState) {
          final l10n = AppLocalizations.of(context)!;
          final buttonItems = [
            ...selectableRegionState.contextMenuButtonItems,
            ContextMenuButtonItem(
              onPressed: () {
                selectableRegionState.hideToolbar();
                if (_lastSelection != null) {
                  widget.onHighlight!(_lastSelection!.plainText);
                }
              },
              label: l10n.highlight,
            ),
            ContextMenuButtonItem(
              onPressed: () {
                selectableRegionState.hideToolbar();
                if (_lastSelection != null) {
                  widget.onNote!(_lastSelection!.plainText);
                }
              },
              label: l10n.addNote,
            ),
          ];

          return AdaptiveTextSelectionToolbar.buttonItems(
            anchors: selectableRegionState.contextMenuAnchors,
            buttonItems: buttonItems,
          );
        },
        child: widget.onTap != null
            ? GestureDetector(
                onTap: widget.onTap,
                behavior: HitTestBehavior.translucent,
                child: textWidget,
              )
            : textWidget,
      );
    }

    return textWidget;
  }
}
