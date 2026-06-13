import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:iconsax/iconsax.dart';
import 'package:meducyte_app/features/observation/data/providers/pathology_assistant_provider.dart';
import 'package:meducyte_app/l10n/arb/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meducyte_app/features/observation/data/providers/observation_providers.dart';

class QuillInputField extends ConsumerStatefulWidget {
  final String label;
  final String initialValue;
  final ValueChanged<String> onChanged;
  final bool dense;
  final String? hint;
  final TextStyle? labelStyle;

  const QuillInputField({
    super.key,
    required this.label,
    required this.initialValue,
    required this.onChanged,
    this.dense = false,
    this.hint,
    this.labelStyle,
    this.fieldKey,
  });

  final String? fieldKey;

  @override
  ConsumerState<QuillInputField> createState() => _QuillInputFieldState();
}

class _QuillInputFieldState extends ConsumerState<QuillInputField> {
  late QuillController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _initController();

    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
      if (_focusNode.hasFocus) {
        ref.read(activeQuillControllerProvider.notifier).state = _controller;
        if (widget.fieldKey != null) {
          ref.read(focusedExamFieldProvider.notifier).state = widget.fieldKey;
        }
      } else {
        _flushChanges();
        //Only clear if we are the current active one
        if (ref.read(activeQuillControllerProvider) == _controller) {
          ref.read(activeQuillControllerProvider.notifier).state = null;
        }
        //Also clear focused field if it's ours
        if (widget.fieldKey != null &&
            ref.read(focusedExamFieldProvider) == widget.fieldKey) {
          ref.read(focusedExamFieldProvider.notifier).state = null;
        }
      }
    });

    _controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        final jsonStr = jsonEncode(_controller.document.toDelta().toJson());
        widget.onChanged(jsonStr);
      }
    });
  }

  void _flushChanges() {
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer?.cancel();
      final jsonStr = jsonEncode(_controller.document.toDelta().toJson());
      widget.onChanged(jsonStr);
    }
  }

  @override
  void didUpdateWidget(covariant QuillInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      //Check if the current controller's JSON is different from the new initialValue
      final currentJson = jsonEncode(_controller.document.toDelta().toJson());
      if (currentJson != widget.initialValue) {
        _controller.removeListener(_onControllerChanged);
        final oldController = _controller;
        _initController();
        //If we were focused,update the global provider with the new controller
        if (_focusNode.hasFocus) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              ref.read(activeQuillControllerProvider.notifier).state =
                  _controller;
            }
          });
        }
        _controller.addListener(_onControllerChanged);

        //Use a post-frame callback or delay to dispose to avoid issues if the editor is still rendering
        WidgetsBinding.instance.addPostFrameCallback((_) {
          oldController.dispose();
        });
      }
    }
  }

  void _initController() {
    if (widget.initialValue.isNotEmpty) {
      try {
        final doc = Document.fromJson(jsonDecode(widget.initialValue));
        _controller = QuillController(
          document: doc,
          selection: const TextSelection.collapsed(offset: 0),
        );
        return;
      } catch (e) {
        //If it was just plain text beforehand
        try {
          final doc = Document()..insert(0, widget.initialValue);
          _controller = QuillController(
            document: doc,
            selection: const TextSelection.collapsed(offset: 0),
          );
          return;
        } catch (_) {}
      }
    }
    _controller = QuillController.basic();
  }

  @override
  void dispose() {
    _flushChanges();
    _debounceTimer?.cancel();
    //We check if we can still access ref to clear the active controller
    //This prevents"Cannot use ref after the widget was disposed"
    try {
      if (mounted) {
        if (ref.read(activeQuillControllerProvider) == _controller) {
          ref.read(activeQuillControllerProvider.notifier).state = null;
        }
      }
    } catch (_) {
      //If ref is already disposed,we don't need to clear the provider
      //as the whole context is likely being destroyed.
    }
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<String?>(focusRequestProvider, (previous, next) {
      if (next != null && next == widget.fieldKey) {
        _focusNode.requestFocus();
        // Clear the focus request
        ref.read(focusRequestProvider.notifier).state = null;
      }
    });

    final theme = Theme.of(context);
    final borderColor = _isFocused ? theme.primaryColor : theme.dividerColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: Row(
              children: [
                Text(
                  widget.label,
                  style:
                      widget.labelStyle ??
                      theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: _isFocused
                            ? theme.primaryColor
                            : theme.textTheme.bodyMedium?.color,
                      ),
                ),
                if (widget.fieldKey != null) ...[
                  const SizedBox(width: 6),
                  Icon(
                    Iconsax.teacher,
                    size: 14,
                    color: _isFocused
                        ? theme.primaryColor
                        : theme.dividerColor.withOpacity(0.5),
                  ),
                ],
              ],
            ),
          ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: borderColor,
              width: _isFocused ? 2.0 : 1.0,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                constraints: BoxConstraints(minHeight: widget.dense ? 36 : 45),
                padding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: widget.dense ? 8 : 12,
                ),
                child: QuillEditor.basic(
                  controller: _controller,
                  focusNode: _focusNode,
                  config: QuillEditorConfig(
                    placeholder:
                        widget.hint ??
                        AppLocalizations.of(context)!.enterResultHint,
                    customStyles: DefaultStyles(
                      placeHolder: DefaultTextBlockStyle(
                        const TextStyle(fontSize: 12, color: Colors.grey),
                        const HorizontalSpacing(0, 0),
                        const VerticalSpacing(0, 0),
                        const VerticalSpacing(0, 0),
                        null,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
