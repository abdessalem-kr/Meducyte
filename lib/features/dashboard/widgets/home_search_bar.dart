import 'package:meducyte_app/export.dart';

class HomeSearchBar extends ConsumerStatefulWidget implements PreferredSizeWidget {
  final TextEditingController controller;
  final void Function(String) onChanged;
  final VoidCallback onFilterPressed;
  final VoidCallback onClear;

  const HomeSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onFilterPressed,
    required this.onClear,
  });

  @override
  ConsumerState<HomeSearchBar> createState() => _HomeSearchBarState();

  @override
  Size get preferredSize => const Size.fromHeight(72);
}

class _HomeSearchBarState extends ConsumerState<HomeSearchBar> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Watch filter states to compute active filters count
    final filter = ref.watch(selectedFilterProvider);
    final sort = ref.watch(selectedSortProvider);
    final specialty = ref.watch(selectedSpecialtyProvider);

    int activeFiltersCount = 0;
    if (filter != 'All') activeFiltersCount++;
    if (sort != 'Relevance') activeFiltersCount++;
    if (specialty != 'All') activeFiltersCount++;

    return SliverAppBar(
      floating: true,
      snap: true,
      primary: false,
      elevation: 0,
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      toolbarHeight: 72,
      title: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                // Animated Search Bar Container
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _isFocused
                            ? AppColors.primary
                            : (isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.04)),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _isFocused
                              ? AppColors.primary.withOpacity(0.08)
                              : Colors.black.withOpacity(0.04),
                          blurRadius: _isFocused ? 14 : 10,
                          offset: Offset(0, _isFocused ? 6 : 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: widget.controller,
                      focusNode: _focusNode,
                      onChanged: widget.onChanged,
                      style: TextStyle(
                        fontSize: 15,
                        color: isDark ? Colors.white : AppColors.primaryDark,
                      ),
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.searchHint,
                        hintStyle: TextStyle(
                          color: isDark ? Colors.grey[500] : Colors.grey[400],
                          fontSize: 14,
                        ),
                        prefixIcon: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          child: Icon(
                            Iconsax.search_normal_1,
                            size: 20,
                            color: _isFocused
                                ? AppColors.primary
                                : (isDark ? Colors.grey[500] : Colors.grey[400]),
                          ),
                        ),
                        suffixIcon: widget.controller.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.close,
                                  color: isDark ? Colors.grey[400] : Colors.grey[500],
                                  size: 18,
                                ),
                                onPressed: widget.onClear,
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Professional Filter Button with Active Badge
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
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
                          color: isDark
                              ? (activeFiltersCount > 0 ? AppColors.primary : Colors.white.withOpacity(0.08))
                              : Colors.transparent,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withOpacity(0.2)
                                : AppColors.primaryDark.withOpacity(activeFiltersCount > 0 ? 0.35 : 0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: widget.onFilterPressed,
                        icon: Icon(
                          Iconsax.setting_4,
                          color: isDark ? (activeFiltersCount > 0 ? AppColors.accentDark : Colors.white) : Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                    
                    // Badge notification count
                    if (activeFiltersCount > 0)
                      Positioned(
                        top: -5,
                        right: -5,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.elasticOut,
                          builder: (context, scale, child) {
                            return Transform.scale(
                              scale: scale,
                              child: child,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(
                              color: AppColors.accentLight,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 20,
                              minHeight: 20,
                            ),
                            child: Center(
                              child: Text(
                                '$activeFiltersCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
