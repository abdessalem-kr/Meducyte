import 'package:flutter/services.dart';
import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/shared/widgets/subscription_gate.dart';
import 'package:meducyte_app/features/productive_bay/data/providers/study_group_provider.dart';
import 'package:meducyte_app/features/productive_bay/presentation/widgets/user_search_sheet.dart';
import 'package:meducyte_app/features/productive_bay/presentation/widgets/quiz_selection_sheet.dart';

class StudyGroupDetailsPage extends ConsumerStatefulWidget {
  final StudyGroup group;

  const StudyGroupDetailsPage({super.key, required this.group});

  @override
  ConsumerState<StudyGroupDetailsPage> createState() =>
      _StudyGroupDetailsPageState();
}

class _StudyGroupDetailsPageState extends ConsumerState<StudyGroupDetailsPage> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  String get title => widget.group.title;
  Color get themeColor => widget.group.themeColor;

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(
      studyGroupMessagesProvider(widget.group.id),
    );
    final activeQuizAsync = ref.watch(
      activeStudyGroupQuizProvider(widget.group.id),
    );

    final isSubscriber =
        ref.watch(authControllerProvider).value?.isSubscriber ?? false;

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: SubscriptionGate(
        isEnabled: !isSubscriber && !widget.group.isPublic,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [_buildSliverAppBar(context)];
          },
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRoomStats(context),
                const SizedBox(height: 32),
                activeQuizAsync.when(
                  data: (session) {
                    if (session != null) {
                      return _buildActiveQuizBanner(context, session);
                    }
                    //Only admin can start a quiz session
                    if (widget.group.isAdmin) {
                      return _buildGStudyAction(context);
                    }
                    //Non-admin wait for the session
                    return _buildWaitingForSessionPlaceholder(context);
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, s) => widget.group.isAdmin
                      ? _buildGStudyAction(context)
                      : _buildWaitingForSessionPlaceholder(context),
                ),
                const SizedBox(height: 40),
                _buildSectionHeader(context.l10n.meducytesWall),
                const SizedBox(height: 20),
                messagesAsync.when(
                  data: (messages) => _buildMessageWall(context, messages),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Center(child: Text("Erreur: $e")),
                ),
                const SizedBox(height: 120),
              ],
            ),
          ),
        ),
      ),
      bottomSheet: _buildMessageInput(context),
    );
  }

  Widget _buildGStudyAction(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => QuizSelectionSheet(group: widget.group),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Iconsax.flash, size: 24),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "ADD A QUIZ SESSION",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  context.l10n.liveQuizBattleInfo,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveQuizBanner(
    BuildContext context,
    StudyGroupQuizSession session,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green, Colors.green.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white24,
              shape: BoxShape.circle,
            ),
            child: const Icon(Iconsax.flash, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.activeSession,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  session.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  context.l10n.participantsCount(session.participantIds.length),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              if (widget.group.isAdmin)
                IconButton(
                  icon: const Icon(Iconsax.edit, color: Colors.white, size: 20),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => QuizSelectionSheet(
                        group: widget.group,
                        editingSession: session,
                      ),
                    );
                  },
                ),
              ElevatedButton(
                onPressed: () {
                  ref
                      .read(studyGroupRepositoryProvider)
                      .joinQuizSession(widget.group.id, session.id);
                  context.pushNamed(
                    AppRoutes.quizGroupStudy,
                    pathParameters: {'id': widget.group.id},
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: Text(
                  context.l10n.joinRoom,
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageWall(
    BuildContext context,
    List<StudyGroupMessage> messages,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (messages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Text(
            context.l10n.beFirstToEncourage,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.grey.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return Column(
      children: messages
          .map((m) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark
                      ? AppColors.dividerDark
                      : AppColors.dividerLight,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundImage: NetworkImage(
                      "https://i.pravatar.cc/150?u=${m.senderId}",
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              m.senderName.toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 11,
                                color: AppColors.primary,
                              ),
                            ),
                            if (m.isEdited) ...[
                              const SizedBox(width: 6),
                              Text(
                                "(${context.l10n.edited})",
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.grey.withOpacity(0.7),
                                  fontStyle: FontStyle.italic,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          m.text,
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_vert,
                          size: 18,
                          color: Colors.grey.withOpacity(0.7),
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showEditMessageDialog(context, m);
                          } else if (value == 'delete') {
                            _confirmDeleteMessage(context, m);
                          } else if (value == 'report') {
                            _showReportMessageDialog(context, m);
                          }
                        },
                        itemBuilder: (context) => [
                          if (m.isMine)
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  const Icon(
                                    Iconsax.edit,
                                    size: 18,
                                    color: Colors.blue,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(context.l10n.edit),
                                ],
                              ),
                            ),
                          if (m.isMine || widget.group.isAdmin)
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  const Icon(
                                    Iconsax.trash,
                                    size: 18,
                                    color: Colors.red,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(context.l10n.delete),
                                ],
                              ),
                            ),
                          if (!m.isMine)
                            PopupMenuItem(
                              value: 'report',
                              child: Row(
                                children: [
                                  const Icon(
                                    Iconsax.danger,
                                    size: 18,
                                    color: Colors.orange,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(context.l10n.reportError),
                                ],
                              ),
                            ),
                        ],
                      ),
                      Text(
                        _timeAgo(m.timestamp),
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          })
          .toList()
          .reversed
          .toList(),
    );
  }

  String _timeAgo(DateTime dateTime) {
    final local = dateTime.toLocal();
    final diff = DateTime.now().difference(local);

    if (diff.inSeconds < 60) return "Maintenant";
    if (diff.inMinutes < 60) return "${diff.inMinutes}m";
    if (diff.inHours < 24) return "${diff.inHours}h";
    if (diff.inDays < 7) return "${diff.inDays}j";
    return "${local.day}/${local.month}";
  }

  Widget _buildMessageInput(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: context.l10n.sendEncouragement,
                hintStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.03),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () async {
              if (_messageController.text.trim().isEmpty) return;

              final message = StudyGroupMessage(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                senderId: "me",
                senderName: context.l10n.you,
                text: _messageController.text.trim(),
                timestamp: DateTime.now(),
              );

              await ref
                  .read(studyGroupRepositoryProvider)
                  .sendMessage(widget.group.id, message);

              _messageController.clear();
              ref.invalidate(studyGroupMessagesProvider(widget.group.id));
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: themeColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: themeColor.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Iconsax.send_1, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: themeColor,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Iconsax.arrow_left_2, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 18,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [themeColor, themeColor.withOpacity(0.8)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Opacity(
                opacity: 0.1,
                child: Icon(Iconsax.people, size: 150, color: Colors.white),
              ),
              Positioned(
                bottom: 60,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Iconsax.radar, color: Colors.green, size: 14),
                      const SizedBox(width: 8),
                      Text(
                        context.l10n.liveSession,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        if (widget.group.isAdmin)
          PopupMenuButton<String>(
            icon: const Icon(Iconsax.setting_2, color: Colors.white),
            onSelected: (value) async {
              if (value == 'toggle_type') {
                final newType = widget.group.type == StudyGroupType.silent
                    ? StudyGroupType.qcmBattle
                    : StudyGroupType.silent;
                final updated = widget.group.copyWith(type: newType);
                await ref
                    .read(studyGroupRepositoryProvider)
                    .updateGroup(updated);
                ref.invalidate(studyGroupProvider(widget.group.id));
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        newType == StudyGroupType.silent
                            ? "Groupe passéen mode Discussion"
                            : "Groupe passéen mode Duel",
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } else if (value == 'delete') {
                _confirmDeleteGroup(context);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'toggle_type',
                child: Row(
                  children: [
                    Icon(
                      widget.group.type == StudyGroupType.silent
                          ? Iconsax.medal_star
                          : Iconsax.messages_3,
                      size: 20,
                      color: Colors.black87,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      widget.group.type == StudyGroupType.silent
                          ? "Passer en mode Duel"
                          : "Passer en mode Discussion",
                    ),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Iconsax.trash, size: 20, color: Colors.red),
                    SizedBox(width: 12),
                    Text(
                      "Supprimer le groupe",
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
          ),
        if (widget.group.isAdmin)
          IconButton(
            icon: const Icon(Iconsax.trash, color: Colors.white),
            tooltip: 'Supprimer le groupe',
            onPressed: () => _confirmDeleteGroup(context),
          ),
        IconButton(
          icon: const Icon(Iconsax.user_add, color: Colors.white),
          tooltip: context.l10n.inviteFriend,
          onPressed: () {
            HapticFeedback.lightImpact();
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => UserSearchSheet(groupId: widget.group.id),
            );
          },
        ),
        //IconButton(
        // icon:const Icon(Iconsax.info_circle,color:Colors.white),
        // onPressed: () {},
        // ),
      ],
    );
  }

  Future<void> _confirmDeleteGroup(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer le groupe'),
        content: Text(
          'Supprimer"${widget.group.title}" ?Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await ref.read(studyGroupRepositoryProvider).deleteGroup(widget.group.id);

      ref.invalidate(availableStudyGroupsProvider);
      ref.invalidate(myStudyGroupsProvider);

      if (!mounted) return;
      Navigator.of(context).pop(); //Pop back to groups list.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
              SizedBox(width: 10),
              Text(
                'Groupe supprimé',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Widget _buildRoomStats(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            context,
            context.l10n.members,
            "${widget.group.membersCount}",
            Iconsax.user_octagon,
          ),
          _buildStatItem(
            context,
            context.l10n.focus.toUpperCase(),
            "${widget.group.totalPomodoros}",
            Iconsax.flash,
          ),
          _buildStatItem(
            context,
            context.l10n.groupTypeLabel,
            widget.group.type.name.toUpperCase(),
            Iconsax.ranking,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, color: themeColor, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w900,
            color: Colors.grey,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.5,
        color: AppColors.primary,
      ),
    );
  }

  void _showEditMessageDialog(BuildContext context, StudyGroupMessage message) {
    final controller = TextEditingController(text: message.text);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.edit),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: context.l10n.editNote,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;
              try {
                await ref
                    .read(studyGroupRepositoryProvider)
                    .editMessage(message.id, controller.text.trim());
                if (context.mounted) Navigator.pop(context);
                ref.invalidate(studyGroupMessagesProvider(widget.group.id));
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              }
            },
            child: Text(context.l10n.save),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteMessage(
    BuildContext context,
    StudyGroupMessage message,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.confirmDelete),
        content: Text(context.l10n.deleteCommentConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(context.l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(studyGroupRepositoryProvider).deleteMessage(message.id);
        ref.invalidate(studyGroupMessagesProvider(widget.group.id));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Message supprimé'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Erreur: $e")));
        }
      }
    }
  }

  void _showReportMessageDialog(
    BuildContext context,
    StudyGroupMessage message,
  ) {
    final reasons = [
      context.l10n.reasonInaccurate,
      context.l10n.reasonUnclear,
      context.l10n.reasonOther,
    ];
    String selectedReason = reasons.first;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(context.l10n.reportError),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: reasons
                .map(
                  (r) => RadioListTile<String>(
                    title: Text(r),
                    value: r,
                    groupValue: selectedReason,
                    onChanged: (val) => setState(() => selectedReason = val!),
                  ),
                )
                .toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.l10n.cancel),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await ref
                      .read(studyGroupRepositoryProvider)
                      .reportMessage(message.id, selectedReason);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(context.l10n.reportSent)),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                }
              },
              child: Text(context.l10n.sendReport),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaitingForSessionPlaceholder(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Iconsax.timer_1,
              color: AppColors.primary,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.waitingForSession,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.adminWillStartSession,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? Colors.white60 : Colors.black54,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
