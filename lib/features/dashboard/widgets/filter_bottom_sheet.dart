import 'package:meducyte_app/export.dart';

class FilterBottomSheet extends ConsumerStatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  ConsumerState<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<FilterBottomSheet> {
  late String _filter;
  late String _sort;
  late String _specialty;

  @override
  void initState() {
    super.initState();
    //Initialize with current Riverpod values
    _filter = ref.read(selectedFilterProvider);
    _sort = ref.read(selectedSortProvider);
    _specialty = ref.read(selectedSpecialtyProvider);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final specialtiesAsync = ref.watch(medicalSpecialtiesProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.6,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.backgroundDark : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.4 : 0.1),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Grab handle
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.15) : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Header title, reset, close
              Row(
                children: [
                  Text(
                    AppLocalizations.of(context)!.filters,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  const Spacer(),
                  if (_filter != 'All' || _sort != 'Relevance' || _specialty != 'All')
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _filter = 'All';
                          _sort = 'Relevance';
                          _specialty = 'All';
                        });
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      child: const Text(
                        'Reset All',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close, 
                        size: 16,
                        color: isDark ? Colors.grey[400] : Colors.grey[700],
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              Expanded(
                child: ListView(
                  controller: scrollController,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // Categories (2x2 Grid)
                    Text(
                      AppLocalizations.of(context)!.category,
                      style: const TextStyle(
                        fontSize: 15, 
                        fontWeight: FontWeight.bold, 
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 2.3,
                      children: [
                        _buildCategoryCard('All', Iconsax.category, 'All Categories', _filter == 'All', () => setState(() => _filter = 'All')),
                        _buildCategoryCard('Drugs', Iconsax.health, 'Drugs & Meds', _filter == 'Drugs', () => setState(() => _filter = 'Drugs')),
                        _buildCategoryCard('Diseases', Iconsax.activity, 'Diseases', _filter == 'Diseases', () => setState(() => _filter = 'Diseases')),
                        _buildCategoryCard('Abbreviations', Iconsax.document_text, 'Abbreviations', _filter == 'Abbreviations', () => setState(() => _filter = 'Abbreviations')),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Sort By
                    Text(
                      AppLocalizations.of(context)!.sortBy,
                      style: const TextStyle(
                        fontSize: 15, 
                        fontWeight: FontWeight.bold, 
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildSortOption('Relevance', Iconsax.sort, 'Relevance', _sort == 'Relevance', () => setState(() => _sort = 'Relevance')),
                        _buildSortOption('Newest', Iconsax.calendar, 'Newest', _sort == 'Newest', () => setState(() => _sort = 'Newest')),
                        _buildSortOption('Alphabetical', Iconsax.text, 'Alphabetical', _sort == 'Alphabetical', () => setState(() => _sort = 'Alphabetical')),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Medical Specialty
                    const Text(
                      'Medical Specialty',
                      style: TextStyle(
                        fontSize: 15, 
                        fontWeight: FontWeight.bold, 
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    specialtiesAsync.when(
                      data: (specialties) {
                        final list = ['All', ...specialties];
                        return Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: list.map((spec) {
                            return _buildSpecialtyOption(
                              spec, 
                              spec, 
                              _specialty == spec, 
                              () => setState(() => _specialty = spec),
                            );
                          }).toList(),
                        );
                      },
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          ),
                        ),
                      ),
                      error: (err, stack) => Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildSpecialtyOption(
                            'All', 
                            'All Specialties', 
                            _specialty == 'All', 
                            () => setState(() => _specialty = 'All'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              
              // Apply Button
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                height: 54,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.primaryDark,
                      AppColors.primary,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryDark.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(selectedFilterProvider.notifier).state = _filter;
                    ref.read(selectedSortProvider.notifier).state = _sort;
                    ref.read(selectedSpecialtyProvider.notifier).state = _specialty;
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.applyFilters,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryCard(
    String value, 
    IconData icon, 
    String label, 
    bool isSelected, 
    VoidCallback onTap
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: isSelected 
          ? (isDark ? AppColors.primary.withOpacity(0.15) : AppColors.primaryLight.withOpacity(0.5))
          : (isDark ? AppColors.surfaceDark : Colors.grey[50]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected 
            ? AppColors.primary 
            : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.04)),
          width: 1.5,
        ),
        boxShadow: isSelected ? [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.12),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ] : [],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected 
                    ? AppColors.primary 
                    : (isDark ? Colors.white.withOpacity(0.05) : Colors.grey[200]),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isSelected ? Colors.white : (isDark ? Colors.grey[400] : Colors.grey[600]),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected 
                      ? (isDark ? Colors.white : AppColors.primaryDark) 
                      : (isDark ? Colors.grey[300] : Colors.black87),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSortOption(
    String value, 
    IconData icon, 
    String label, 
    bool isSelected, 
    VoidCallback onTap
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: isSelected 
          ? AppColors.primary 
          : (isDark ? AppColors.surfaceDark : Colors.grey[50]),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected 
            ? AppColors.primary 
            : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.04)),
          width: 1.5,
        ),
        boxShadow: isSelected ? [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ] : [],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : (isDark ? Colors.grey[400] : Colors.grey[600]),
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : (isDark ? Colors.grey[300] : Colors.black87),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialtyOption(
    String value, 
    String label, 
    bool isSelected, 
    VoidCallback onTap
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = AppColors.primary;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: isSelected 
          ? primaryColor.withOpacity(isDark ? 0.15 : 0.1) 
          : (isDark ? AppColors.surfaceDark : Colors.grey[50]),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected 
            ? primaryColor 
            : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.04)),
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSelected) ...[
                Icon(
                  Icons.check_circle_rounded,
                  color: primaryColor,
                  size: 16,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? primaryColor : (isDark ? Colors.grey[300] : Colors.black87),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
