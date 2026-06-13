import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:meducyte_app/core/themes/app_colors.dart';
import 'package:meducyte_app/l10n/arb/app_localizations.dart';
import 'package:meducyte_app/features/drugs/data/providers/drug_providers.dart';
import 'package:meducyte_app/features/drugs/domain/models/drug_models.dart';
import 'package:meducyte_app/features/chatbot/domain/models/chat_models.dart';
import 'package:meducyte_app/features/chatbot/data/providers/chat_providers.dart';

class DrugInteractionsScreen extends ConsumerWidget {
  const DrugInteractionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selectedDrugs = ref.watch(selectedDrugsProvider);
    final interactionsAsync = ref.watch(drugInteractionsProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.drugInteractions),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        foregroundColor: theme.textTheme.titleLarge?.color,
        actions: [
          IconButton(
            icon: Icon(Iconsax.magicpen, color: AppColors.primary),
            tooltip: "Pharmacology Assistant",
            onPressed: () => _showAiHelperSheet(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          //Selected Drugs Header
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.selectedDrugs,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _showAddDrugBottomSheet(context, ref),
                      icon: const Icon(Icons.add, size: 18),
                      label: Text(AppLocalizations.of(context)!.addDrug),
                    ),
                  ],
                ),
                if (selectedDrugs.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      AppLocalizations.of(context)!.noDrugsSelectedPrompt,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: selectedDrugs.map((drug) {
                      return Chip(
                        label: Text(drug.name),
                        onDeleted: () {
                          ref
                              .read(selectedDrugsProvider.notifier)
                              .update(
                                (state) => state
                                    .where((d) => d.id != drug.id)
                                    .toList(),
                              );
                        },
                        deleteIcon: const Icon(Icons.close, size: 16),
                        backgroundColor: AppColors.primaryDark.withOpacity(0.1),
                        labelStyle: const TextStyle(
                          color: AppColors.primaryDark,
                        ),
                        side: BorderSide.none,
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),

          const Divider(height: 1),

          //Interactions List
          Expanded(
            child: interactionsAsync.when(
              data: (interactions) {
                if (selectedDrugs.length < 2) {
                  return _InteractionPlaceholder(
                    icon: Iconsax.info_circle,
                    text: AppLocalizations.of(context)!.selectTwoDrugsPrompt,
                  );
                }
                if (interactions.isEmpty) {
                  return _InteractionPlaceholder(
                    icon: Iconsax.tick_circle,
                    text: AppLocalizations.of(context)!.noInteractionsFound,
                    color: Colors.green,
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: interactions.length,
                  itemBuilder: (context, index) {
                    final interaction = interactions[index];
                    return _InteractionCard(interaction: interaction);
                  },
                );
              },
              loading: () => Skeletonizer(
                enabled: true,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text("MODÉRÉ"),
                              ),
                              const Spacer(),
                              const Icon(Iconsax.warning_2, size: 16, color: Colors.amber),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Médicament A vs Médicament B",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Description de l'interaction médicamenteuse factice de chargement...",
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Prise en charge",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const Text("Prise en charge de l'interaction factice..."),
                        ],
                      ),
                    );
                  },
                ),
              ),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddDrugBottomSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _AddDrugBottomSheet(),
    );
  }

  String _compileDrugContext(WidgetRef ref) {
    final selectedDrugs = ref.read(selectedDrugsProvider);
    final interactions = ref.read(drugInteractionsProvider).value ?? [];

    final buffer = StringBuffer();
    buffer.writeln("Médicaments sélectionnés :");
    for (final drug in selectedDrugs) {
      buffer.writeln("- ${drug.name} (Générique : ${drug.genericName})");
    }

    if (interactions.isNotEmpty) {
      buffer.writeln("\nInteractions détectées :");
      for (final interaction in interactions) {
        final drug1 = selectedDrugs.firstWhere(
          (d) => d.id == interaction.drugId1,
          orElse: () => Drug(
            id: '',
            name: 'Inconnu',
            genericName: '',
            drugClass: '',
            indications: [],
            contraindications: [],
            dosage: '',
            sideEffects: '',
            mechanismOfAction: '',
          ),
        ).name;
        final drug2 = selectedDrugs.firstWhere(
          (d) => d.id == interaction.drugId2,
          orElse: () => Drug(
            id: '',
            name: 'Inconnu',
            genericName: '',
            drugClass: '',
            indications: [],
            contraindications: [],
            dosage: '',
            sideEffects: '',
            mechanismOfAction: '',
          ),
        ).name;
        buffer.writeln("- $drug1 vs $drug2 (Sévérité : ${interaction.severity.name})");
        buffer.writeln("  Description : ${interaction.description}");
        buffer.writeln("  Prise en charge : ${interaction.management}");
      }
    } else {
      buffer.writeln("\nAucune interaction médicamenteuse détectée.");
    }
    return buffer.toString();
  }

  void _showAiHelperSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DrugInteractionsAiHelperSheet(
        compileContext: () => _compileDrugContext(ref),
        selectedDrugs: ref.read(selectedDrugsProvider),
      ),
    );
  }
}

class _InteractionPlaceholder extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;

  const _InteractionPlaceholder({
    required this.icon,
    required this.text,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: color ?? theme.hintColor.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              text,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.hintColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InteractionCard extends ConsumerWidget {
  final DrugInteraction interaction;

  const _InteractionCard({required this.interaction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final drugs = ref.watch(selectedDrugsProvider);
    final drug1 = drugs.firstWhere((d) => d.id == interaction.drugId1).name;
    final drug2 = drugs.firstWhere((d) => d.id == interaction.drugId2).name;

    Color severityColor;
    String severityText;
    switch (interaction.severity) {
      case InteractionSeverity.severe:
        severityColor = Colors.red;
        severityText = AppLocalizations.of(context)!.severe;
        break;
      case InteractionSeverity.moderate:
        severityColor = Colors.orange;
        severityText = AppLocalizations.of(context)!.moderate;
        break;
      case InteractionSeverity.minor:
        severityColor = Colors.blue;
        severityText = AppLocalizations.of(context)!.minor;
      default:
        severityColor = theme.hintColor;
        severityText = '';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: severityColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: severityColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  severityText.toUpperCase(),
                  style: TextStyle(
                    color: severityColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              const Icon(Iconsax.warning_2, size: 16, color: Colors.amber),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '$drug1 vs$drug2',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(interaction.description, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context)!.management,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: severityColor,
            ),
          ),
          Text(interaction.management, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _AddDrugBottomSheet extends ConsumerStatefulWidget {
  const _AddDrugBottomSheet();

  @override
  ConsumerState<_AddDrugBottomSheet> createState() =>
      _AddDrugBottomSheetState();
}

class _AddDrugBottomSheetState extends ConsumerState<_AddDrugBottomSheet> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final drugSearchAsync = ref.watch(interactionDrugSearchProvider);
    final query = ref.watch(interactionSearchQueryProvider);
    final selectedDrugs = ref.watch(selectedDrugsProvider);

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Text(
                  AppLocalizations.of(context)!.addDrugToChecker,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) =>
                  ref.read(interactionSearchQueryProvider.notifier).state =
                      value,
              autofocus: true,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.searchDrugHint,
                prefixIcon: const Icon(Iconsax.search_normal),
                suffixIcon: query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchController.clear();
                          ref
                                  .read(interactionSearchQueryProvider.notifier)
                                  .state =
                              '';
                        },
                      )
                    : null,
                filled: true,
                fillColor: theme.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: drugSearchAsync.when(
              data: (drugs) {
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: drugs.length,
                  itemBuilder: (context, index) {
                    final drug = drugs[index];
                    final isSelected = selectedDrugs.any(
                      (d) => d.id == drug.id,
                    );

                    return ListTile(
                      title: Text(drug.name),
                      subtitle: Text(drug.genericName),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : const Icon(Icons.add_circle_outline),
                      onTap: () {
                        if (isSelected) {
                          ref
                              .read(selectedDrugsProvider.notifier)
                              .update(
                                (state) => state
                                    .where((d) => d.id != drug.id)
                                    .toList(),
                              );
                        } else {
                          ref
                              .read(selectedDrugsProvider.notifier)
                              .update((state) => [...state, drug]);
                        }
                      },
                    );
                  },
                );
              },
              loading: () => Skeletonizer(
                enabled: true,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: const Text("Nom du médicament factice"),
                      subtitle: const Text("Nom générique du médicament"),
                      trailing: const Icon(Icons.add_circle_outline),
                    );
                  },
                ),
              ),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Drug Interactions AI Helper Sheet Widget
// -----------------------------------------------------------------------------
class _DrugInteractionsAiHelperSheet extends ConsumerStatefulWidget {
  final String Function() compileContext;
  final List<Drug> selectedDrugs;

  const _DrugInteractionsAiHelperSheet({
    required this.compileContext,
    required this.selectedDrugs,
  });

  @override
  ConsumerState<_DrugInteractionsAiHelperSheet> createState() =>
      __DrugInteractionsAiHelperSheetState();
}

class __DrugInteractionsAiHelperSheetState
    extends ConsumerState<_DrugInteractionsAiHelperSheet> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final drugNames = widget.selectedDrugs.map((d) => d.name).join(', ');
    final introText = widget.selectedDrugs.isEmpty
        ? "Bonjour ! Je suis votre assistant pharmacologique Meducyte AI. Veuillez sélectionner des médicaments pour analyser leurs interactions, ou posez-moi vos questions de pharmacologie !"
        : "Bonjour ! Je suis votre assistant pharmacologique Meducyte AI. J'ai analysé votre sélection ($drugNames).\nComment puis-je vous aider (explications des mécanismes, alternatives thérapeutiques, ajustement des doses) ?";
    _messages.add(
      ChatMessage(
        id: 'welcome',
        text: introText,
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
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

  Future<void> _handleSend([String? textToSend]) async {
    final text = textToSend ?? _controller.text.trim();
    if (text.isEmpty) return;

    if (textToSend == null) {
      _controller.clear();
    }

    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      final chatRepo = ref.read(chatRepositoryProvider);
      final drugContext = widget.compileContext();

      final aiResponse = await chatRepo.sendDrugInteractionChatMessage(
        history: _messages.sublist(1, _messages.length - 1),
        message: text,
        drugContext: drugContext,
      );

      if (mounted) {
        setState(() {
          _messages.add(aiResponse);
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(
            ChatMessage(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              text: "Une erreur est survenue lors de la communication avec l'assistant pharmacologique: $e",
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
          _isLoading = false;
        });
        _scrollToBottom();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.80,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Iconsax.magicpen, color: AppColors.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Assistant Pharmacologique",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Analyse et gestion des interactions médicamenteuses",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Iconsax.close_circle),
                  color: theme.hintColor,
                ),
              ],
            ),
          ),
          const Divider(height: 32),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildChatBubble(message);
              },
            ),
          ),
          if (_messages.length == 1) _buildSuggestions(),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: LinearProgressIndicator(
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primary,
                ),
              ),
            ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    final suggestions = [
      "Mécanisme de l'interaction",
      "Alternatives thérapeutiques",
      "Ajustement de dose / Suivi",
      "Gravité et risques cliniques",
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: suggestions.map((s) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ActionChip(
                label: Text(s, style: const TextStyle(fontSize: 12)),
                backgroundColor: Theme.of(context).cardColor,
                elevation: 0,
                pressElevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: Theme.of(context).dividerColor.withOpacity(0.1),
                  ),
                ),
                onPressed: () => _handleSend(s),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage message) {
    final theme = Theme.of(context);
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              margin: const EdgeInsets.only(right: 8, top: 4),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smart_toy_outlined,
                color: AppColors.primary,
                size: 14,
              ),
            ),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser
                    ? AppColors.primary
                    : theme.cardColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                border: isUser
                    ? null
                    : Border.all(
                        color: theme.dividerColor.withOpacity(0.08),
                      ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  isUser
                      ? Text(
                          message.text,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                          ),
                        )
                      : MarkdownBody(
                          data: message.text,
                          selectable: true,
                          styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                            p: theme.textTheme.bodyMedium?.copyWith(
                              height: 1.6,
                              fontSize: 14.5,
                            ),
                            h3: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: theme.primaryColor,
                            ),
                            blockquote: theme.textTheme.bodyMedium?.copyWith(
                              fontStyle: FontStyle.italic,
                              color: Colors.amber[900],
                            ),
                            blockquotePadding: const EdgeInsets.all(12),
                            blockquoteDecoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(8),
                              border: Border(
                                left: BorderSide(color: Colors.amber[700]!, width: 4),
                              ),
                            ),
                            tableBorder: TableBorder.all(
                              color: theme.dividerColor.withOpacity(0.2),
                              width: 1,
                            ),
                            tableCellsPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            tableHead: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                  if (!isUser && message.id != 'welcome') ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Iconsax.copy, size: 16),
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                          tooltip: "Copier la suggestion",
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: message.text));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Copié dans le presse-papiers !"),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ]
                ],
              ),
            ),
          ),
          if (isUser) ...[
            Container(
              margin: const EdgeInsets.only(left: 8, top: 4),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_outline,
                color: AppColors.primary,
                size: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(
          top: BorderSide(color: theme.dividerColor.withOpacity(0.1)),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: "Posez votre question pharmacologique...",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 8),
                ),
                onSubmitted: (_) => _handleSend(),
              ),
            ),
            IconButton(
              icon: const Icon(Iconsax.send_1, color: AppColors.primary),
              onPressed: _handleSend,
            ),
          ],
        ),
      ),
    );
  }
}
