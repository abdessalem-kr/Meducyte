import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meducyte_app/core/database/app_database.dart';
import 'package:meducyte_app/shared/providers/database_provider.dart';
import 'package:meducyte_app/features/chatbot/data/repositories/chat_repository.dart';
import 'package:meducyte_app/features/chatbot/domain/models/chat_models.dart';
import 'package:meducyte_app/shared/providers/network_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:meducyte_app/l10n/arb/locale_provider.dart';
import 'package:meducyte_app/l10n/arb/app_localizations_en.dart';
import 'package:meducyte_app/l10n/arb/app_localizations_fr.dart';
import 'package:meducyte_app/features/auth/application/providers/auth_provider.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ChatRepository(dioClient.dio);
});

final currentSessionIdProvider = StateProvider<int?>((ref) => null);

final chatSessionsProvider = FutureProvider<List<DbChatSession>>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  return db.getAllSessions();
});

class ChatMessagesNotifier extends StateNotifier<List<ChatMessage>> {
  final ChatRepository _repository;
  final AppDatabase _db;
  final Ref _ref;

  ChatMessagesNotifier(this._repository, this._db, this._ref) : super([]);

  Future<void> loadSession(int sessionId) async {
    final dbMessages = await _db.getMessagesForSession(sessionId);
    state = dbMessages
        .map(
          (m) => ChatMessage(
            id: m.id.toString(),
            sessionId: m.sessionId,
            text: m.content, //content column
            isUser: m.isUser,
            timestamp: m.timestamp,
          ),
        )
        .toList();
    _ref.read(currentSessionIdProvider.notifier).state = sessionId;
  }

  Future<void> sendMessage(String text) async {
    final user = _ref.read(authControllerProvider).value;
    final isSubscriber = user?.isSubscriber ?? false;

    if (!isSubscriber) {
      final messageCount = await _db.getTotalUserMessageCount();
      if (messageCount >= 5) {
        throw Exception('LIMIT_REACHED');
      }
    }

    var sessionId = _ref.read(currentSessionIdProvider);

    //Create session if it doesn't exist
    if (sessionId == null) {
      final title = text.length > 30 ? '${text.substring(0, 30)}...' : text;
      sessionId = await _db.createSession(title);
      _ref.read(currentSessionIdProvider.notifier).state = sessionId;
      _ref.invalidate(chatSessionsProvider);
    }

    final userMessage = ChatMessage(
      id: const Uuid().v4(),
      sessionId: sessionId,
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    state = [...state, userMessage];
    await _db.insertMessage(sessionId, text, true);

    try {
      final aiMessage = await _repository.sendMessage(
        state.sublist(0, state.length - 1),
        text,
      );

      final savedAiMessage = aiMessage.copyWith(sessionId: sessionId);
      state = [...state, savedAiMessage];
      await _db.insertMessage(sessionId, aiMessage.text, false);
    } catch (e) {
      if (e.toString().contains('LIMIT_REACHED')) {
        rethrow;
      }
      final locale = _ref.read(localeProvider);
      final errorMsg = locale.languageCode == 'fr'
          ? AppLocalizationsFr().chatbotError
          : AppLocalizationsEn().chatbotError;

      final errorMessage = ChatMessage(
        id: const Uuid().v4(),
        sessionId: sessionId,
        text: errorMsg,
        isUser: false,
        timestamp: DateTime.now(),
      );
      state = [...state, errorMessage];
    }
  }

  Future<void> refineMessage(String messageId, String instruction) async {
    final originalMessage = state.firstWhere((m) => m.id == messageId);
    final prompt =
        "About your previous message:\n\"${originalMessage.text}\"\n\n$instruction";
    await sendMessage(prompt);
  }

  Future<void> sendAiAction(String messageId, String actionLabel) async {
    final originalMessage = state.firstWhere((m) => m.id == messageId);
    String prompt;
    if (actionLabel.toLowerCase() == "summary" ||
        actionLabel.toLowerCase() == "summarize") {
      prompt =
          "Summarize your previous message in 3-5 bullet points:\n\"${originalMessage.text}\"";
    } else if (actionLabel.toLowerCase() == "mnemonic") {
      prompt =
          "Create a medical mnemonic to help me remember the following content:\n\"${originalMessage.text}\"";
    } else {
      prompt =
          "Explain in more detail the following part of your previous message:\n\"${originalMessage.text}\"";
    }
    await sendMessage(prompt);
  }

  Future<void> startNewSession() async {
    _ref.read(currentSessionIdProvider.notifier).state = null;
    state = [];
  }

  void clearHistory() {
    final sessionId = _ref.read(currentSessionIdProvider);
    if (sessionId != null) {
      _db.deleteSession(sessionId);
      _ref.invalidate(chatSessionsProvider);
    }
    state = [];
    _ref.read(currentSessionIdProvider.notifier).state = null;
  }
}

final chatMessagesProvider =
    StateNotifierProvider<ChatMessagesNotifier, List<ChatMessage>>((ref) {
      final repository = ref.watch(chatRepositoryProvider);
      final db = ref.watch(appDatabaseProvider);
      return ChatMessagesNotifier(repository, db, ref);
    });

final isChatLoadingProvider = StateProvider<bool>((ref) => false);

final chatMessageCountProvider = FutureProvider<int>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  return db.getTotalUserMessageCount();
});
