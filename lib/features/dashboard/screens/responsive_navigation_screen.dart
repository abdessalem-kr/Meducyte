import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/features/explore/presentation/pages/explore_page.dart';
import 'package:meducyte_app/features/simulation/presentation/pages/simulation_page.dart';

class ResponsiveNavigationScreen extends ConsumerStatefulWidget {
  const ResponsiveNavigationScreen({super.key});

  @override
  ConsumerState<ResponsiveNavigationScreen> createState() =>
      _ResponsiveNavigationScreenState();
}

class _ResponsiveNavigationScreenState
    extends ConsumerState<ResponsiveNavigationScreen> {
  //Screens(Must be identical for both layouts)
  final List<Widget> _screens = [
    const HomeScreen(),
    const LearnPage(),
    const ExplorePage(),
    const SimulationPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(navigationIndexProvider);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool useRail = constraints.maxWidth >= 800;

        return Scaffold(
          body: Row(
            children: [
              if (useRail)
                NavigationRail(
                  selectedIndex: currentIndex,
                  onDestinationSelected: (index) {
                    ref.read(navigationIndexProvider.notifier).state = index;
                  },
                  labelType: NavigationRailLabelType.all,
                  backgroundColor: isDark
                      ? AppColors.backgroundDark
                      : AppColors.backgroundLight,
                  indicatorColor: theme.primaryColor.withOpacity(0.12),
                  minWidth: 90,
                  selectedIconTheme: IconThemeData(
                    color: theme.primaryColor,
                    size: 28,
                  ),
                  unselectedIconTheme: IconThemeData(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                    size: 24,
                  ),
                  selectedLabelTextStyle: TextStyle(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                  unselectedLabelTextStyle: TextStyle(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                    fontSize: 12,
                  ),
                  destinations: [
                    NavigationRailDestination(
                      icon: const Icon(Iconsax.home_2),
                      selectedIcon: const Icon(Iconsax.home_1),
                      label: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(l10n.navHome),
                      ),
                    ),
                    NavigationRailDestination(
                      icon: const Icon(Iconsax.book_1),
                      selectedIcon: const Icon(Iconsax.book),
                      label: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(l10n.navLearn),
                      ),
                    ),
                    NavigationRailDestination(
                      icon: const Icon(Iconsax.folder_2),
                      selectedIcon: const Icon(Iconsax.folder_cloud),
                      label: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(l10n.navExplore),
                      ),
                    ),
                    NavigationRailDestination(
                      icon: const Icon(Iconsax.status_up),
                      selectedIcon: const Icon(Iconsax.status_up5),
                      label: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(l10n.navSimulation),
                      ),
                    ),
                  ],
                ),
              if (useRail)
                VerticalDivider(
                  thickness: 1,
                  width: 1,
                  color: isDark
                      ? AppColors.dividerDark
                      : AppColors.dividerLight,
                ),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: useRail ? 1200 : double.infinity,
                    ),
                    child: _screens[currentIndex],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: useRail
              ? null
              : NavigationBar(
                  selectedIndex: currentIndex,
                  onDestinationSelected: (index) {
                    ref.read(navigationIndexProvider.notifier).state = index;
                  },
                  backgroundColor: isDark
                      ? AppColors.backgroundDark
                      : AppColors.backgroundLight,
                  elevation: 0,
                  height: 80,
                  indicatorColor: theme.primaryColor.withOpacity(0.12),
                  labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                  destinations: [
                    NavigationDestination(
                      icon: const Icon(Iconsax.home_2),
                      selectedIcon: const Icon(Iconsax.home_1),
                      label: l10n.navHome,
                    ),
                    NavigationDestination(
                      icon: const Icon(Iconsax.book_1),
                      selectedIcon: const Icon(Iconsax.book),
                      label: l10n.navLearn,
                    ),
                    NavigationDestination(
                      icon: const Icon(Iconsax.folder_2),
                      selectedIcon: const Icon(Iconsax.folder_cloud),
                      label: l10n.navExplore,
                    ),
                    NavigationDestination(
                      icon: const Icon(Iconsax.status_up),
                      selectedIcon: const Icon(Iconsax.status_up5),
                      label: l10n.navSimulation,
                    ),
                  ],
                ),
        );
      },
    );
  }
}
