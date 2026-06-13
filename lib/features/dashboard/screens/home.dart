import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/features/dashboard/widgets/home_app_bar.dart';
import 'package:meducyte_app/features/dashboard/widgets/home_search_bar.dart';
import 'package:meducyte_app/features/dashboard/widgets/quick_access_item.dart';
import 'package:meducyte_app/features/dashboard/widgets/filter_bottom_sheet.dart';
import 'package:meducyte_app/features/dashboard/widgets/search_results_overlay.dart';
import 'package:meducyte_app/features/dashboard/widgets/dashboard_cards_carousel.dart';
import 'package:meducyte_app/features/dashboard/widgets/subscribe_card.dart';

import 'package:meducyte_app/features/drugs/presentation/screens/drug_database_screen.dart';
import 'package:meducyte_app/features/drugs/presentation/screens/drug_interactions_screen.dart';
import 'package:meducyte_app/features/chatbot/presentation/screens/chat_chatbot_screen.dart';
import 'package:meducyte_app/features/learn/presentation/screens/dictionary_screen.dart';

import 'package:meducyte_app/features/productive_bay/presentation/widgets/productive_bay_section.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      ref.read(searchQueryProvider.notifier).state = _searchController.text;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FilterBottomSheet(),
    );
  }

  void _onDismissSearch() {
    _searchController.clear();
    ref.read(searchQueryProvider.notifier).state = '';
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: Stack(
        children: [
          NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                const HomeAppBar(),
                HomeSearchBar(
                  controller: _searchController,
                  onChanged: (value) {},
                  onFilterPressed: () {
                    FocusScope.of(context).unfocus();
                    _showFilterBottomSheet();
                  },
                  onClear: _onDismissSearch,
                ),
              ];
            },
            body: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const DashboardCardsCarousel(),
                      if (!(ref
                              .watch(authControllerProvider)
                              .value
                              ?.isSubscriber ??
                          false)) ...[
                        const SizedBox(height: 24),
                        const SubscribeCard(),
                      ],
                      const SizedBox(height: 32),
                      const ProductiveBaySection(),
                      const SizedBox(height: 32),
                      const QuickAccessSection(),
                      const SizedBox(height: 100), //Space for bottom padding
                    ]),
                  ),
                ),
              ],
            ),
          ),

          //Floating Search Results Overlay
          SearchResultsOverlay(
            controller: _searchController,
            onDismiss: _onDismissSearch,
          ),
        ],
      ),
      floatingActionButton: Container(
        height: 54,
        width: 54,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [AppColors.surfaceDark, AppColors.surfaceDark.withOpacity(0.8)]
                : [AppColors.primaryDark, AppColors.primary],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.08) : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.2)
                  : AppColors.primaryDark.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatBotScreen()),
              );
            },
            child: const Center(
              child: Icon(
                Iconsax.message_question,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class QuickAccessSection extends StatelessWidget {
  const QuickAccessSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                l10n.quickAccess,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildGrid(context, l10n),
        ],
      ),
    );
  }

  Widget _buildGrid(BuildContext context, AppLocalizations l10n) {
    final items = [
      QuickAccessItem(
        icon: Iconsax.monitor,
        title: l10n.quizTraining,
        onTap: () {
          context.push(
            AppRoutes.quizTraining,
            extra: {'isPractice': true, 'isExplore': false},
          );
        },
      ),
      QuickAccessItem(
        icon: Iconsax.book,
        title: l10n.drugDatabase,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DrugDatabaseScreen()),
          );
        },
      ),
      QuickAccessItem(
        icon: Iconsax.warning_2,
        title: l10n.drugInteractions,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DrugInteractionsScreen(),
            ),
          );
        },
      ),
      QuickAccessItem(
        icon: Iconsax.book_1,
        title: l10n.medicalAbbreviations,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DictionaryScreen()),
          );
        },
      ),
      QuickAccessItem(
        icon: Iconsax.clipboard_text,
        title: l10n.observationReport,
        onTap: () {
          context.push(AppRoutes.observation);
        },
      ),
      QuickAccessItem(
        icon: Iconsax.calculator,
        title: l10n.medicalCalculator,
        onTap: () {
          context.push(AppRoutes.medicalCalculator);
        },
      ),
    ];

    if (MediaQuery.of(context).size.width < 700) {
      return Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            items[i],
            if (i < items.length - 1) const SizedBox(height: 12),
          ],
        ],
      );
    }

    return GridView(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 300,
        mainAxisExtent: 84,
        mainAxisSpacing: 12,
        crossAxisSpacing: 16,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: items,
    );
  }
}
