import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/features/calculator/presentation/providers/calculator_provider.dart';
import 'package:meducyte_app/features/calculator/domain/models/calculator_models.dart';

class MedicalCalculatorScreen extends ConsumerStatefulWidget {
  const MedicalCalculatorScreen({super.key});

  @override
  ConsumerState<MedicalCalculatorScreen> createState() =>
      _MedicalCalculatorScreenState();
}

class _MedicalCalculatorScreenState
    extends ConsumerState<MedicalCalculatorScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final calculatorsAsync = ref.watch(filteredCalculatorsProvider);
    final searchQuery = ref.watch(calculatorSearchQueryProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Text(
              l10n.medicalCalculator,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            backgroundColor: AppColors.backgroundLight,
            actions: [
              if (searchQuery.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(calculatorSearchQueryProvider.notifier).state = '';
                  },
                ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: SearchBar(
                controller: _searchController,
                hintText: 'Search 380+calculators...',
                leading: const Icon(
                  Iconsax.search_normal,
                  color: AppColors.primary,
                ),
                onChanged: (value) =>
                    ref.read(calculatorSearchQueryProvider.notifier).state =
                        value,
                elevation: const WidgetStatePropertyAll(0),
                backgroundColor: WidgetStatePropertyAll(Colors.white),
                padding: const WidgetStatePropertyAll(
                  EdgeInsets.symmetric(horizontal: 16.0),
                ),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
          calculatorsAsync.when(
            data: (categories) {
              if (categories.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Iconsax.search_status,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text('No calculators found matching your search.'),
                      ],
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.only(bottom: 32.0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final category = categories[index];
                    return _CategorySection(category: category);
                  }, childCount: categories.length),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, stack) => SliverFillRemaining(
              child: Center(child: Text('Error loading calculators: $err')),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  final CalculatorCategory category;

  const _CategorySection({required this.category});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  category.name.replaceAll('_', ' '),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Text(
                '${category.calculators.length}',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListView.separated(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: category.calculators.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              indent: 16,
              endIndent: 16,
              color: Colors.grey[100],
            ),
            itemBuilder: (context, index) {
              final calc = category.calculators[index];
              return _CalculatorTile(calculator: calc);
            },
          ),
        ),
      ],
    );
  }
}

class _CalculatorTile extends StatelessWidget {
  final MedicalCalculatorMetadata calculator;

  const _CalculatorTile({required this.calculator});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 4.0,
      ),
      title: Text(
        calculator.name,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
      ),
      subtitle:
          calculator
              .localizedDescription(
                Localizations.localeOf(context).languageCode,
              )
              .isNotEmpty
          ? Text(
              calculator.localizedDescription(
                Localizations.localeOf(context).languageCode,
              ),
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            )
          : null,
      trailing: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Iconsax.arrow_right_3,
          size: 12,
          color: AppColors.primary,
        ),
      ),
      onTap: () {
        if (calculator.id == 'bmi') {
          context.push(AppRoutes.bmi);
        } else if (calculator.id == 'glasgow') {
          context.push(AppRoutes.glasgow);
        } else if (calculator.id == 'apgar') {
          context.push(AppRoutes.apgar);
        } else if (calculator.id == 'wellsep') {
          context.push(AppRoutes.wells);
        } else if (calculator.id == 'cha2ds2vasc') {
          context.push(AppRoutes.cha2ds2vasc);
        } else if (calculator.schema != null) {
          context.push(
            AppRoutes.generic.replaceAll(':id', calculator.id),
            extra: calculator,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${calculator.name}is coming soon!'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              backgroundColor: AppColors.primaryDark,
            ),
          );
        }
      },
    );
  }
}
