import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/features/simulation/domain/models/simulation_models.dart';
import 'package:meducyte_app/features/simulation/presentation/providers/simulation_providers.dart';
import 'package:meducyte_app/features/simulation/presentation/widgets/clinical_media_viewer.dart';

/// Shows a newly designed investigation modal from scratch.
void showInvestigationModal(
  BuildContext context,
  WidgetRef ref,
  String name,
  String type, {
  bool skipTrigger = false,
}) {
  final notifier = ref.read(simSessionProvider.notifier);

  if (!skipTrigger) {
    if (type == 'lab') {
      notifier.orderLabTest(name);
    } else {
      notifier.performPhysicalExam(name);
    }
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _InvestigationBottomSheet(name: name, type: type),
  );
}

class _InvestigationBottomSheet extends ConsumerWidget {
  final String name;
  final String type;

  const _InvestigationBottomSheet({required this.name, required this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final session = ref.watch(simSessionProvider).value;

    if (session == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final msg = session.messages.lastWhere(
      (m) =>
          (m.text == "[EXAM] $name" || m.text == "[LAB] $name") &&
          (m.rawResult != null || m.media != null),
      orElse: () =>
          const SimMessage(id: "loading", text: "loading", isFromUser: false),
    );

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: msg.id == "loading"
            ? _buildLoadingState(l10n)
            : _buildContent(context, ref, session, msg, scrollController),
      ),
    );
  }

  Widget _buildLoadingState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(l10n.simRetrievingData),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    SimSession session,
    SimMessage msg,
    ScrollController scrollController,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.all(24),
      children: [
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.dividerColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Placeholder for the new design
        Text(
          "New Investigation Modal: $name",
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        if (msg.media != null) ClinicalMediaViewer(media: msg.media!),
        const SizedBox(height: 16),
        Text(msg.rawResult ?? l10n.simNoDataAvailable),
        const SizedBox(height: 100),
      ],
    );
  }
}
