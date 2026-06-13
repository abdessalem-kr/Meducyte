import 'package:flutter/services.dart';
import 'package:collection/collection.dart';
import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/shared/widgets/subscription_gate.dart';
import 'package:meducyte_app/features/productive_bay/data/providers/study_group_provider.dart';
import 'package:meducyte_app/features/productive_bay/presentation/widgets/user_search_sheet.dart';
import 'package:meducyte_app/features/productive_bay/presentation/widgets/quiz_selection_sheet.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:meducyte_app/features/productive_bay/presentation/utils/study_share_helper.dart';
import 'package:meducyte_app/features/productive_bay/data/providers/pomodoro_provider.dart';
import 'package:meducyte_app/features/productive_bay/domain/models/pomodoro_models.dart';
import 'package:meducyte_app/features/auth/presentation/widgets/notion_avatar_renderer.dart';

class StudyGroupDetailsPage extends ConsumerStatefulWidget {
  final StudyGroup group;

  const StudyGroupDetailsPage({super.key, required this.group});

  @override
  ConsumerState<StudyGroupDetailsPage> createState() =>
      _StudyGroupDetailsPageState();
}

class _StudyGroupDetailsPageState extends ConsumerState<StudyGroupDetailsPage> {
  final TextEditingController _messageController = TextEditingController();
  bool _hasAutoPushed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _joinGroupAndSync();
    });
  }

  Future<void> _joinGroupAndSync() async {
    final myGroups = ref.read(myStudyGroupsProvider).value ?? [];
    final alreadyJoined = myGroups.any((g) => g.id == group.id);

    if (!alreadyJoined) {
      try {
        await ref.read(studyGroupRepositoryProvider).joinGroup(group.id);
        ref.invalidate(myStudyGroupsProvider);
        ref.invalidate(studyGroupProvider(group.id));

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Vous avez rejoint le groupe \"${group.title}\""),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      } catch (e) {
        // Quiet fail
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  StudyGroup? _realTimeGroup;
  StudyGroup get group => _realTimeGroup ?? widget.group;

  String get title => group.title;
  Color get themeColor => group.themeColor;

  @override
  Widget build(BuildContext context) {
    final groupAsync = ref.watch(studyGroupProvider(widget.group.id));
    _realTimeGroup = groupAsync.value;

    final messagesAsync = ref.watch(studyGroupMessagesProvider(group.id));
    final activeQuizAsync = ref.watch(activeStudyGroupQuizProvider(group.id));

    final isSubscriber =
        ref.watch(authControllerProvider).value?.isSubscriber ?? false;

    final activeQuiz = activeQuizAsync.value;
    if (activeQuiz != null && activeQuiz.isActive) {
      if (!_hasAutoPushed) {
        _hasAutoPushed = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            context.pushNamed(
              AppRoutes.quizGroupStudy,
              pathParameters: {'id': group.id},
              extra: {'session': activeQuiz},
            );
          }
        });
      }
    } else {
      _hasAutoPushed = false;
    }

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: SubscriptionGate(
        isEnabled: !isSubscriber && !group.isPublic,
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
                _buildAdminPanel(context),
                if (group.type == StudyGroupType.qcmBattle) ...[
                  const SizedBox(height: 32),
                  activeQuizAsync.when(
                    data: (session) {
                      if (session != null) {
                        return _buildActiveQuizBanner(context, session);
                      }
                      return _buildGStudyAction(context);
                    },
                    loading: () => Skeletonizer(
                      enabled: true,
                      child: _buildActiveQuizBanner(
                        context,
                        StudyGroupQuizSession(
                          id: 'dummy',
                          studyGroupId: 'dummy',
                          quizId: 'dummy',
                          title: 'Chargement de la session active...',
                          participantIds: const ['1', '2'],
                          participantScores: const {'1': 0, '2': 0},
                          questions: const [],
                          isActive: true,
                          startTime: DateTime.now(),
                        ),
                      ),
                    ),
                    error: (e, s) => _buildGStudyAction(context),
                  ),
                ],
                if (group.type == StudyGroupType.focus) ...[
                  const SizedBox(height: 32),
                  _buildFocusGroupPomodoro(context),
                ],
                const SizedBox(height: 40),
                _buildSectionHeader(context.l10n.meducytesWall),
                const SizedBox(height: 20),
                messagesAsync.when(
                  data: (messages) => _buildMessageWall(context, messages),
                  loading: () => Skeletonizer(
                    enabled: true,
                    child: _buildMessageWall(
                      context,
                      List.generate(
                        3,
                        (index) => StudyGroupMessage(
                          id: 'dummy_$index',
                          senderId: 'dummy_sender',
                          senderName: 'Chargement...',
                          text:
                              'Ceci est un message de discussion factice pour le chargement du mur.',
                          timestamp: DateTime.now(),
                        ),
                      ),
                    ),
                  ),
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
            builder: (context) => QuizSelectionSheet(group: group),
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
              if (group.isAdmin)
                IconButton(
                  icon: const Icon(Iconsax.edit, color: Colors.white, size: 20),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => QuizSelectionSheet(
                        group: group,
                        editingSession: session,
                      ),
                    );
                  },
                ),
              ElevatedButton(
                onPressed: () {
                  ref
                      .read(studyGroupRepositoryProvider)
                      .joinQuizSession(group.id, session.id);
                  context.pushNamed(
                    AppRoutes.quizGroupStudy,
                    pathParameters: {'id': group.id},
                    extra: {'session': session},
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
                  Builder(
                    builder: (context) {
                      final senderUser = widget.group.members.firstWhereOrNull((u) => u.id.toString() == m.senderId);
                      final avatarKey = senderUser?.avatarKey ?? 'avatar_1';
                      return NotionAvatarRenderer(avatarKey: avatarKey, size: 28);
                    },
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
                          if (m.isMine || group.isAdmin)
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
                  .sendMessage(group.id, message);

              _messageController.clear();
              ref.invalidate(studyGroupMessagesProvider(group.id));
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
        if (group.isAdmin)
          PopupMenuButton<String>(
            icon: const Icon(Iconsax.setting_2, color: Colors.white),
            onSelected: (value) async {
              if (value == 'settings') {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => _EditGroupSheet(group: group),
                );
              } else if (value == 'toggle_type') {
                final newType = group.type == StudyGroupType.silent
                    ? StudyGroupType.qcmBattle
                    : StudyGroupType.silent;
                final updated = group.copyWith(type: newType);
                await ref
                    .read(studyGroupRepositoryProvider)
                    .updateGroup(updated);
                ref.invalidate(studyGroupProvider(group.id));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        newType == StudyGroupType.silent
                            ? "Groupe passé en mode Discussion"
                            : "Groupe passé en mode Duel",
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } else if (value == 'delete') {
                _confirmDeleteGroup(context);
              }
            },
            itemBuilder: (context) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              final iconColor = isDark ? Colors.white70 : Colors.black87;
              return [
                PopupMenuItem(
                  value: 'settings',
                  child: Row(
                    children: [
                      Icon(Iconsax.setting_3, size: 20, color: iconColor),
                      const SizedBox(width: 12),
                      const Text("Paramètres du groupe"),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'toggle_type',
                  child: Row(
                    children: [
                      Icon(
                        group.type == StudyGroupType.silent
                            ? Iconsax.medal_star
                            : Iconsax.messages_3,
                        size: 20,
                        color: iconColor,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        group.type == StudyGroupType.silent
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
              ];
            },
          )
        else
          PopupMenuButton<String>(
            icon: const Icon(Iconsax.setting_2, color: Colors.white),
            onSelected: (value) async {
              if (value == 'leave') {
                _confirmLeaveGroup(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'leave',
                child: Row(
                  children: [
                    Icon(Iconsax.logout, size: 20, color: Colors.red),
                    SizedBox(width: 12),
                    Text(
                      "Quitter le groupe",
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
          ),
        IconButton(
          icon: const Icon(Iconsax.share, color: Colors.white),
          tooltip: 'Partager le groupe',
          onPressed: () {
            HapticFeedback.lightImpact();
            StudyShareHelper.shareInviteCard(context, group);
          },
        ),
        if (group.isAdmin)
          IconButton(
            icon: const Icon(Iconsax.user_add, color: Colors.white),
            tooltip: context.l10n.inviteFriend,
            onPressed: () {
              HapticFeedback.lightImpact();
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => UserSearchSheet(groupId: group.id, memberIds: group.memberIds),
              );
            },
          ),
      ],
    );
  }

  Future<void> _confirmDeleteGroup(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer le groupe'),
        content: Text(
          'Supprimer"${group.title}" ?Cette action est irréversible.',
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
      await ref.read(studyGroupRepositoryProvider).deleteGroup(group.id);

      ref.invalidate(availableStudyGroupsProvider);
      ref.invalidate(myStudyGroupsProvider);

      if (!context.mounted) return;
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
      if (!context.mounted) return;
      AppSnackBars.error(context, e);
    }
  }

  Future<void> _confirmLeaveGroup(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Quitter le groupe'),
        content: Text(
          'Voulez-vous vraiment quitter le groupe "${group.title}" ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Quitter'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await ref.read(studyGroupRepositoryProvider).leaveGroup(group.id);

      ref.invalidate(availableStudyGroupsProvider);
      ref.invalidate(myStudyGroupsProvider);

      if (!context.mounted) return;
      Navigator.of(context).pop(); // Go back to groups list
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Vous avez quitté le groupe'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      AppSnackBars.error(context, e);
    }
  }

  String _formatFocusTime(int totalSeconds) {
    if (totalSeconds < 60) {
      return "${totalSeconds}s";
    }
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    if (minutes < 60) {
      return "${minutes}m ${seconds}s";
    }
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    return "${hours}h ${remainingMinutes}m";
  }

  Widget _buildFocusGroupPomodoro(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pomodoro = ref.watch(pomodoroProvider);
    final notifier = ref.read(pomodoroProvider.notifier);
    final focusMembers = ref.watch(focusGroupSessionsProvider(widget.group.id));

    final minutes = pomodoro.remainingSeconds ~/ 60;
    final seconds = pomodoro.remainingSeconds % 60;
    final timeStr = "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";

    Color statusColor;
    String statusLabel;
    IconData statusIcon;

    switch (pomodoro.type) {
      case PomodoroSessionType.work:
        statusColor = themeColor;
        statusLabel = "TRAVAIL INTENSIF";
        statusIcon = Iconsax.flash;
        break;
      case PomodoroSessionType.shortBreak:
        statusColor = Colors.green;
        statusLabel = "COURTE PAUSE";
        statusIcon = Iconsax.coffee;
        break;
      case PomodoroSessionType.longBreak:
        statusColor = Colors.blue;
        statusLabel = "LONGUE PAUSE";
        statusIcon = Iconsax.moon;
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                statusColor.withOpacity(isDark ? 0.15 : 0.08),
                statusColor.withOpacity(isDark ? 0.05 : 0.02),
              ],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: statusColor.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(statusIcon, color: statusColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        statusLabel,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Iconsax.maximize_4, color: isDark ? Colors.white70 : Colors.black87),
                    onPressed: () {
                      context.pushNamed(AppRoutes.deepWork);
                    },
                    tooltip: "Mode Plein Écran",
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                timeStr,
                style: const TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -2,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      if (pomodoro.state == PomodoroState.running) {
                        notifier.pauseSession();
                      } else {
                        notifier.startSession();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: statusColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          pomodoro.state == PomodoroState.running
                              ? Iconsax.pause
                              : Iconsax.play,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          pomodoro.state == PomodoroState.running
                              ? "PAUSE"
                              : "COMMENCER",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      notifier.stopSession();
                    },
                    icon: const Icon(Iconsax.refresh),
                    style: IconButton.styleFrom(
                      backgroundColor: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
                      padding: const EdgeInsets.all(14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        _buildSectionHeader("Membres en session de Focus"),
        const SizedBox(height: 16),
        if (focusMembers.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                "Aucun membre n'est connecté",
                style: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: focusMembers.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final member = focusMembers[index];
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
                  ),
                ),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        NotionAvatarRenderer(
                          avatarKey: member.avatarKey ?? 'avatar_1',
                          size: 40,
                        ),
                        if (member.isOnline)
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDark ? AppColors.surfaceDark : Colors.white,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            member.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              if (member.isFocusing) ...[
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: themeColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "Travaille intensément",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: themeColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ] else if (member.isOnline) ...[
                                const Text(
                                  "En pause ou inactif",
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ] else ...[
                                const Text(
                                  "Hors ligne",
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formatFocusTime(member.focusTimeSeconds),
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        ),
                        const Text(
                          "Focus total",
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
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
          InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => _GroupMembersSheet(group: group),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildStatItem(
                context,
                context.l10n.members,
                "${group.membersCount}",
                Iconsax.user_octagon,
              ),
            ),
          ),
          _buildStatItem(
            context,
            context.l10n.focus.toUpperCase(),
            "${group.totalPomodoros}",
            Iconsax.flash,
          ),
          _buildStatItem(
            context,
            context.l10n.groupTypeLabel,
            group.type.name.toUpperCase(),
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
                ref.invalidate(studyGroupMessagesProvider(group.id));
              } catch (e) {
                if (context.mounted) {
                  AppSnackBars.error(context, e);
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
        ref.invalidate(studyGroupMessagesProvider(group.id));
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
          AppSnackBars.error(context, e);
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
                    AppSnackBars.error(context, e);
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

  Widget _buildAdminPanel(BuildContext context) {
    if (!group.isAdmin) return const SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: themeColor.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.setting_5, color: themeColor, size: 20),
              const SizedBox(width: 10),
              Text(
                "OPTIONS D'ADMINISTRATEUR",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildAdminActionButton(
                context,
                icon: Iconsax.edit,
                label: "Modifier",
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => _EditGroupSheet(group: group),
                  );
                },
              ),
              _buildAdminActionButton(
                context,
                icon: Iconsax.user_add,
                label: "Inviter",
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => UserSearchSheet(groupId: group.id, memberIds: group.memberIds),
                  );
                },
              ),
              _buildAdminActionButton(
                context,
                icon: Iconsax.people,
                label: "Membres",
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => _GroupMembersSheet(group: group),
                  );
                },
              ),
              _buildAdminActionButton(
                context,
                icon: group.type == StudyGroupType.silent
                    ? Iconsax.medal_star
                    : Iconsax.messages_3,
                label: group.type == StudyGroupType.silent
                    ? "Mode Duel"
                    : "Discussion",
                onTap: () async {
                  final newType = group.type == StudyGroupType.silent
                      ? StudyGroupType.qcmBattle
                      : StudyGroupType.silent;
                  final updated = group.copyWith(type: newType);
                  await ref
                      .read(studyGroupRepositoryProvider)
                      .updateGroup(updated);
                  ref.invalidate(studyGroupProvider(group.id));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          newType == StudyGroupType.silent
                              ? "Groupe passé en mode Discussion"
                              : "Groupe passé en mode Duel",
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
              ),
              _buildAdminActionButton(
                context,
                icon: Iconsax.trash,
                label: "Supprimer",
                onTap: () => _confirmDeleteGroup(context),
                isDestructive: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdminActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: 76,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          decoration: BoxDecoration(
            color: isDestructive
                ? Colors.red.withOpacity(0.08)
                : isDark
                ? Colors.white.withOpacity(0.04)
                : Colors.black.withOpacity(0.03),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDestructive
                  ? Colors.red.withOpacity(0.3)
                  : isDark
                  ? Colors.white10
                  : Colors.black.withOpacity(0.08),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isDestructive ? Colors.redAccent : themeColor,
                size: 18,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isDestructive
                      ? Colors.redAccent
                      : (isDark ? Colors.white70 : Colors.black87),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditGroupSheet extends ConsumerStatefulWidget {
  final StudyGroup group;
  const _EditGroupSheet({required this.group});

  @override
  ConsumerState<_EditGroupSheet> createState() => _EditGroupSheetState();
}

class _EditGroupSheetState extends ConsumerState<_EditGroupSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late String selectedType;
  String? selectedModuleId;
  String? selectedModuleName;
  String? selectedLessonId;
  String? selectedLessonName;
  late Color selectedColor;
  bool isLoading = false;
  bool _initializedIds = false;

  final List<Color> _availableColors = [
    AppColors.primary,
    Colors.teal,
    Colors.pinkAccent,
    Colors.orange,
    Colors.blueGrey,
    Colors.indigo,
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.group.title);
    _descriptionController = TextEditingController(
      text: widget.group.description,
    );
    selectedType = widget.group.type == StudyGroupType.silent
        ? "Silent"
        : widget.group.type == StudyGroupType.qcmBattle
        ? "QCM Battle"
        : "Focus";
    selectedColor = widget.group.themeColor;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _handleSave() async {
    if (_nameController.text.isEmpty) return;

    setState(() => isLoading = true);

    final name = _nameController.text;
    final description = _descriptionController.text;
    final typeStr = selectedType;
    final color = selectedColor;

    final repository = ref.read(studyGroupRepositoryProvider);
    final type = typeStr == "Silent"
        ? StudyGroupType.silent
        : typeStr == "QCM Battle"
        ? StudyGroupType.qcmBattle
        : StudyGroupType.focus;

    final category = selectedModuleName ?? 'Général';
    final tags = [
      selectedType,
      if (selectedModuleName != null) selectedModuleName!,
      if (selectedLessonName != null) selectedLessonName!,
    ];

    final updatedGroup = widget.group.copyWith(
      title: name,
      description: description.isEmpty
          ? "Travail intensif en groupe."
          : description,
      themeColor: color,
      tags: tags,
      type: type,
      category: category,
      icon: type == StudyGroupType.silent
          ? Iconsax.book_1
          : type == StudyGroupType.qcmBattle
          ? Iconsax.flash
          : Iconsax.timer_1,
    );

    try {
      await repository.updateGroup(updatedGroup);

      // Refresh providers
      ref.invalidate(studyGroupProvider(widget.group.id));
      ref.invalidate(availableStudyGroupsProvider);
      ref.invalidate(myStudyGroupsProvider);

      if (!mounted) return;
      Navigator.pop(context);
      HapticFeedback.lightImpact();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Iconsax.tick_circle, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: const Text(
                  "Groupe mis à jour avec succès !",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
    } catch (e) {
      setState(() => isLoading = false);
      if (!context.mounted) return;
      AppSnackBars.error(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final modulesAsync = ref.watch(learnModulesProvider);

    // Resolve IDs from names on first successful data load
    if (!_initializedIds && modulesAsync.value != null) {
      final modules = modulesAsync.value!;
      selectedModuleName = widget.group.category;
      if (selectedModuleName != null && selectedModuleName != 'Général') {
        final matchedMod = modules.firstWhereOrNull(
          (m) => m.name == selectedModuleName,
        );
        if (matchedMod != null) {
          selectedModuleId = matchedMod.id;
          // Match lesson
          final possibleLessonTag = widget.group.tags.firstWhereOrNull(
            (t) => t != selectedType && t != selectedModuleName,
          );
          if (possibleLessonTag != null && matchedMod.lessons != null) {
            final matchedLesson = matchedMod.lessons!.firstWhereOrNull(
              (l) => l.title == possibleLessonTag,
            );
            if (matchedLesson != null) {
              selectedLessonId = matchedLesson.id;
              selectedLessonName = matchedLesson.title;
            }
          }
        }
      }
      _initializedIds = true;
    }

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 32,
        bottom: MediaQuery.of(context).viewInsets.bottom + 40,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Modifier le groupe",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    letterSpacing: -0.5,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Iconsax.close_circle, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              context.l10n.roomNameLabel,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: Colors.grey,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                hintText: "Ex: Prépa Neuro-Chirurgie J-10",
                hintStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                filled: true,
                fillColor: isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.03),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(18),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              context.l10n.descriptionOptional,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: Colors.grey,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              maxLines: 2,
              maxLength: 120,
              decoration: InputDecoration(
                hintText: "Objectifs, règles de la salle...",
                hintStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                counterStyle: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                filled: true,
                fillColor: isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.03),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(18),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              context.l10n.sessionType,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: Colors.grey,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildTypeOption(
                  "Silent",
                  Iconsax.volume_cross,
                  context.l10n.silent.toUpperCase(),
                ),
                const SizedBox(width: 12),
                _buildTypeOption(
                  "QCM Battle",
                  Iconsax.flash,
                  context.l10n.qcmBattle.toUpperCase(),
                ),
                const SizedBox(width: 12),
                _buildTypeOption(
                  "Focus",
                  Iconsax.timer_1,
                  context.l10n.focus.toUpperCase(),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              context.l10n.themeColorLabel,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: Colors.grey,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _availableColors.length,
                separatorBuilder: (context, _) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final color = _availableColors[index];
                  final isSelected = selectedColor == color;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => selectedColor = color);
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(
                                color: isDark ? Colors.white : Colors.black,
                                width: 3,
                              )
                            : null,
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color: color.withOpacity(0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                        ],
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 20,
                            )
                          : null,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'MODULE & COURS',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: Colors.grey,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 12),
            modulesAsync.when(
              loading: () => _buildSelectorRow(
                context,
                isDark,
                icon: Iconsax.book_1,
                label: 'Chargement des modules...',
                hasValue: false,
                onTap: null,
              ),
              error: (_, __) => _buildSelectorRow(
                context,
                isDark,
                icon: Iconsax.book_1,
                label: 'Erreur de chargement',
                hasValue: false,
                onTap: null,
              ),
              data: (modules) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSelectorRow(
                    context,
                    isDark,
                    icon: Iconsax.book_1,
                    label: selectedModuleName ?? 'Choisir un module...',
                    hasValue: selectedModuleId != null,
                    onTap: () => _pickModule(context, isDark, modules),
                    onClear: selectedModuleId != null
                        ? () => setState(() {
                            selectedModuleId = null;
                            selectedModuleName = null;
                            selectedLessonId = null;
                            selectedLessonName = null;
                          })
                        : null,
                  ),
                  if (selectedModuleId != null) ...[
                    const SizedBox(height: 8),
                    _buildSelectorRow(
                      context,
                      isDark,
                      icon: Iconsax.document_text,
                      label:
                          selectedLessonName ?? 'Choisir un cours (optionnel)',
                      hasValue: selectedLessonId != null,
                      onTap: () {
                        final mod = modules.firstWhere(
                          (m) => m.id == selectedModuleId,
                        );
                        final lessons = mod.lessons ?? [];
                        if (lessons.isNotEmpty) {
                          _pickLesson(context, isDark, lessons);
                        }
                      },
                      onClear: selectedLessonId != null
                          ? () => setState(() {
                              selectedLessonId = null;
                              selectedLessonName = null;
                            })
                          : null,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: selectedColor.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: isLoading ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Enregistrer les modifications",
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeOption(String type, IconData icon, String label) {
    final isSelected = selectedType == type;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => selectedType = type);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? selectedColor
                : isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.black.withOpacity(0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? Colors.transparent
                  : isDark
                  ? Colors.white10
                  : Colors.black.withOpacity(0.05),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? Colors.white
                    : isDark
                    ? Colors.white70
                    : Colors.black87,
                size: 20,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : isDark
                      ? Colors.white70
                      : Colors.black87,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectorRow(
    BuildContext context,
    bool isDark, {
    required IconData icon,
    required String label,
    required bool hasValue,
    required VoidCallback? onTap,
    VoidCallback? onClear,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: hasValue
              ? AppColors.primary.withOpacity(0.06)
              : isDark
              ? Colors.white.withOpacity(0.04)
              : Colors.black.withOpacity(0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasValue
                ? AppColors.primary.withOpacity(0.5)
                : isDark
                ? Colors.white12
                : Colors.black12,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: hasValue
                  ? AppColors.primary
                  : (isDark ? Colors.white38 : Colors.black38),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: hasValue ? FontWeight.w700 : FontWeight.w500,
                  color: hasValue
                      ? (isDark ? Colors.white : Colors.black87)
                      : (isDark ? Colors.white38 : Colors.black38),
                ),
              ),
            ),
            if (onClear != null)
              GestureDetector(
                onTap: onClear,
                child: const Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: Colors.grey,
                ),
              )
            else
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: isDark ? Colors.white24 : Colors.black26,
              ),
          ],
        ),
      ),
    );
  }

  void _pickModule(
    BuildContext context,
    bool isDark,
    List<LearnModule> modules,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Choisir un module',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                shrinkWrap: true,
                itemCount: modules.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final mod = modules[i];
                  final isSelected = selectedModuleId == mod.id;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        selectedModuleId = mod.id;
                        selectedModuleName = mod.name;
                        selectedLessonId = null;
                        selectedLessonName = null;
                      });
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : isDark
                            ? Colors.white.withOpacity(0.05)
                            : AppColors.primary.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : isDark
                              ? Colors.white12
                              : AppColors.primary.withOpacity(0.15),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Iconsax.book_1,
                            size: 16,
                            color: isSelected
                                ? Colors.white
                                : AppColors.primary.withOpacity(0.7),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              mod.name,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? Colors.white
                                    : isDark
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _pickLesson(
    BuildContext context,
    bool isDark,
    List<LearnLesson> lessons,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Choisir un cours',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                shrinkWrap: true,
                itemCount: lessons.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final lesson = lessons[i];
                  final isSelected = selectedLessonId == lesson.id;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        selectedLessonId = lesson.id;
                        selectedLessonName = lesson.title;
                      });
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withOpacity(0.1)
                            : isDark
                            ? Colors.white.withOpacity(0.04)
                            : Colors.black.withOpacity(0.02),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : isDark
                              ? Colors.white10
                              : Colors.black.withOpacity(0.08),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected
                                ? Iconsax.tick_circle
                                : Iconsax.document_text,
                            size: 14,
                            color: isSelected
                                ? AppColors.primary
                                : isDark
                                ? Colors.white38
                                : Colors.black38,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              lesson.title,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected
                                    ? AppColors.primary
                                    : isDark
                                    ? Colors.white70
                                    : Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupMembersSheet extends ConsumerStatefulWidget {
  final StudyGroup group;

  const _GroupMembersSheet({required this.group});

  @override
  ConsumerState<_GroupMembersSheet> createState() => _GroupMembersSheetState();
}

class _GroupMembersSheetState extends ConsumerState<_GroupMembersSheet> {
  bool _loading = false;
  late StudyGroup _currentGroup;

  @override
  void initState() {
    super.initState();
    _currentGroup = widget.group;
  }

  Future<void> _refreshGroup() async {
    final updated = await ref.read(studyGroupRepositoryProvider).getGroup(_currentGroup.id);
    if (updated != null && mounted) {
      setState(() {
        _currentGroup = updated;
      });
    }
  }

  Future<void> _removeUser(User user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Exclure le membre ?"),
        content: Text("Êtes-vous sûr de vouloir retirer ${user.name} de ce groupe d'étude ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text("Exclure"),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _loading = true;
    });

    try {
      await ref.read(studyGroupRepositoryProvider).removeMember(_currentGroup.id, user.id.toString());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${user.name} a été retiré du groupe."),
            backgroundColor: Colors.green,
          ),
        );
      }
      await _refreshGroup();
      // Invalidate providers
      ref.invalidate(studyGroupProvider(_currentGroup.id));
      ref.invalidate(availableStudyGroupsProvider);
    } catch (e) {
      if (mounted) {
        AppSnackBars.error(context, e);
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeColor = _currentGroup.themeColor;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Membres du groupe (${_currentGroup.members.length})",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_currentGroup.isAdmin)
                IconButton(
                  icon: const Icon(Iconsax.user_add),
                  onPressed: () {
                    Navigator.pop(context);
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => UserSearchSheet(
                        groupId: _currentGroup.id,
                        memberIds: _currentGroup.memberIds,
                      ),
                    );
                  },
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else if (_currentGroup.members.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Text("Aucun membre dans ce groupe"),
              ),
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _currentGroup.members.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final member = _currentGroup.members[index];
                  final currentUser = ref.watch(authControllerProvider).value;
                  final isMe = currentUser != null && currentUser.id == member.id;

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: themeColor.withOpacity(0.1),
                      child: Text(
                        member.name.isNotEmpty ? member.name[0].toUpperCase() : 'U',
                        style: TextStyle(color: themeColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(
                      isMe ? "${member.name} (Vous)" : member.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: member.email.isNotEmpty ? Text(member.email) : null,
                    trailing: (_currentGroup.isAdmin && !isMe)
                        ? IconButton(
                            icon: const Icon(Iconsax.user_remove, color: Colors.red),
                            onPressed: () => _removeUser(member),
                          )
                        : null,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
