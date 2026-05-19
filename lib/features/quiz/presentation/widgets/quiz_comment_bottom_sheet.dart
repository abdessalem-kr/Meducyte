import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/core/themes/quiz_theme_extension.dart';
import 'package:meducyte_app/features/quiz/domain/models/comment_model.dart';
import 'package:intl/intl.dart';
import 'package:meducyte_app/features/quiz/presentation/widgets/note_editor_widgets.dart';

class QuizCommentBottomSheet extends ConsumerStatefulWidget {
  final int initialTabIndex;
  final String questionId;
  final String? questionContext;
  const QuizCommentBottomSheet({
    super.key,
    this.initialTabIndex = 0,
    required this.questionId,
    this.questionContext,
    this.initialCommentId,
  });

  final String? initialCommentId;

  @override
  ConsumerState<QuizCommentBottomSheet> createState() =>
      _QuizCommentBottomSheetState();
}

class _QuizCommentBottomSheetState
    extends ConsumerState<QuizCommentBottomSheet> {
  final _commentController = TextEditingController();
  final _focusNode = FocusNode();
  String? _editingCommentId;
  String? _replyingCommentId;
  String? _replyingAuthorName;
  bool _initialReplyShown = false;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _commentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    if (_editingCommentId != null) {
      ref
          .read(quizSessionProvider.notifier)
          .editComment(_editingCommentId!, text);
      setState(() {
        _editingCommentId = null;
      });
    } else {
      ref
          .read(quizSessionProvider.notifier)
          .addComment(
            int.parse(widget.questionId),
            text,
            parentId: _replyingCommentId,
          );
      setState(() {
        _replyingCommentId = null;
        _replyingAuthorName = null;
      });
    }
    _commentController.clear();
    _focusNode.unfocus();
  }

  void _startEditingComment(CommentModel comment) {
    setState(() {
      _editingCommentId = comment.id;
      _replyingCommentId = null;
      _replyingAuthorName = null;
      _commentController.text = comment.text;
    });
    _focusNode.requestFocus();
  }

  void _startReplying(CommentModel comment) {
    setState(() {
      _replyingCommentId = comment.id;
      _replyingAuthorName = comment.author;
      _editingCommentId = null;
      _commentController.clear();
    });
    _focusNode.requestFocus();
  }

  void _startEditingNote(String textId, HighlightModel highlight) {
    _showNoteEditor(
      initialValue: highlight.note ?? '',
      onSave: (newNote) {
        ref
            .read(quizSessionProvider.notifier)
            .updateHighlightNote(
              int.parse(widget.questionId),
              textId,
              highlight.id,
              newNote,
            );
      },
      onDelete: () {
        ref
            .read(quizSessionProvider.notifier)
            .removeHighlight(
              int.parse(widget.questionId),
              textId,
              highlight.id,
            );
      },
      contextText: highlight.text,
    );
  }

  void _startEditingGlobalNote(String? currentNote) {
    _showNoteEditor(
      initialValue: currentNote ?? '',
      onSave: (newNote) {
        ref
            .read(quizSessionProvider.notifier)
            .updateQuestionNote(int.parse(widget.questionId), newNote);
      },
      onDelete: () {
        ref
            .read(quizSessionProvider.notifier)
            .updateQuestionNote(int.parse(widget.questionId), '');
      },
      isGlobal: true,
      contextText: widget.questionContext,
    );
  }

  void _showNoteEditor({
    required String initialValue,
    required Function(String) onSave,
    VoidCallback? onDelete,
    bool isGlobal = false,
    String? contextText,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NoteEditorBottomSheet(
        initialValue: initialValue,
        onSave: onSave,
        onDelete: onDelete,
        isGlobal: isGlobal,
        contextText: contextText,
      ),
    );
  }

  void _cancelEditing() {
    setState(() {
      _editingCommentId = null;
      _replyingCommentId = null;
      _replyingAuthorName = null;
      _commentController.clear();
    });
    _focusNode.unfocus();
  }

  CommentModel? _findComment(List<CommentModel> comments, String id) {
    for (var comment in comments) {
      if (comment.id == id) return comment;
      final reply = _findComment(comment.replies, id);
      if (reply != null) return reply;
    }
    return null;
  }

  void _confirmDeleteComment(BuildContext context, String commentId) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmDelete),
        content: Text(l10n.deleteCommentConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              ref.read(quizSessionProvider.notifier).deleteComment(commentId);
              Navigator.pop(context);
            },
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showReportBottomSheet(String commentId) {
    final quizTheme = Theme.of(context).extension<QuizThemeExtension>()!;
    final reasons = [
      "Harassment",
      "Spam",
      "Inappropriate content",
      "Misinformation",
      "Other",
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: quizTheme.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text(
                "Report Comment",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 4),
              child: Text(
                "Why are you reporting this comment?",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
            ...reasons.map(
              (reason) => ListTile(
                leading: Icon(
                  Iconsax.danger,
                  color: quizTheme.secondaryTextColor,
                ),
                title: Text(reason),
                onTap: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  Navigator.pop(context);
                  try {
                    await ref
                        .read(quizSessionProvider.notifier)
                        .reportComment(commentId, reason);
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text("Comment reported successfully"),
                      ),
                    );
                  } catch (e) {
                    messenger.showSnackBar(
                      SnackBar(content: Text("Failed to report: $e")),
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final quizState = ref.watch(quizSessionProvider);
    final quizTheme = Theme.of(context).extension<QuizThemeExtension>()!;
    final l10n = AppLocalizations.of(context)!;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    if (!_initialReplyShown &&
        widget.initialCommentId != null &&
        quizState.comments.isNotEmpty) {
      final comment = _findComment(
        quizState.comments,
        widget.initialCommentId!,
      );
      if (comment != null) {
        _initialReplyShown = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _startReplying(comment);

          //Scroll to comment
          final index = quizState.comments.indexWhere(
            (c) => c.id == comment.id,
          );
          if (index != -1 && _scrollController.hasClients) {
            _scrollController.animateTo(
              index * 100.0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
            );
          }
        });
      }
    }

    final List<MapEntry<String, HighlightModel>> notesHighlights = [];
    quizState.highlights.forEach((textId, list) {
      for (var h in list) {
        if (h.note != null && h.note!.isNotEmpty) {
          notesHighlights.add(MapEntry(textId, h));
        }
      }
    });
    notesHighlights.sort(
      (a, b) => b.value.createdAt.compareTo(a.value.createdAt),
    );

    return DefaultTabController(
      length: 2,
      initialIndex: widget.initialTabIndex,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        padding: EdgeInsets.only(bottom: bottomPadding),
        decoration: BoxDecoration(
          color: quizTheme.backgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            _buildHandle(quizTheme),
            _buildHeader(l10n, quizTheme),
            TabBar(
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: quizTheme.secondaryTextColor,
              indicatorColor: Theme.of(context).primaryColor,
              indicatorSize: TabBarIndicatorSize.label,
              tabs: [
                Tab(text: l10n.commentsFeed),
                Tab(text: l10n.myNotes),
              ],
            ),
            const Divider(height: 1),
            Expanded(
              child: TabBarView(
                children: [
                  _buildCommentsTab(quizState, quizTheme, l10n),
                  _buildNotesTab(notesHighlights, quizTheme, l10n),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle(QuizThemeExtension quizTheme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: quizTheme.secondaryTextColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n, QuizThemeExtension quizTheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            l10n.interactionSpace,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Iconsax.close_circle,
              color: quizTheme.secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsTab(
    QuizSessionState quizState,
    QuizThemeExtension quizTheme,
    AppLocalizations l10n,
  ) {
    final topLevelComments = quizState.comments
        .where((c) => c.parentId == null)
        .toList();

    return Column(
      children: [
        Expanded(
          child: topLevelComments.isEmpty
              ? _buildEmptyState(l10n, quizTheme)
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  controller: _scrollController,
                  itemCount: topLevelComments.length,
                  itemBuilder: (context, index) {
                    return _CommentTree(
                      key: ValueKey(topLevelComments[index].id),
                      comment: topLevelComments[index],
                      quizTheme: quizTheme,
                      onEdit: () =>
                          _startEditingComment(topLevelComments[index]),
                      onDelete: () => _confirmDeleteComment(
                        context,
                        topLevelComments[index].id,
                      ),
                      onReply: () => _startReplying(topLevelComments[index]),
                      onVote: (vote) => ref
                          .read(quizSessionProvider.notifier)
                          .voteComment(topLevelComments[index].id, vote),
                      onReport: () =>
                          _showReportBottomSheet(topLevelComments[index].id),
                      onEditChild: (c) => _startEditingComment(c),
                      onDeleteChild: (id) => _confirmDeleteComment(context, id),
                      onReplyChild: (c) => _startReplying(c),
                      onReportChild: (id) => _showReportBottomSheet(id),
                    );
                  },
                ),
        ),
        _buildInputSection(quizTheme, l10n),
      ],
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n, QuizThemeExtension quizTheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.messages_2,
            size: 48,
            color: quizTheme.secondaryTextColor.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noComments,
            style: TextStyle(color: quizTheme.secondaryTextColor),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesTab(
    List<MapEntry<String, HighlightModel>> notes,
    QuizThemeExtension quizTheme,
    AppLocalizations l10n,
  ) {
    final quizState = ref.watch(quizSessionProvider);
    final globalNote = quizState.questionNote;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              if (globalNote != null && globalNote.isNotEmpty) ...[
                _GlobalNoteTile(
                  note: globalNote,
                  quizTheme: quizTheme,
                  onEdit: () => _startEditingGlobalNote(globalNote),
                  onDelete: () => ref
                      .read(quizSessionProvider.notifier)
                      .removeQuestionNote(int.parse(widget.questionId)),
                ),
                const SizedBox(height: 16),
              ] else ...[
                _buildAddGlobalNoteButton(quizTheme),
                const SizedBox(height: 16),
              ],
              if (notes.isEmpty && (globalNote == null || globalNote.isEmpty))
                _buildEmptyNotesState(l10n, quizTheme)
              else
                ...notes.map((entry) {
                  final textId = entry.key;
                  final note = entry.value;
                  return _NoteTile(
                    note: note,
                    textId: textId,
                    quizTheme: quizTheme,
                    onEdit: () => _startEditingNote(textId, note),
                    onDelete: () => ref
                        .read(quizSessionProvider.notifier)
                        .removeHighlight(
                          int.parse(widget.questionId),
                          textId,
                          note.id,
                        ),
                  );
                }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddGlobalNoteButton(QuizThemeExtension quizTheme) {
    return GestureDetector(
      onTap: () => _startEditingGlobalNote(null),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.note_add,
              size: 20,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 8),
            Text(
              "Add Note to whole question",
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyNotesState(
    AppLocalizations l10n,
    QuizThemeExtension quizTheme,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 60),
        Icon(
          Iconsax.note_2,
          size: 48,
          color: quizTheme.secondaryTextColor.withOpacity(0.3),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.noNotes,
          style: TextStyle(color: quizTheme.secondaryTextColor),
        ),
      ],
    );
  }

  Widget _buildInputSection(
    QuizThemeExtension quizTheme,
    AppLocalizations l10n,
  ) {
    final isEditingComment = _editingCommentId != null;
    final isReplying = _replyingCommentId != null;
    final isSpecialMode = isEditingComment || isReplying;

    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        8,
        16,
        16 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: quizTheme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isSpecialMode)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0, left: 8.0),
              child: Row(
                children: [
                  Icon(
                    isReplying ? Iconsax.arrow_right_3 : Iconsax.edit,
                    size: 14,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isReplying
                        ? "Replying to$_replyingAuthorName"
                        : l10n.editComment,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _cancelEditing,
                    child: Icon(
                      Iconsax.close_circle,
                      size: 18,
                      color: quizTheme.secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: quizTheme.backgroundColor.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: _commentController,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText: isReplying
                          ? "Write a reply..."
                          : (isEditingComment
                                ? l10n.editComment
                                : l10n.addPublicComment),
                      hintStyle: TextStyle(
                        color: quizTheme.secondaryTextColor,
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    style: TextStyle(
                      color: quizTheme.primaryTextColor,
                      fontSize: 14,
                    ),
                    onSubmitted: (_) => _submit(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor,
                child: IconButton(
                  onPressed: _submit,
                  icon: Icon(
                    isEditingComment ? Iconsax.tick_circle : Iconsax.send_1,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CommentTree extends ConsumerStatefulWidget {
  final CommentModel comment;
  final QuizThemeExtension quizTheme;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onReply;
  final Function(int) onVote;
  final Function(CommentModel) onEditChild;
  final Function(String) onDeleteChild;
  final Function(CommentModel) onReplyChild;
  final VoidCallback onReport;
  final Function(String) onReportChild;
  final int depth;

  const _CommentTree({
    super.key,
    required this.comment,
    required this.quizTheme,
    required this.onEdit,
    required this.onDelete,
    required this.onReply,
    required this.onVote,
    required this.onEditChild,
    required this.onDeleteChild,
    required this.onReplyChild,
    required this.onReport,
    required this.onReportChild,
    this.depth = 0,
  });

  @override
  ConsumerState<_CommentTree> createState() => _CommentTreeState();
}

class _CommentTreeState extends ConsumerState<_CommentTree> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final hasReplies = widget.comment.replies.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CommentTile(
          comment: widget.comment,
          quizTheme: widget.quizTheme,
          onEdit: widget.onEdit,
          onDelete: widget.onDelete,
          onReply: widget.onReply,
          onVote: widget.onVote,
          onReport: widget.onReport,
          depth: widget.depth,
          showThreadLine: _isExpanded && hasReplies,
        ),
        if (hasReplies) ...[
          if (!_isExpanded)
            Padding(
              padding: const EdgeInsets.only(left: 40, bottom: 12),
              child: InkWell(
                onTap: () => setState(() => _isExpanded = true),
                child: Row(
                  children: [
                    Icon(
                      Iconsax.arrow_down_1,
                      size: 14,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "Show${widget.comment.replies.length}replies",
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              children: [
                ...widget.comment.replies.asMap().entries.map((entry) {
                  final index = entry.key;
                  final reply = entry.value;
                  final isLast = index == widget.comment.replies.length - 1;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ThreadConnector(
                        isLast: isLast,
                        quizTheme: widget.quizTheme,
                      ),
                      Expanded(
                        child: _CommentTree(
                          key: ValueKey(reply.id),
                          comment: reply,
                          quizTheme: widget.quizTheme,
                          depth: widget.depth + 1,
                          onEdit: () => widget.onEditChild(reply),
                          onDelete: () => widget.onDeleteChild(reply.id),
                          onReply: () => widget.onReplyChild(reply),
                          onVote: (vote) => ref
                              .read(quizSessionProvider.notifier)
                              .voteComment(reply.id, vote),
                          onEditChild: widget.onEditChild,
                          onDeleteChild: widget.onDeleteChild,
                          onReplyChild: widget.onReplyChild,
                          onReport: () => widget.onReportChild(reply.id),
                          onReportChild: widget.onReportChild,
                        ),
                      ),
                    ],
                  );
                }),
                Padding(
                  padding: const EdgeInsets.only(left: 24, bottom: 12),
                  child: InkWell(
                    onTap: () => setState(() => _isExpanded = false),
                    child: Row(
                      children: [
                        Icon(
                          Iconsax.arrow_up_2,
                          size: 14,
                          color: widget.quizTheme.secondaryTextColor
                              .withOpacity(0.5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "Hide replies",
                          style: TextStyle(
                            color: widget.quizTheme.secondaryTextColor
                                .withOpacity(0.5),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
        ],
      ],
    );
  }
}

class _ThreadConnector extends StatelessWidget {
  final bool isLast;
  final QuizThemeExtension quizTheme;
  const _ThreadConnector({required this.isLast, required this.quizTheme});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32, //Match avatar width
      //We use a specific height that aligns with the avatar center
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 40),
        child: CustomPaint(
          painter: _ThreadPainter(
            color: quizTheme.secondaryTextColor.withOpacity(0.15),
            isLast: isLast,
          ),
        ),
      ),
    );
  }
}

class _ThreadPainter extends CustomPainter {
  final Color color;
  final bool isLast;
  _ThreadPainter({required this.color, required this.isLast});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final path = Path();
    //Start at top center of the 32px width
    final centerX = size.width / 2;
    path.moveTo(centerX, 0);

    //Curve down and right to meet the reply avatar
    final curveAtY = 20.0;
    final hStretch = 16.0; //Extend to meet the reply tile's avatar start

    if (isLast) {
      path.lineTo(centerX, curveAtY - 8);
      path.quadraticBezierTo(centerX, curveAtY, centerX + 8, curveAtY);
      path.lineTo(centerX + hStretch, curveAtY);
    } else {
      path.lineTo(centerX, size.height);
      path.moveTo(centerX, curveAtY - 8);
      path.quadraticBezierTo(centerX, curveAtY, centerX + 8, curveAtY);
      path.lineTo(centerX + hStretch, curveAtY);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CommentTile extends StatelessWidget {
  final CommentModel comment;
  final QuizThemeExtension quizTheme;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onReply;
  final Function(int) onVote;
  final VoidCallback onReport;
  final int depth;
  final bool showThreadLine;

  const _CommentTile({
    required this.comment,
    required this.quizTheme,
    required this.onEdit,
    required this.onDelete,
    required this.onReply,
    required this.onVote,
    required this.onReport,
    this.depth = 0,
    this.showThreadLine = false,
  });

  @override
  Widget build(BuildContext context) {
    final isMe = comment.isMine;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 32,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Theme.of(
                      context,
                    ).primaryColor.withOpacity(0.1),
                    child: Text(
                      comment.author.isNotEmpty ? comment.author[0] : '?',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  if (showThreadLine)
                    Expanded(
                      child: Center(
                        child: Container(
                          width: 2,
                          color: quizTheme.secondaryTextColor.withOpacity(0.15),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        comment.author,
                        style: TextStyle(
                          color: quizTheme.primaryTextColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('HH:mm').format(comment.createdAt),
                        style: TextStyle(
                          color: quizTheme.secondaryTextColor,
                          fontSize: 11,
                        ),
                      ),
                      if (comment.isEdited) ...[
                        const SizedBox(width: 8),
                        Text(
                          "(${l10n.edited})",
                          style: TextStyle(
                            color: quizTheme.secondaryTextColor,
                            fontSize: 10,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    comment.text,
                    style: TextStyle(
                      color: quizTheme.primaryTextColor,
                      fontSize: 14,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _VoteWidget(
                        upvotes: comment.upvotes,
                        downvotes: comment.downvotes,
                        myVote: comment.myVote,
                        onVote: onVote,
                        quizTheme: quizTheme,
                      ),
                      GestureDetector(
                        onTap: onReply,
                        child: Text(
                          "Reply",
                          style: TextStyle(
                            color: quizTheme.secondaryTextColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (isMe) ...[
                        GestureDetector(
                          onTap: onEdit,
                          child: Text(
                            "Edit",
                            style: TextStyle(
                              color: quizTheme.secondaryTextColor,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: onDelete,
                          child: Text(
                            "Delete",
                            style: TextStyle(
                              color: Colors.red.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                      if (!isMe) ...[
                        GestureDetector(
                          onTap: onReport,
                          child: Text(
                            "Report",
                            style: TextStyle(
                              color: quizTheme.secondaryTextColor,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VoteWidget extends StatelessWidget {
  final int upvotes;
  final int downvotes;
  final int? myVote;
  final Function(int) onVote;
  final QuizThemeExtension quizTheme;

  const _VoteWidget({
    required this.upvotes,
    required this.downvotes,
    required this.myVote,
    required this.onVote,
    required this.quizTheme,
  });

  @override
  Widget build(BuildContext context) {
    final score = upvotes - downvotes;

    return Row(
      children: [
        GestureDetector(
          onTap: () => onVote(myVote == 1 ? 0 : 1),
          child: Icon(
            Iconsax.arrow_circle_up,
            size: 16,
            color: myVote == 1 ? Colors.orange : quizTheme.secondaryTextColor,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text(
            score.toString(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: myVote == 1
                  ? Colors.orange
                  : (myVote == -1 ? Colors.blue : quizTheme.secondaryTextColor),
            ),
          ),
        ),
        GestureDetector(
          onTap: () => onVote(myVote == -1 ? 0 : -1),
          child: Icon(
            Iconsax.arrow_circle_down,
            size: 16,
            color: myVote == -1 ? Colors.blue : quizTheme.secondaryTextColor,
          ),
        ),
      ],
    );
  }
}

class _NoteTile extends StatelessWidget {
  final HighlightModel note;
  final String textId;
  final QuizThemeExtension quizTheme;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _NoteTile({
    required this.note,
    required this.textId,
    required this.quizTheme,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: quizTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: quizTheme.secondaryTextColor.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 16,
                    decoration: BoxDecoration(
                      color: note.color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.selectionReminder,
                    style: TextStyle(
                      color: quizTheme.secondaryTextColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit();
                  } else if (value == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        const Icon(Iconsax.edit, size: 18),
                        const SizedBox(width: 8),
                        Text(l10n.edit),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(Iconsax.trash, size: 18, color: Colors.red),
                        const SizedBox(width: 8),
                        Text(
                          l10n.delete,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
                child: Icon(
                  Icons.more_vert,
                  size: 18,
                  color: quizTheme.secondaryTextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '"${note.text}"',
            style: TextStyle(
              color: quizTheme.primaryTextColor,
              fontStyle: FontStyle.italic,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          QuillSimpleViewer(
            content: note.note ?? '',
            textColor: quizTheme.primaryTextColor,
          ),
        ],
      ),
    );
  }
}

class _GlobalNoteTile extends StatelessWidget {
  final String note;
  final QuizThemeExtension quizTheme;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _GlobalNoteTile({
    required this.note,
    required this.quizTheme,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Iconsax.note_2, size: 16, color: Colors.blueAccent),
                  SizedBox(width: 8),
                  Text(
                    "Question Note",
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit();
                  } else if (value == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        const Icon(Iconsax.edit, size: 18),
                        const SizedBox(width: 8),
                        Text(l10n.edit),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(Iconsax.trash, size: 18, color: Colors.red),
                        const SizedBox(width: 8),
                        Text(
                          l10n.delete,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
                child: Icon(
                  Icons.more_vert,
                  size: 18,
                  color: quizTheme.secondaryTextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          QuillSimpleViewer(
            content: note,
            textColor: quizTheme.primaryTextColor,
            fontSize: 15,
          ),
        ],
      ),
    );
  }
}
