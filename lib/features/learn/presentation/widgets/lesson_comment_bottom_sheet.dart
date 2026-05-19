import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/core/themes/quiz_theme_extension.dart';
import 'package:meducyte_app/features/quiz/domain/models/comment_model.dart';
import 'package:meducyte_app/features/learn/presentation/providers/lesson_interaction_provider.dart';
import 'package:intl/intl.dart';
import 'package:meducyte_app/features/quiz/presentation/widgets/note_editor_widgets.dart';

class InteractionCommentBottomSheet extends ConsumerStatefulWidget {
  final String id;
  final InteractionType type;
  final String? title;
  final int initialTabIndex;
  final LearnLesson? lesson;
  final LearnModule? module;

  const InteractionCommentBottomSheet({
    super.key,
    required this.id,
    required this.type,
    this.title,
    this.initialTabIndex = 0,
    this.lesson,
    this.module,
    this.initialCommentId,
  });

  final String? initialCommentId;

  @override
  ConsumerState<InteractionCommentBottomSheet> createState() =>
      _InteractionCommentBottomSheetState();
}

class _InteractionCommentBottomSheetState
    extends ConsumerState<InteractionCommentBottomSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String? _editingCommentId;
  String? _replyingCommentId;
  String? _replyingAuthorName;
  bool _initialReplyShown = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _commentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit(InteractionNotifier notifier) {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    if (_editingCommentId != null) {
      notifier.editComment(_editingCommentId!, text);
      setState(() {
        _editingCommentId = null;
      });
    } else {
      notifier.addComment(text, parentId: _replyingCommentId);
      setState(() {
        _replyingCommentId = null;
        _replyingAuthorName = null;
      });
    }
    _commentController.clear();
    _focusNode.unfocus();
  }

  void _startEditing(CommentModel comment) {
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

  void _cancelAction() {
    setState(() {
      _editingCommentId = null;
      _replyingCommentId = null;
      _replyingAuthorName = null;
      _commentController.clear();
    });
    _focusNode.unfocus();
  }

  Future<void> _confirmDelete(
    BuildContext context,
    InteractionNotifier notifier,
    String commentId,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmDelete),
        content: Text(l10n.deleteCommentConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      notifier.deleteComment(commentId);
    }
  }

  CommentModel? _findComment(List<CommentModel> comments, String id) {
    for (var comment in comments) {
      if (comment.id == id) return comment;
      final reply = _findComment(comment.replies, id);
      if (reply != null) return reply;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final params = (id: widget.id, type: widget.type);
    final state = ref.watch(interactionProvider(params));
    final notifier = ref.read(interactionProvider(params).notifier);
    final l10n = AppLocalizations.of(context)!;
    final quizTheme = Theme.of(context).extension<QuizThemeExtension>()!;

    if (!_initialReplyShown &&
        widget.initialCommentId != null &&
        state.comments.isNotEmpty) {
      final comment = _findComment(state.comments, widget.initialCommentId!);
      if (comment != null) {
        _initialReplyShown = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _startReplying(comment);

          //Attempt to scroll to the comment
          final index = state.comments.indexWhere((c) => c.id == comment.id);
          if (index != -1 && _scrollController.hasClients) {
            //Very rough estimation of scroll position since items have dynamic height
            //But better than nothing.For more accuracy,a specialized package or
            //GlobalKey approach would be needed.
            _scrollController.animateTo(
              index * 100.0, //Assumption of average item height
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
            );
          }
        });
      }
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: quizTheme.backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          _buildHeader(quizTheme, l10n),
          _buildTabs(quizTheme, l10n),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCommentsTab(state, notifier, quizTheme, l10n),
                _buildNotesTab(quizTheme, l10n),
              ],
            ),
          ),
          if (_tabController.index == 0)
            _buildCommentInput(notifier, quizTheme, l10n),
        ],
      ),
    );
  }

  Widget _buildHeader(QuizThemeExtension quizTheme, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.title ??
                (widget.type == InteractionType.lesson
                    ? l10n.lesson
                    : l10n.module),
            style: TextStyle(
              color: quizTheme.primaryTextColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: quizTheme.primaryTextColor),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(QuizThemeExtension quizTheme, AppLocalizations l10n) {
    return TabBar(
      controller: _tabController,
      labelColor: Theme.of(context).primaryColor,
      unselectedLabelColor: quizTheme.secondaryTextColor,
      indicatorColor: Theme.of(context).primaryColor,
      onTap: (index) => setState(() {}),
      tabs: [
        Tab(text: l10n.interactionSpace),
        Tab(text: l10n.myNotes),
      ],
    );
  }

  Widget _buildCommentsTab(
    InteractionState state,
    InteractionNotifier notifier,
    QuizThemeExtension quizTheme,
    AppLocalizations l10n,
  ) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.comments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.message_text,
              size: 64,
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

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(20),
      itemCount: state.comments.length,
      itemBuilder: (context, index) {
        final comment = state.comments[index];
        final isSelected = widget.initialCommentId == comment.id;

        return Container(
          decoration: isSelected
              ? BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                  ),
                )
              : null,
          child: _CommentTile(
            comment: comment,
            quizTheme: quizTheme,
            l10n: l10n,
            onVote: (c, vote) => notifier.voteComment(c.id, vote),
            onReply: (c) => _startReplying(c),
            onEdit: (c) => _startEditing(c),
            onDelete: (c) => _confirmDelete(context, notifier, c.id, l10n),
            onReport: (c) {
              //Future implementation
            },
          ),
        );
      },
    );
  }

  Widget _buildNotesTab(QuizThemeExtension quizTheme, AppLocalizations l10n) {
    final List<MapEntry<String, HighlightModel>> notesHighlights = [];

    if (widget.type == InteractionType.lesson && widget.lesson != null) {
      if (widget.lesson!.paragraphs != null) {
        for (var paragraph in widget.lesson!.paragraphs!) {
          for (var h in paragraph.highlights) {
            if (h.note != null && h.note!.isNotEmpty) {
              notesHighlights.add(MapEntry(paragraph.id, h));
            }
          }
        }
      }
    } else if (widget.type == InteractionType.course && widget.module != null) {
      if (widget.module!.lessons != null) {
        for (var lesson in widget.module!.lessons!) {
          if (lesson.paragraphs != null) {
            for (var paragraph in lesson.paragraphs!) {
              for (var h in paragraph.highlights) {
                if (h.note != null && h.note!.isNotEmpty) {
                  notesHighlights.add(MapEntry(paragraph.id, h));
                }
              }
            }
          }
        }
      }
    }

    if (notesHighlights.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.note,
              size: 64,
              color: quizTheme.secondaryTextColor.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noNotes,
              style: TextStyle(color: quizTheme.secondaryTextColor),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: notesHighlights.length,
      itemBuilder: (context, index) {
        final entry = notesHighlights[index];
        final highlight = entry.value;
        final hColor = highlight.color;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: quizTheme.secondaryTextColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: hColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  highlight.text,
                  style: TextStyle(
                    color: quizTheme.primaryTextColor,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              QuillSimpleViewer(
                content: highlight.note ?? '',
                textColor: quizTheme.primaryTextColor,
                fontSize: 15,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCommentInput(
    InteractionNotifier notifier,
    QuizThemeExtension quizTheme,
    AppLocalizations l10n,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: quizTheme.backgroundColor,
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
          if (_editingCommentId != null || _replyingCommentId != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              color: Theme.of(context).primaryColor.withOpacity(0.05),
              child: Row(
                children: [
                  Icon(
                    _editingCommentId != null ? Icons.edit : Icons.reply,
                    size: 16,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _editingCommentId != null
                          ? l10n.editComment
                          : "Replying to$_replyingAuthorName",
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _cancelAction,
                    child: Icon(
                      Icons.close,
                      size: 16,
                      color: quizTheme.secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 10,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    focusNode: _focusNode,
                    style: TextStyle(color: quizTheme.primaryTextColor),
                    decoration: InputDecoration(
                      hintText: l10n.addPublicComment,
                      hintStyle: TextStyle(
                        color: quizTheme.secondaryTextColor.withOpacity(0.5),
                      ),
                      filled: true,
                      fillColor: quizTheme.secondaryTextColor.withOpacity(0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: () => _submit(notifier),
                  icon: Icon(Icons.send, color: Theme.of(context).primaryColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final CommentModel comment;
  final QuizThemeExtension quizTheme;
  final AppLocalizations l10n;
  final Function(CommentModel, int) onVote;
  final Function(CommentModel) onReply;
  final Function(CommentModel) onEdit;
  final Function(CommentModel) onDelete;
  final Function(CommentModel) onReport;
  final bool isReply;
  final bool showThreadLine;

  const _CommentTile({
    required this.comment,
    required this.quizTheme,
    required this.l10n,
    required this.onVote,
    required this.onReply,
    required this.onEdit,
    required this.onDelete,
    required this.onReport,
    this.isReply = false,
    this.showThreadLine = false,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 32,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: Theme.of(
                    context,
                  ).primaryColor.withOpacity(0.1),
                  child: Text(
                    comment.author.isNotEmpty
                        ? comment.author[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      fontSize: 10,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (showThreadLine || comment.replies.isNotEmpty)
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
                _CommentActions(
                  comment: comment,
                  quizTheme: quizTheme,
                  l10n: l10n,
                  onVote: (vote) => onVote(comment, vote),
                  onReply: () => onReply(comment),
                  onEdit: () => onEdit(comment),
                  onDelete: () => onDelete(comment),
                  onReport: () => onReport(comment),
                ),
                if (comment.replies.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Column(
                      children: List.generate(comment.replies.length, (index) {
                        return _CommentTile(
                          comment: comment.replies[index],
                          quizTheme: quizTheme,
                          l10n: l10n,
                          onVote: onVote,
                          onReply: onReply,
                          onEdit: onEdit,
                          onDelete: onDelete,
                          onReport: onReport,
                          isReply: true,
                          showThreadLine: index < comment.replies.length - 1,
                        );
                      }),
                    ),
                  ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentActions extends StatelessWidget {
  final CommentModel comment;
  final QuizThemeExtension quizTheme;
  final AppLocalizations l10n;
  final Function(int) onVote;
  final VoidCallback onReply;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onReport;

  const _CommentActions({
    required this.comment,
    required this.quizTheme,
    required this.l10n,
    required this.onVote,
    required this.onReply,
    required this.onEdit,
    required this.onDelete,
    required this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
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
              color: Theme.of(context).primaryColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (comment.isMine) ...[
          GestureDetector(
            onTap: onEdit,
            child: Text(
              l10n.edit,
              style: TextStyle(
                color: quizTheme.secondaryTextColor,
                fontSize: 12,
              ),
            ),
          ),
          GestureDetector(
            onTap: onDelete,
            child: Text(
              l10n.delete,
              style: TextStyle(
                color: Colors.red.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ),
        ] else
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
      mainAxisSize: MainAxisSize.min,
      children: [
        _VoteIcon(
          icon: Iconsax.arrow_circle_up,
          isActive: myVote == 1,
          activeColor: Colors.orange,
          onTap: () => onVote(myVote == 1 ? 0 : 1),
          quizTheme: quizTheme,
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
        _VoteIcon(
          icon: Iconsax.arrow_circle_down,
          isActive: myVote == -1,
          activeColor: Colors.blue,
          onTap: () => onVote(myVote == -1 ? 0 : -1),
          quizTheme: quizTheme,
        ),
      ],
    );
  }
}

class _VoteIcon extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;
  final QuizThemeExtension quizTheme;

  const _VoteIcon({
    required this.icon,
    required this.isActive,
    required this.activeColor,
    required this.onTap,
    required this.quizTheme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        icon,
        size: 16,
        color: isActive ? activeColor : quizTheme.secondaryTextColor,
      ),
    );
  }
}

//Deprecated alias for compatibility
class LessonCommentBottomSheet extends InteractionCommentBottomSheet {
  const LessonCommentBottomSheet({
    super.key,
    required String lessonId,
    super.lesson,
    super.initialTabIndex = 0,
  }) : super(id: lessonId, type: InteractionType.lesson);
}
