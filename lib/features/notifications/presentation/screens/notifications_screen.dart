import 'package:meducyte_app/export.dart';
import 'package:intl/intl.dart';
import 'package:meducyte_app/features/notifications/presentation/controllers/notification_controller.dart';
import 'package:meducyte_app/features/notifications/domain/models/notification.dart';
import 'package:meducyte_app/features/notifications/application/services/notification_service.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  NotificationType? _selectedType;
  bool _showUnreadOnly = false;

  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(notificationControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;

    final categories = _getCategories(l10n);

    // Filter notifications based on selected category or "Unread Only" status
    final filteredNotifications = notifications.where((n) {
      bool matchesType = true;
      if (_selectedType != null) {
        // If we have a selected type, we need to check if the notification's type
        // belongs to the same category as the selected one.
        // Actually, easier to just check if n.type is one of the types in the selected category's group.
        final selectedCategoryLabel = _getTypeLabel(_selectedType!, l10n);
        final allowedTypes =
            categories[selectedCategoryLabel] ?? [_selectedType!];
        matchesType = allowedTypes.contains(n.type);
      }

      final matchesRead = !_showUnreadOnly || !n.isRead;
      return matchesType && matchesRead;
    }).toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, ref, isDark, l10n),
          _buildFilterBar(isDark, l10n),
          if (filteredNotifications.isEmpty)
            _buildEmptyState(context, isDark, l10n)
          else
            _buildNotificationHistory(
              context,
              ref,
              filteredNotifications,
              isDark,
              l10n,
            ),
        ],
      ),
    );
  }

  Widget _buildAppBar(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final unreadCount = ref
        .watch(notificationControllerProvider.notifier)
        .unreadCount;
    final hasNotifications = ref
        .watch(notificationControllerProvider)
        .isNotEmpty;

    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new,
          color: isDark ? Colors.white : Colors.black,
          size: 20,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        if (hasNotifications) ...[
          IconButton(
            icon: Icon(
              Iconsax.trash,
              color: Colors.redAccent.withOpacity(0.8),
              size: 20,
            ),
            onPressed: () => _showClearAllConfirmation(context),
            tooltip: l10n.clearAllNotifications,
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(
                  Iconsax.tick_circle,
                  color: AppColors.primary,
                  size: 22,
                ),
                onPressed: unreadCount > 0
                    ? () => ref
                          .read(notificationControllerProvider.notifier)
                          .markAllAsRead()
                    : null,
                tooltip: l10n.markAllAsRead,
              ),
              if (unreadCount > 0)
                Positioned(
                  top: 10,
                  right: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? AppColors.surfaceDark : Colors.white,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          l10n.notificationsTitle,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
    );
  }

  Widget _buildFilterBar(bool isDark, AppLocalizations l10n) {
    final categories = _getCategories(l10n);
    return SliverToBoxAdapter(
      child: Container(
        height: 54,
        margin: const EdgeInsets.only(top: 8),
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            _buildSpecialFilterChip(
              id: 'unread',
              label: l10n.all, // Using "All" for the default
              icon: Iconsax.notification,
              isSelected: !_showUnreadOnly && _selectedType == null,
              onTap: () => setState(() {
                _showUnreadOnly = false;
                _selectedType = null;
              }),
              isDark: isDark,
            ),
            _buildSpecialFilterChip(
              id: 'unread_only',
              label: "Non lues",
              icon: Iconsax.filter,
              isSelected: _showUnreadOnly,
              count: ref
                  .watch(notificationControllerProvider.notifier)
                  .unreadCount,
              onTap: () => setState(() => _showUnreadOnly = !_showUnreadOnly),
              isDark: isDark,
            ),
            const VerticalDivider(width: 24, indent: 12, endIndent: 12),
            ...categories.keys.map((label) {
              // Determine a representative type for this category to use with _buildFilterChip
              final type = categories[label]!.first;
              return _buildFilterChip(type, label, isDark);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(NotificationType type, String label, bool isDark) {
    final isSelected = _selectedType == type;
    final color = isDark ? Colors.white : Colors.black;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedType = selected ? type : null;
            // Optionally auto-disable unread filter when specific type selected
            // or keep both, which is what my logic currently does.
          });
        },
        selectedColor: AppColors.primary.withOpacity(0.1),
        backgroundColor: Colors.transparent,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primary : color.withOpacity(0.5),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          fontSize: 13,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
          side: BorderSide(
            color: isSelected
                ? AppColors.primary.withOpacity(0.5)
                : color.withOpacity(0.1),
            width: 1,
          ),
        ),
        showCheckmark: false,
      ),
    );
  }

  Widget _buildSpecialFilterChip({
    required String id,
    required String label,
    required IconData icon,
    required bool isSelected,
    int? count,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    final color = isDark ? Colors.white : Colors.black;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary.withOpacity(0.5)
                  : color.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? AppColors.primary : color.withOpacity(0.5),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? AppColors.primary
                      : color.withOpacity(0.5),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              if (count != null && count > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    count.toString(),
                    style: TextStyle(
                      color: isSelected ? Colors.white : color.withOpacity(0.5),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showClearAllConfirmation(BuildContext context) {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearAllNotifications),
        content: Text(l10n.clearAllNotificationsConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              ref.read(notificationControllerProvider.notifier).clearAll();
              Navigator.pop(context);
            },
            child: Text(
              l10n.clearAll,
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return SliverFillRemaining(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Iconsax.notification_status,
                      size: 80,
                      color: AppColors.primary.withOpacity(0.2),
                    ),
                    Positioned(
                      right: 40,
                      top: 40,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.done_all,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text(
                l10n.noNotificationsTitle,
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : Colors.black,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.noNotificationsSubtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white60 : Colors.black54,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationHistory(
    BuildContext context,
    WidgetRef ref,
    List<AppNotification> notifications,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final now = DateTime.now();
    // Sort notifications by timestamp descending (newest first)
    final sortedNotifications = [...notifications]
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    final today = sortedNotifications
        .where((n) => _isSameDay(n.timestamp, now))
        .toList();
    final yesterday = sortedNotifications
        .where(
          (n) => _isSameDay(n.timestamp, now.subtract(const Duration(days: 1))),
        )
        .toList();
    final earlier = sortedNotifications.where((n) {
      final diff = now.difference(n.timestamp).inDays;
      return diff >= 2;
    }).toList();

    return SliverList(
      delegate: SliverChildListDelegate([
        if (today.isNotEmpty) ...[
          _buildSectionHeader(l10n.notificationToday),
          ...today.map(
            (n) => _buildNotificationTile(context, ref, n, isDark, l10n),
          ),
        ],
        if (yesterday.isNotEmpty) ...[
          _buildSectionHeader(l10n.notificationYesterday),
          ...yesterday.map(
            (n) => _buildNotificationTile(context, ref, n, isDark, l10n),
          ),
        ],
        if (earlier.isNotEmpty) ...[
          _buildSectionHeader(l10n.notificationEarlier),
          ...earlier.map(
            (n) => _buildNotificationTile(context, ref, n, isDark, l10n),
          ),
        ],
        const SizedBox(height: 48),
      ]),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: AppColors.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildNotificationTile(
    BuildContext context,
    WidgetRef ref,
    AppNotification notification,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.horizontal,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 24),
        color: AppColors.primary,
        child: Icon(
          notification.isRead ? Icons.mark_as_unread : Icons.done_all,
          color: Colors.white,
        ),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: Colors.redAccent,
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Toggle read/unread
          ref
              .read(notificationControllerProvider.notifier)
              .markAsRead(notification.id, isRead: !notification.isRead);
          return false; // Don't dismiss
        }
        return true; // Dismiss (Delete)
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          final intId = int.tryParse(notification.id);
          if (intId != null) {
            ref
                .read(notificationControllerProvider.notifier)
                .deleteNotification(intId);
          }
        }
      },
      child: InkWell(
        onTap: () => _handleNotificationTap(context, ref, notification),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: notification.isRead
                ? (isDark ? Colors.white.withOpacity(0.02) : Colors.white)
                : (isDark
                      ? AppColors.primary.withOpacity(0.1)
                      : AppColors.primary.withOpacity(0.03)),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: notification.isRead
                  ? (isDark ? Colors.white10 : Colors.black.withOpacity(0.05))
                  : AppColors.primary.withOpacity(0.2),
              width: 1.2,
            ),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: 'notif_icon_${notification.id}',
                child: _buildTypeIcon(notification.type, isDark),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontWeight: notification.isRead
                                  ? FontWeight.w600
                                  : FontWeight.bold,
                              fontSize: 15,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.5),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notification.body,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white70 : Colors.black54,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _getTypeLabel(notification.type, l10n),
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.white38 : Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          DateFormat.Hm().format(notification.timestamp),
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleNotificationTap(
    BuildContext context,
    WidgetRef ref,
    AppNotification notification,
  ) {
    ref
        .read(notificationControllerProvider.notifier)
        .markAsRead(notification.id);

    // Navigation logic based on notification data
    final data = notification.data;
    if (data == null) return;

    ref.read(notificationServiceProvider).navigateToContext(data);
  }

  Widget _buildTypeIcon(NotificationType type, bool isDark) {
    IconData icon;
    Color color;

    switch (type) {
      case NotificationType.content:
        icon = Iconsax.book_1;
        color = Colors.blue;
        break;
      case NotificationType.community:
      case NotificationType.comment_reply:
        icon = Iconsax.messages_1;
        color = Colors.orange;
        break;
      case NotificationType.performance:
        icon = Iconsax.ranking;
        color = Colors.green;
        break;
      case NotificationType.system:
        icon = Iconsax.setting_2;
        color = Colors.purple;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }

  String _getTypeLabel(NotificationType type, AppLocalizations l10n) {
    switch (type) {
      case NotificationType.content:
        return l10n.notificationTypeContent;
      case NotificationType.community:
      case NotificationType.comment_reply:
        return l10n.notificationTypeCommunity;
      case NotificationType.performance:
        return l10n.notificationTypePerformance;
      case NotificationType.system:
        return l10n.notificationTypeSystem;
    }
  }

  Map<String, List<NotificationType>> _getCategories(AppLocalizations l10n) {
    return {
      l10n.notificationTypeContent: [NotificationType.content],
      l10n.notificationTypeCommunity: [
        NotificationType.community,
        NotificationType.comment_reply,
      ],
      l10n.notificationTypePerformance: [NotificationType.performance],
      l10n.notificationTypeSystem: [NotificationType.system],
    };
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
