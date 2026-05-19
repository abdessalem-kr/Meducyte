import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/features/simulation/domain/models/simulation_models.dart';
import 'package:meducyte_app/features/simulation/presentation/providers/simulation_providers.dart';

class InterviewTab extends ConsumerStatefulWidget {
  final SimSession session;
  const InterviewTab({super.key, required this.session});

  @override
  ConsumerState<InterviewTab> createState() => _InterviewTabState();
}

class _InterviewTabState extends ConsumerState<InterviewTab> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSend() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    _messageController.clear();
    ref.read(simSessionProvider.notifier).sendMessage(text);
    _scrollToBottom();
  }

  void _showDiagnosisDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.simFinalDiagnosis),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: l10n.simEnterPathology,
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.simCancel),
          ),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(simSessionProvider.notifier)
                  .submitDiagnosis(controller.text);
              Navigator.pop(context);
            },
            child: Text(l10n.simSubmit),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.session;
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: session.messages.length,
            itemBuilder: (context, index) {
              final msg = session.messages[index];
              return ChatBubble(msg: msg);
            },
          ),
        ),
        if (session.isTyping) _buildTypingIndicator(),
        _buildInputArea(context),
      ],
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          AppLocalizations.of(context)!.simPatientThinking,
          style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildInputArea(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(color: theme.dividerColor.withOpacity(0.1)),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Iconsax.receipt_search, color: AppColors.primary),
            onPressed: () => _showDiagnosisDialog(context),
            tooltip: AppLocalizations.of(context)!.simFinalDiagnosis,
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.simInterviewHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: theme.cardColor,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              onSubmitted: (_) => _handleSend(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Iconsax.send_1, color: AppColors.primary),
            onPressed: _handleSend,
          ),
        ],
      ),
    );
  }
}

/// A single chat bubble in the interview tab.
class ChatBubble extends ConsumerWidget {
  final SimMessage msg;
  const ChatBubble({super.key, required this.msg});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final session = ref.watch(simSessionProvider).value;
    final isJunior = session?.difficulty == SimulationDifficulty.junior;

    return Align(
      alignment: msg.isFromUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: msg.isFromUser ? theme.primaryColor : theme.cardColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(msg.isFromUser ? 16 : 0),
            bottomRight: Radius.circular(msg.isFromUser ? 0 : 16),
          ),
          border: msg.isFromUser ? null : Border.all(color: theme.dividerColor.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              msg.text,
              style: TextStyle(
                color: msg.isFromUser ? Colors.white : theme.textTheme.bodyLarge?.color,
                fontSize: 14,
                fontWeight: msg.rawResult != null ? FontWeight.bold : null,
              ),
            ),
            if (msg.rawResult != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: msg.isFromUser
                      ? Colors.white.withOpacity(0.1)
                      : theme.scaffoldBackgroundColor.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  msg.rawResult!,
                  style: TextStyle(
                    color: msg.isFromUser ? Colors.white : theme.primaryColor,
                    fontSize: 13,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
            if (msg.media != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black.withOpacity(0.1)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      msg.media!.type == MediaType.audio ? Iconsax.volume_high : Iconsax.document_filter,
                      size: 14,
                      color: msg.isFromUser ? Colors.white : AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context)!.simViewMedia(msg.media!.type.name.toUpperCase()),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: msg.isFromUser ? Colors.white : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (msg.interpretation != null && isJunior) ...[
              const SizedBox(height: 12),
              if (msg.isRevealed)
                Container(
                  padding: const EdgeInsets.all(12),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.simExpertInterpretation,
                        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        msg.interpretation!,
                        style: const TextStyle(fontSize: 12, color: Colors.green),
                      ),
                    ],
                  ),
                )
              else
                OutlinedButton(
                  onPressed: () => ref.read(simSessionProvider.notifier).revealInterpretation(msg.id),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Iconsax.eye, size: 14),
                      const SizedBox(width: 8),
                      Text(AppLocalizations.of(context)!.simRevealInterpretation.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
