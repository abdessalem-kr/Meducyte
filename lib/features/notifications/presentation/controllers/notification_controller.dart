import 'dart:async';
import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/features/notifications/domain/models/notification.dart';
import 'package:meducyte_app/features/notifications/data/repositories/notification_repository.dart';

class NotificationController extends StateNotifier<List<AppNotification>>
    with WidgetsBindingObserver {
  final NotificationRepository _repository;
  final Ref _ref;
  StreamSubscription? _subscription;
  String? _currentUserId;

  NotificationController(this._repository, this._ref) : super([]) {
    _currentUserId = _ref.read(authControllerProvider).value?.id.toString();
    _init();
    
    // Watch for user changes to refresh notifications
    _ref.listen<AsyncValue<User?>>(authControllerProvider, (previous, next) {
      final newUserId = next.value?.id.toString();
      if (newUserId != _currentUserId) {
        _currentUserId = newUserId;
        _init();
      }
    });

    WidgetsBinding.instance.addObserver(this);
  }

  void _init() {
    _subscription?.cancel();
    _subscription = _repository.watchNotifications(_currentUserId).listen((notifications) {
      state = notifications;
    });

    // Sync with backend on init without awaiting so it doesn't block
    if (_currentUserId != null) {
      _repository.syncNotificationsWithBackend(_currentUserId);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _currentUserId != null) {
      // Refresh local stream and sync with backend when app resumes
      _repository.syncNotificationsWithBackend(_currentUserId);
    }
  }

  Future<void> markAsRead(String id, {bool isRead = true}) async {
    final intId = int.tryParse(id);
    if (intId != null) {
      await _repository.markAsRead(intId, _currentUserId, isRead: isRead);
    }
  }

  Future<void> markAllAsRead() async {
    await _repository.markAllAsRead(_currentUserId);
  }

  Future<void> deleteNotification(int id) async {
    await _repository.deleteNotification(id);
  }

  Future<void> clearAll() async {
    await _repository.clearAll(_currentUserId);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _subscription?.cancel();
    super.dispose();
  }

  int get unreadCount => state.where((n) => !n.isRead).length;
}

final notificationControllerProvider =
    StateNotifierProvider<NotificationController, List<AppNotification>>((ref) {
      final repository = ref.watch(notificationRepositoryProvider);
      return NotificationController(repository, ref);
    });
