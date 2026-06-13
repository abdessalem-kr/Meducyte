import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/core/themes/quiz_theme_extension.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'dart:convert';

class QuillSimpleViewer extends StatelessWidget {
  final String content;
  final Color textColor;
  final double fontSize;

  const QuillSimpleViewer({
    super.key,
    required this.content,
    required this.textColor,
    this.fontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    if (content.isEmpty) return const SizedBox.shrink();

    final isJson =
        content.trim().startsWith('[') || content.trim().startsWith('{');
    if (isJson) {
      try {
        final doc = Document.fromJson(jsonDecode(content));
        return QuillEditor.basic(
          controller: QuillController(
            document: doc,
            selection: const TextSelection.collapsed(offset: 0),
            readOnly: true,
          ),
          config: QuillEditorConfig(
            autoFocus: false,
            expands: false,
            padding: EdgeInsets.zero,
            showCursor: false,
            enableInteractiveSelection: false,
            customStyles: DefaultStyles(
              paragraph: DefaultTextBlockStyle(
                TextStyle(color: textColor, height: 1.4, fontSize: fontSize),
                const HorizontalSpacing(0, 0),
                const VerticalSpacing(0, 0),
                const VerticalSpacing(0, 0),
                null,
              ),
              h1: DefaultTextBlockStyle(
                TextStyle(
                  color: textColor,
                  fontSize: fontSize + 8,
                  fontWeight: FontWeight.bold,
                ),
                const HorizontalSpacing(0, 0),
                const VerticalSpacing(8, 2),
                const VerticalSpacing(0, 0),
                null,
              ),
              h2: DefaultTextBlockStyle(
                TextStyle(
                  color: textColor,
                  fontSize: fontSize + 6,
                  fontWeight: FontWeight.bold,
                ),
                const HorizontalSpacing(0, 0),
                const VerticalSpacing(6, 2),
                const VerticalSpacing(0, 0),
                null,
              ),
              h3: DefaultTextBlockStyle(
                TextStyle(
                  color: textColor,
                  fontSize: fontSize + 4,
                  fontWeight: FontWeight.bold,
                ),
                const HorizontalSpacing(0, 0),
                const VerticalSpacing(4, 2),
                const VerticalSpacing(0, 0),
                null,
              ),
            ),
          ),
        );
      } catch (e) {
        return Text(
          "[Preview Error:Invalid Format]",
          style: TextStyle(
            color: textColor.withOpacity(0.5),
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
        );
      }
    }

    return Text(
      content,
      style: TextStyle(color: textColor, height: 1.4, fontSize: fontSize),
    );
  }
}

class NoteEditorBottomSheet extends ConsumerStatefulWidget {
  final String initialValue;
  final Function(String) onSave;
  final VoidCallback? onDelete;
  final bool isGlobal;
  final String? title;
  final String? contextText;
  final String? autoAction;

  const NoteEditorBottomSheet({
    super.key,
    required this.initialValue,
    required this.onSave,
    this.onDelete,
    this.isGlobal = false,
    this.title,
    this.contextText,
    this.autoAction,
  });

  @override
  ConsumerState<NoteEditorBottomSheet> createState() =>
      _NoteEditorBottomSheetState();
}

class _NoteEditorBottomSheetState extends ConsumerState<NoteEditorBottomSheet> {
  late QuillController _controller;
  bool _isAiLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue.isNotEmpty) {
      try {
        final doc = Document.fromJson(jsonDecode(widget.initialValue));
        _controller = QuillController(
          document: doc,
          selection: const TextSelection.collapsed(offset: 0),
        );
      } catch (e) {
        final doc = Document()..insert(0, widget.initialValue);
        _controller = QuillController(
          document: doc,
          selection: const TextSelection.collapsed(offset: 0),
        );
      }
    } else {
      _controller = QuillController.basic();
    }

    if (widget.autoAction != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleAiAction(widget.autoAction!);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleAiAction(String action) async {
    if (widget.contextText == null &&
        (action == 'explain' ||
            action == 'summarize' ||
            action == 'mnemonic')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please select some text first or use this in a question context.",
          ),
        ),
      );
      return;
    }

    if (action == 'refine' && _controller.document.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please write some notes first to refine them."),
        ),
      );
      return;
    }

    setState(() => _isAiLoading = true);

    try {
      final currentNotePlain = _controller.document.toPlainText();
      final language = Localizations.localeOf(context).languageCode;

      final response = await ref
          .read(noteAiRepositoryProvider)
          .getAiResponse(
            action: action,
            contextText: widget.contextText ?? "",
            language: language,
            currentNote: currentNotePlain.trim(),
          );

      debugPrint("AI Response extracted: $response");

      dynamic deltaOperations;
      try {
        final decoded = jsonDecode(response);
        if (decoded is Map && decoded.containsKey('ops')) {
          deltaOperations = decoded['ops'];
        } else {
          deltaOperations = decoded;
        }
      } catch (e) {
        deltaOperations = response; //Fallback to plain text
      }

      if (deltaOperations is List) {
        //Create a temporary document to ensure valid Delta structure and terminal newline
        final tempDoc = Document.fromJson(deltaOperations);
        final incomingDelta = tempDoc.toDelta();

        if (action == 'refine') {
          //Replace entire content with refined version
          _controller.document.replace(
            0,
            _controller.document.length - 1,
            incomingDelta,
          );
        } else {
          //Append to end by merging Delta operations manually.
          //This is the most robust way across different quill/delta versions.
          final currentOps = _controller.document.toDelta().toJson() as List;
          final incomingOps = incomingDelta.toJson() as List;

          final combinedOps = <Map<String, dynamic>>[];

          for (final op in currentOps) {
            combinedOps.add(Map<String, dynamic>.from(op as Map));
          }

          //Add separator
          if (combinedOps.isNotEmpty) {
            combinedOps.add({"insert": "\n---\n"});
          }

          for (final op in incomingOps) {
            combinedOps.add(Map<String, dynamic>.from(op as Map));
          }

          final finalDelta = Delta.fromJson(combinedOps);

          _controller.document.replace(
            0,
            _controller.document.length - 1,
            finalDelta,
          );
        }
      } else {
        //Fallback for plain text or malformed JSON
        _controller.document.insert(
          _controller.document.length - 1,
          deltaOperations.toString(),
        );
      }
    } catch (e) {
      if (mounted) {
        AppSnackBars.error(context, e);
      }
    } finally {
      if (mounted) {
        setState(() => _isAiLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final quizTheme = Theme.of(context).extension<QuizThemeExtension>()!;
    final l10n = AppLocalizations.of(context)!;
    final primaryColor = Theme.of(context).primaryColor;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: quizTheme.backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        children: [
          _buildHeader(context, l10n, primaryColor),
          _buildAiSmartBar(quizTheme, primaryColor),
          QuillSimpleToolbar(
            controller: _controller,
            config: const QuillSimpleToolbarConfig(
              showSearchButton: false,
              showFontFamily: false,
              showFontSize: false,
              showLink: false,
              showQuote: false,
              showCodeBlock: false,
              showInlineCode: false,
              showSubscript: false,
              showSuperscript: false,
              showDirection: false,
              multiRowsDisplay: false,
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: quizTheme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: quizTheme.secondaryTextColor.withOpacity(0.1),
                ),
              ),
              child: Stack(
                children: [
                  QuillEditor.basic(
                    controller: _controller,
                    config: QuillEditorConfig(
                      placeholder: 'Type your note here...',
                      autoFocus: true,
                      customStyles: DefaultStyles(
                        paragraph: DefaultTextBlockStyle(
                          TextStyle(
                            color: quizTheme.primaryTextColor,
                            height: 1.4,
                            fontSize: 15,
                          ),
                          const HorizontalSpacing(0, 0),
                          const VerticalSpacing(0, 0),
                          const VerticalSpacing(0, 0),
                          null,
                        ),
                        h1: DefaultTextBlockStyle(
                          TextStyle(
                            color: quizTheme.primaryTextColor,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          const HorizontalSpacing(0, 0),
                          const VerticalSpacing(8, 2),
                          const VerticalSpacing(0, 0),
                          null,
                        ),
                        h2: DefaultTextBlockStyle(
                          TextStyle(
                            color: quizTheme.primaryTextColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          const HorizontalSpacing(0, 0),
                          const VerticalSpacing(6, 2),
                          const VerticalSpacing(0, 0),
                          null,
                        ),
                        h3: DefaultTextBlockStyle(
                          TextStyle(
                            color: quizTheme.primaryTextColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          const HorizontalSpacing(0, 0),
                          const VerticalSpacing(4, 2),
                          const VerticalSpacing(0, 0),
                          null,
                        ),
                      ),
                    ),
                  ),
                  if (_isAiLoading)
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: quizTheme.backgroundColor.withOpacity(0.8),
                          shape: BoxShape.circle,
                        ),
                        child: CircularProgressIndicator(color: primaryColor),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiSmartBar(QuizThemeExtension quizTheme, Color primaryColor) {
    final hasContext =
        widget.contextText != null && widget.contextText!.isNotEmpty;
    final hasContent = _controller.document.length > 1;

    if (!hasContext && !hasContent) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.withOpacity(0.1)),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        children: [
          _AiActionButton(
            icon: Iconsax.magic_star,
            label: "Explain",
            onPressed: () => _handleAiAction('explain'),
            primaryColor: primaryColor,
          ),
          _AiActionButton(
            icon: Iconsax.document_text,
            label: "Summarize",
            onPressed: () => _handleAiAction('summarize'),
            primaryColor: primaryColor,
          ),
          _AiActionButton(
            icon: Iconsax.lamp_on,
            label: "Mnemonic",
            onPressed: () => _handleAiAction('mnemonic'),
            primaryColor: primaryColor,
          ),
          _AiActionButton(
            icon: Iconsax.brush_2,
            label: "Refine",
            onPressed: () => _handleAiAction('refine'),
            primaryColor: primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AppLocalizations l10n,
    Color primaryColor,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                const Icon(Iconsax.note, size: 20),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    widget.title ??
                        (widget.isGlobal ? "Question Note" : l10n.myNote),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.onDelete != null)
                IconButton(
                  onPressed: () {
                    widget.onDelete!();
                    Navigator.pop(context);
                  },
                  icon: const Icon(Iconsax.trash, size: 20, color: Colors.red),
                ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancel),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  final content = jsonEncode(
                    _controller.document.toDelta().toJson(),
                  );
                  widget.onSave(content);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(l10n.save),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AiActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color primaryColor;

  const _AiActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: primaryColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
