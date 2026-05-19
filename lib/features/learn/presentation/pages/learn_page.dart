import 'dart:convert';
import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/shared/widgets/notification_badge.dart';
import 'package:meducyte_app/features/learn/presentation/widgets/quiz_hub_section.dart';

class LearnPage extends ConsumerStatefulWidget {
  const LearnPage({super.key});

  @override
  ConsumerState<LearnPage> createState() => _LearnPageState();
}

class _LearnPageState extends ConsumerState<LearnPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedYear = 1;
  final Set<String> _collapsedGroupIds = {};
  Map<int, List<String>> _customOrders = {};

  void _toggleGroup(String id) {
    setState(() {
      if (_collapsedGroupIds.contains(id)) {
        _collapsedGroupIds.remove(id);
      } else {
        _collapsedGroupIds.add(id);
      }
    });
  }

  Future<void> _loadCustomOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('learn_custom_orders');
    if (jsonStr != null) {
      try {
        final Map<String, dynamic> decoded = json.decode(jsonStr);
        setState(() {
          _customOrders = decoded.map(
            (key, value) => MapEntry(int.parse(key), List<String>.from(value)),
          );
        });
      } catch (e) {
        debugPrint('Error loading custom orders: $e');
      }
    }
  }

  Future<void> _saveCustomOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = json.encode(
      _customOrders.map((k, v) => MapEntry(k.toString(), v)),
    );
    await prefs.setString('learn_custom_orders', jsonStr);
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCustomOrders();

    //Initialize selected year from user profile
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authControllerProvider).value;
      if (user != null) {
        setState(() {
          _selectedYear = user.year;
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
    final modulesAsync = ref.watch(learnModulesProvider);
    final primaryColor = Theme.of(context).primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            _buildSliverHeader(context, l10n),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: primaryColor,
                  unselectedLabelColor: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                  indicatorColor: primaryColor,
                  tabs: [
                    Tab(text: l10n.modules),
                    Tab(text: l10n.quizzes),
                  ],
                ),
                isDark,
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            //1.MODULES TAB
            _buildModulesTab(modulesAsync, primaryColor, isDark, l10n),

            //2.QUIZZES TAB
            QuizHubSection(selectedYear: _selectedYear),
          ],
        ),
      ),
    );
  }

  Widget _buildModulesTab(
    AsyncValue<List<LearnModule>> modulesAsync,
    Color primaryColor,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _buildYearFilter(context, primaryColor, isDark, l10n),
        ),
        modulesAsync.when(
          data: (modules) {
            final allTopModules = modules
                .where((m) => m.year == _selectedYear && m.parentId == null)
                .toList();

            final ueiModules = allTopModules
                .where((m) => m.children != null && m.children!.isNotEmpty)
                .toList();
            final standaloneModules = allTopModules
                .where((m) => m.children == null || m.children!.isEmpty)
                .toList();

            //Create display items:UEIs+one synthetic"standalone_group"
            final List<dynamic> displayItems = [...ueiModules];
            if (standaloneModules.isNotEmpty) {
              displayItems.add('standalone_group');
            }

            //Apply custom order if exists
            final yearOrder = _customOrders[_selectedYear] ?? [];
            if (yearOrder.isNotEmpty) {
              displayItems.sort((a, b) {
                final idA = a is LearnModule ? a.id : 'standalone_group';
                final idB = b is LearnModule ? b.id : 'standalone_group';
                final indexA = yearOrder.indexOf(idA);
                final indexB = yearOrder.indexOf(idB);
                if (indexA == -1 && indexB == -1) return 0;
                if (indexA == -1) return 1;
                if (indexB == -1) return -1;
                return indexA.compareTo(indexB);
              });
            }

            if (displayItems.isEmpty) {
              return SliverFillRemaining(
                child: Center(child: Text(l10n.noModulesForYear)),
              );
            }

            //Reordering only for Year 2 and 3
            final bool canReorder =
                _selectedYear > 1 && displayItems.length > 1;

            if (!canReorder) {
              return SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final item = displayItems[index];
                  return _buildReorderableGroup(
                    context,
                    item,
                    primaryColor,
                    isDark,
                    l10n,
                    canReorder: false,
                    standaloneModules: standaloneModules,
                  );
                }, childCount: displayItems.length),
              );
            }

            return SliverReorderableList(
              itemCount: displayItems.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex -= 1;
                  final item = displayItems.removeAt(oldIndex);
                  displayItems.insert(newIndex, item);
                  _customOrders[_selectedYear] = displayItems.map((item) {
                    return item is LearnModule ? item.id : 'standalone_group';
                  }).toList();
                });
                _saveCustomOrders();
              },
              proxyDecorator:
                  (Widget child, int index, Animation<double> animation) {
                    return AnimatedBuilder(
                      animation: animation,
                      builder: (BuildContext context, Widget? child) {
                        return Material(
                          elevation: 10,
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          clipBehavior: Clip.antiAlias,
                          child: ConstrainedBox(
                            //Crop the height during drag to avoid the"oversized drag target"crash
                            constraints: const BoxConstraints(maxHeight: 100),
                            child: child,
                          ),
                        );
                      },
                      child: child,
                    );
                  },
              itemBuilder: (context, index) {
                final item = displayItems[index];
                final String itemId = item is LearnModule
                    ? item.id
                    : 'standalone_group';

                return ReorderableDelayedDragStartListener(
                  key: ValueKey(itemId),
                  index: index,
                  child: _buildReorderableGroup(
                    context,
                    item,
                    primaryColor,
                    isDark,
                    l10n,
                    canReorder: true,
                    standaloneModules: standaloneModules,
                  ),
                );
              },
            );
          },
          loading: () => const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (err, _) =>
              SliverFillRemaining(child: Center(child: Text('$err'))),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
      ],
    );
  }

  Widget _buildReorderableGroup(
    BuildContext context,
    dynamic item,
    Color primaryColor,
    bool isDark,
    AppLocalizations l10n, {
    required bool canReorder,
    required List<LearnModule> standaloneModules,
  }) {
    if (item == 'standalone_group') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildGroupHeader(
            "",
            primaryColor,
            isDark,
            isExpanded: true,
            onTap: null,
            isReorderable: canReorder,
            category: l10n.module.toUpperCase(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = (constraints.maxWidth / 160)
                    .floor()
                    .clamp(2, 4);
                return GridView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: standaloneModules.length,
                  itemBuilder: (context, index) {
                    return _buildModuleCard(
                      context,
                      standaloneModules[index],
                      primaryColor,
                      isDark,
                    );
                  },
                );
              },
            ),
          ),
        ],
      );
    }

    final module = item as LearnModule;
    final children = module.children;
    final isExpanded = !_collapsedGroupIds.contains(module.id);
    final hasChildren = children != null && children.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildGroupHeader(
          module.name,
          primaryColor,
          isDark,
          isExpanded: isExpanded,
          onTap: hasChildren ? () => _toggleGroup(module.id) : null,
          isReorderable: canReorder,
          category: hasChildren
              ? l10n.unitOfIntegratedTeaching.toUpperCase()
              : l10n.module.toUpperCase(),
        ),
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: hasChildren
                ? LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = (constraints.maxWidth / 160)
                          .floor()
                          .clamp(2, 4);
                      return GridView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.85,
                        ),
                        itemCount: children.length,
                        itemBuilder: (context, index) {
                          return _buildModuleCard(
                            context,
                            children[index],
                            primaryColor,
                            isDark,
                          );
                        },
                      );
                    },
                  )
                : SizedBox(
                    width: 200,
                    child: _buildModuleCard(
                      context,
                      module,
                      primaryColor,
                      isDark,
                    ),
                  ),
          ),
      ],
    );
  }

  Widget _buildGroupHeader(
    String name,
    Color primaryColor,
    bool isDark, {
    bool isExpanded = true,
    VoidCallback? onTap,
    bool isReorderable = false,
    String? category,
  }) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (isReorderable) ...[
                    Icon(
                      Icons.drag_indicator,
                      color: primaryColor.withOpacity(0.5),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Container(
                    width: 3,
                    height: 14,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(1.5),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (category != null)
                    Text(
                      category,
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                ],
              ),
              if (category != null) const SizedBox(height: 6),
              if (name.isNotEmpty)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                    ),
                    if (onTap != null) ...[
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: primaryColor,
                          size: 24,
                        ),
                      ),
                    ],
                  ],
                ),
              const SizedBox(height: 8),
              Container(
                height: 1,
                width: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primaryColor.withOpacity(0.5),
                      primaryColor.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliverHeader(BuildContext context, AppLocalizations l10n) {
    final topPadding = MediaQuery.of(context).padding.top;
    return SliverPersistentHeader(
      pinned: true,
      delegate: _LearnHeaderDelegate(topPadding: topPadding, l10n: l10n),
    );
  }

  Widget _buildYearFilter(
    BuildContext context,
    Color primaryColor,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final user = ref.watch(authControllerProvider).value;
    final isResidency = user?.year == 7 && (user?.isSubscriber ?? false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                l10n.studyYear,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 7,
            itemBuilder: (context, index) {
              final year = index + 1;
              final isSelected = _selectedYear == year;

              String labelText;
              if (year == 1) {
                labelText = l10n.firstYearOrdinal;
              } else if (year == 7) {
                labelText = l10n.residencyExam;
              } else {
                labelText = l10n.otherYearOrdinal(year.toString());
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(labelText),
                      if (!isResidency && !isSelected) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Iconsax.lock,
                          size: 14,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ],
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (isResidency) {
                      if (selected) setState(() => _selectedYear = year);
                    } else if (selected && !isSelected) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.upgradeToResidencyToUnlockYears),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  selectedColor: primaryColor,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : (isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight),
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  backgroundColor: isDark
                      ? AppColors.surfaceDark
                      : AppColors.backgroundLight,
                  elevation: isSelected ? 4 : 0,
                  shadowColor: primaryColor.withOpacity(0.4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildModuleCard(
    BuildContext context,
    LearnModule module,
    Color primaryColor,
    bool isDark,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () {
        context.push('/learn/module/${module.id}');
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              Positioned(
                top: -20,
                right: -20,
                child: Icon(
                  Iconsax.book,
                  size: 100,
                  color: primaryColor.withOpacity(0.05),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        _getModuleIcon(module.name),
                        color: primaryColor,
                        size: 24,
                      ),
                    ),
                    if (module.isFree) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.green.withOpacity(0.3),
                          ),
                        ),
                        child: const Text(
                          "FREE PREVIEW",
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Text(
                      module.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${module.lessons?.length ?? 0} ${module.lessons?.length == 1 ? l10n.lesson : l10n.lessons}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppColors.textSecondaryDark.withOpacity(0.7)
                            : AppColors.textSecondaryLight.withOpacity(0.7),
                      ),
                    ),
                    const Spacer(),
                    Consumer(
                      builder: (context, ref, child) {
                        final progress = ref.watch(
                          moduleProgressProvider(module.id),
                        );
                        final percentage = (progress * 100).toInt();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '$percentage%',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: primaryColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: progress,
                              backgroundColor: primaryColor.withOpacity(0.1),
                              color: primaryColor,
                              minHeight: 4,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getModuleIcon(String name) {
    name = name.toLowerCase();
    if (name.contains('cardio')) return Iconsax.heart;
    if (name.contains('pneu')) return Iconsax.mask;
    if (name.contains('gastro')) return Iconsax.cake;
    if (name.contains('neuro')) return Iconsax.flash;
    if (name.contains('pediatrie')) return Iconsax.user;
    if (name.contains('gyneco')) return Iconsax.woman;
    return Iconsax.book_1;
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar, this.isDark);

  final TabBar _tabBar;
  final bool isDark;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

class _LearnHeaderDelegate extends SliverPersistentHeaderDelegate {
  _LearnHeaderDelegate({required this.topPadding, required this.l10n});

  final double topPadding;
  final AppLocalizations l10n;

  static const double _expandedHeight = 150;

  @override
  double get minExtent => kToolbarHeight + topPadding;

  @override
  double get maxExtent => _expandedHeight + topPadding;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final t = (1.0 - shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
    final radius = t * 30.0;
    final br = BorderRadius.vertical(bottom: Radius.circular(radius));

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: br,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primaryDark, AppColors.backgroundDark],
          ),
        ),
        child: ClipRRect(
          borderRadius: br,
          child: Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: 0.18,
                  child: Image.asset(
                    'assets/images/learn_pattern.png',
                    repeat: ImageRepeat.repeat,
                  ),
                ),
              ),
              Positioned(
                top: topPadding,
                left: 0,
                right: 0,
                height: kToolbarHeight,
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    Image.asset('assets/images/logo.png', height: 32),
                    const SizedBox(width: 10),
                    Text(
                      l10n.navLearn,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    const NotificationBadge(),
                    IconButton(
                      icon: const Icon(
                        Iconsax.search_normal,
                        color: Colors.white,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              if (t > 0)
                Positioned(
                  bottom: 0,
                  left: 24,
                  right: 24,
                  child: Opacity(
                    opacity: t,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.yourJourney,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.navLearn,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_LearnHeaderDelegate oldDelegate) {
    return oldDelegate.topPadding != topPadding;
  }
}
