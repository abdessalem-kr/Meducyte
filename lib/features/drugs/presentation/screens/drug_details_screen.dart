import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:meducyte_app/core/themes/app_colors.dart';
import 'package:meducyte_app/l10n/arb/app_localizations.dart';
import 'package:meducyte_app/features/drugs/data/providers/drug_providers.dart';
import 'package:meducyte_app/shared/widgets/subscription_gate.dart';

class DrugDetailsScreen extends ConsumerWidget {
  final String drugId;

  const DrugDetailsScreen({super.key, required this.drugId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final drugAsync = ref.watch(drugDetailsProvider(drugId));

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.viewDetails),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        foregroundColor: theme.textTheme.titleLarge?.color,
      ),
      body: drugAsync.when(
        data: (drug) {
          if (drug == null) {
            return Center(
              child: Text(AppLocalizations.of(context)!.drugNotFound),
            );
          }
          return SubscriptionGate(
            isEnabled: !drug.isFree,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //Header Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primaryDark, Color(0xFF1A5A96)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          drug.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          drug.genericName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                drug.category ??
                                    AppLocalizations.of(context)!.general,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            if (drug.dosage.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.white24),
                                ),
                                child: Text(
                                  drug.dosage,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  //Administrative Info
                  _DetailSection(
                    title: AppLocalizations.of(context)!.administrativeInfos,
                    icon: Iconsax.document_text,
                    initiallyExpanded: true,
                    contentWidget: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (drug.therapeuticClass != null &&
                            drug.therapeuticClass!.isNotEmpty)
                          _MetaDataItem(
                            label: AppLocalizations.of(
                              context,
                            )!.therapeuticClass,
                            value: drug.therapeuticClass!,
                          ),
                        _MetaDataItem(
                          label: AppLocalizations.of(context)!.labAndForm,
                          value: drug.drugClass,
                        ),
                      ],
                    ),
                  ),

                  if (drug.indications.isNotEmpty)
                    _DetailSection(
                      title: AppLocalizations.of(
                        context,
                      )!.therapeuticIndications,
                      icon: Iconsax.tick_circle,
                      content: drug.indications.join('\n'),
                      isList: true,
                      initiallyExpanded: true,
                    ),
                  if (drug.contraindications.isNotEmpty)
                    _DetailSection(
                      title: AppLocalizations.of(context)!.contraindications,
                      icon: Iconsax.close_circle,
                      content: drug.contraindications.join('\n'),
                      isList: true,
                      color: Colors.redAccent,
                    ),
                  if (drug.sideEffects.isNotEmpty)
                    _DetailSection(
                      title: AppLocalizations.of(context)!.sideEffects,
                      icon: Iconsax.warning_2,
                      content: drug.sideEffects,
                    ),
                  if (drug.mechanismOfAction.isNotEmpty)
                    _DetailSection(
                      title: AppLocalizations.of(context)!.mechanismOfAction,
                      icon: Iconsax.information,
                      content: drug.mechanismOfAction,
                    ),

                  //Info section for non-enriched drugs
                  if (drug.indications.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryDark.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primaryDark.withOpacity(0.1),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Iconsax.info_circle,
                            color: AppColors.primaryDark,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              AppLocalizations.of(
                                context,
                              )!.clinicalInfoUpdating,
                              style: const TextStyle(
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
        loading: () => Skeletonizer(
          enabled: true,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //Header Card Mockup
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Nom du médicament factice",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Nom générique du médicament",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "Catégorie du médicament",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                //Administrative Info Section Mockup
                _DetailSection(
                  title: "Informations Administratives",
                  icon: Iconsax.document_text,
                  initiallyExpanded: true,
                  contentWidget: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      _MetaDataItem(
                        label: "Classe thérapeutique",
                        value: "Classe thérapeutique factice de chargement",
                      ),
                      _MetaDataItem(
                        label: "Laboratoire et Forme",
                        value: "Laboratoire factice et forme",
                      ),
                    ],
                  ),
                ),
                _DetailSection(
                  title: "Indications Thérapeutiques",
                  icon: Iconsax.tick_circle,
                  content: "Indication factice de chargement 1\nIndication factice de chargement 2",
                  isList: true,
                  initiallyExpanded: true,
                ),
              ],
            ),
          ),
        ),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

class _DetailSection extends StatefulWidget {
  final String title;
  final IconData icon;
  final String? content;
  final Widget? contentWidget;
  final bool isList;
  final Color? color;
  final bool initiallyExpanded;

  const _DetailSection({
    required this.title,
    required this.icon,
    this.content,
    this.contentWidget,
    this.isList = false,
    this.color,
    this.initiallyExpanded = false,
  });

  @override
  State<_DetailSection> createState() => _DetailSectionState();
}

class _DetailSectionState extends State<_DetailSection> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      widget.icon,
                      size: 20,
                      color: widget.color ?? AppColors.primaryDark,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: widget.color,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Iconsax.arrow_down_1,
                        size: 16,
                        color: widget.color ?? AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox(width: double.infinity),
              secondChild: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child:
                    widget.contentWidget ??
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: (widget.content ?? '').split('\n').map((line) {
                        if (line.isEmpty) return const SizedBox();
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (widget.isList)
                                const Padding(
                                  padding: EdgeInsets.only(top: 6, right: 8),
                                  child: Icon(
                                    Icons.circle,
                                    size: 5,
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                              Expanded(
                                child: Text(
                                  line,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
              ),
              crossFadeState: _isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaDataItem extends StatelessWidget {
  final String label;
  final String value;

  const _MetaDataItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.hintColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
