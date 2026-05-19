import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meducyte_app/core/routes/routes.dart';
import 'package:meducyte_app/export.dart' show Iconsax;
import 'package:go_router/go_router.dart';
import 'package:meducyte_app/features/notifications/presentation/controllers/notification_controller.dart';

class NotificationBadge extends ConsumerWidget {
  final Color? color;

  const NotificationBadge({super.key, this.color});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationControllerProvider);
    final unreadCount = notifications.where((n) => !n.isRead).length;

    return IconButton(
      icon: Stack(
        children: [
          Icon(Iconsax.notification, color: color ?? Colors.white),
          if (unreadCount > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(6),
                ),
                constraints: const BoxConstraints(minWidth: 12, minHeight: 12),
                child: Text(
                  unreadCount > 9 ? '9+' : '$unreadCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
      onPressed: () => context.push(AppRoutes.notifications),
    );
  }
}
