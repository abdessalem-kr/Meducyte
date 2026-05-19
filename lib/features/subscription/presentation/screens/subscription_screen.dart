import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meducyte_app/core/access/feature_access.dart';
import 'package:meducyte_app/export.dart' show AppLocalizations, Iconsax;
import 'package:meducyte_app/features/subscription/data/models/subscription_model.dart';
import 'package:meducyte_app/features/subscription/data/providers/subscription_provider.dart';
import 'package:meducyte_app/features/subscription/presentation/screens/chargily_checkout_screen.dart';
import 'package:meducyte_app/features/auth/application/providers/auth_provider.dart';

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? selectedPlanId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          selectedPlanId = null; //Reset selection when switching tiers
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final plansAsync = ref.watch(subscriptionPlansProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final activeOffer = ref.watch(activeOfferProvider);
    final user = ref.watch(authControllerProvider).value;

    //Determine plan type based on user year
    final String targetLevel = (user != null && user.year >= 7)
        ? 'residency'
        : 'student';
    final String levelLabel = targetLevel == 'residency'
        ? "Residency"
        : "Medical Student";

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: theme.primaryColor,
            centerTitle: true,
            title: Text(
              l10n.subscription,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            actions: [
              if (user != null && !user.isSubscriber)
                IconButton(
                  icon: const Icon(Iconsax.logout, color: Colors.white),
                  onPressed: () =>
                      ref.read(authControllerProvider.notifier).logout(),
                  tooltip: l10n.logout,
                ),
            ],
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              indicatorWeight: 4,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withOpacity(0.7),
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              tabs: [
                Tab(text: l10n.basicPlan.toUpperCase()),
                Tab(text: l10n.premiumPlan.toUpperCase()),
              ],
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.primaryColor,
                      theme.primaryColor.withBlue(200),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -50,
                      top: -50,
                      child: Icon(
                        Iconsax.crown,
                        size: 250,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.only(bottom: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "${levelLabel.toUpperCase()}EDITION",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 32.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    theme,
                    "${_tabController.index == 0 ? l10n.basicPlan : l10n.premiumPlan}Plans($levelLabel)",
                  ),
                  const SizedBox(height: 24),
                  plansAsync.when(
                    data: (plans) {
                      final isPremiumTab = _tabController.index == 1;

                      //Filter by level AND tab type(Basic vs Premium)
                      final filteredPlans = plans.where((p) {
                        return p.accessLevel == targetLevel &&
                            p.hasAiAccess == isPremiumTab;
                      }).toList();

                      //Sort plans:Yearly first(Best Value),then 3mo,then Monthly
                      filteredPlans.sort((a, b) {
                        if (a.durationMonths != b.durationMonths) {
                          return b.durationMonths.compareTo(a.durationMonths);
                        }
                        return a.price.compareTo(b.price);
                      });

                      return Column(
                        children: filteredPlans
                            .map((plan) => _buildPlanCard(plan, theme))
                            .toList(),
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, st) =>
                        Center(child: Text("Error loading plans: $e")),
                  ),
                  const SizedBox(height: 32),
                  _buildSectionHeader(theme, "Features Comparison"),
                  const SizedBox(height: 16),
                  _buildComparisonTable(theme, l10n),
                  const SizedBox(height: 32),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildBottomAction(theme, activeOffer),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.primaryColor,
      ),
    );
  }

  Widget _buildPlanCard(SubscriptionPlan plan, ThemeData theme) {
    final isSelected = selectedPlanId == plan.id;
    final isBestValue = plan.durationMonths == 12;

    return GestureDetector(
      onTap: () => setState(() => selectedPlanId = plan.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? (plan.hasAiAccess ? Colors.amber[700]! : theme.primaryColor)
                : Colors.grey.withOpacity(0.2),
            width: 2,
          ),
          color: isSelected
              ? (plan.hasAiAccess
                    ? Colors.amber[700]!.withOpacity(0.05)
                    : theme.primaryColor.withOpacity(0.05))
              : theme.cardColor,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color:
                        (plan.hasAiAccess
                                ? Colors.amber[700]!
                                : theme.primaryColor)
                            .withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            if (isBestValue)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber[700],
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(18),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "BEST VALUE",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? (plan.hasAiAccess
                                  ? Colors.amber[700]!
                                  : theme.primaryColor)
                            : Colors.grey.withOpacity(0.5),
                        width: 2,
                      ),
                      color: isSelected
                          ? (plan.hasAiAccess
                                ? Colors.amber[700]!
                                : theme.primaryColor)
                          : Colors.transparent,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                plan.name.split(' (')[0],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            _buildTierBadge(plan.hasAiAccess),
                          ],
                        ),
                        Text(
                          "${plan.durationMonths}Month${plan.durationMonths > 1 ? 's' : ''}Access",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (plan.hasAiAccess)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Row(
                              children: [
                                Icon(
                                  Iconsax.magic_star,
                                  size: 14,
                                  color: Colors.amber[700],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "AI Features Included",
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.amber[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "${plan.price.toInt()}DA",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: isSelected
                              ? (plan.hasAiAccess
                                    ? Colors.amber[700]
                                    : theme.primaryColor)
                              : null,
                        ),
                      ),
                      if (plan.durationMonths > 1)
                        Text(
                          "${(plan.price / plan.durationMonths).toInt()}DA/mo",
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
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
    );
  }

  Widget _buildComparisonTable(ThemeData theme, AppLocalizations l10n) {
    final features = [
      FeatureId.standardQuiz,
      FeatureId.basicCourses,
      FeatureId.basicCalculators,
      FeatureId.customQuiz,
      FeatureId.drugDatabase,
      FeatureId.aiTutor,
      FeatureId.premiumCourses,
      FeatureId.studyGroups,
      FeatureId.aiCaseAnalysis,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(theme, l10n.comparePlans),
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              _buildComparisonHeader(l10n),
              const Divider(height: 1),
              ...features.map((f) => _buildComparisonRow(theme, f)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonHeader(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          const Expanded(flex: 3, child: SizedBox.shrink()),
          Expanded(
            flex: 2,
            child: Text(
              l10n.basicPlan.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 10,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              l10n.premiumPlan.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 10,
                color: Colors.amber[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(ThemeData theme, FeatureId feature) {
    final requiredTier = FeaturePolicy.getRequiredTier(feature);
    final label = FeaturePolicy.getFeatureLabel(feature);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ),
          //Basic Access
          Expanded(
            flex: 2,
            child: Center(
              child: _buildAccessIndicator(
                SubscriptionTier.basic >= requiredTier,
                theme.primaryColor,
              ),
            ),
          ),
          //Premium Access
          Expanded(
            flex: 2,
            child: Center(
              child: _buildAccessIndicator(
                SubscriptionTier.premium >= requiredTier,
                Colors.amber[700]!,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccessIndicator(bool hasAccess, Color color) {
    return hasAccess
        ? Icon(Icons.check_circle, color: color, size: 20)
        : Icon(Icons.lock, color: Colors.grey.withOpacity(0.3), size: 18);
  }

  Widget _buildTierBadge(bool isPremium) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isPremium ? Colors.amber[700] : Colors.blue[100],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isPremium ? "PREMIUM" : "BASIC",
        style: TextStyle(
          color: isPremium ? Colors.white : Colors.blue[900],
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBottomAction(ThemeData theme, dynamic activeOffer) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.1))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (activeOffer != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text(
                "Discount Applied: ${activeOffer.discountPercent}%Off!",
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          //Error display
          ref
              .watch(subscriptionControllerProvider)
              .when(
                data: (_) => const SizedBox.shrink(),
                loading: () => const Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: LinearProgressIndicator(),
                ),
                error: (err, _) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    err.toString(),
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              ),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: selectedPlanId == null
                  ? null
                  : () async {
                      final url = await ref
                          .read(subscriptionControllerProvider.notifier)
                          .subscribeWithChargily(selectedPlanId!);

                      if (url != null && mounted) {
                        final result = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ChargilyCheckoutScreen(checkoutUrl: url),
                          ),
                        );

                        if (result == true && mounted) {
                          //Payment successful,refresh user state
                          ref.read(authControllerProvider.notifier).getUser();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Abonnement activéavec succès!"),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                "Secure Checkout",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "Cancel anytime.Secure encryption enabled.",
            style: TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
