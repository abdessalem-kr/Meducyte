import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/shared/widgets/notification_badge.dart';

class HomeAppBar extends ConsumerWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topPadding = MediaQuery.of(context).padding.top;
    final userAsync = ref.watch(authControllerProvider);
    final name = userAsync.valueOrNull?.name ?? '';

    return SliverPersistentHeader(
      pinned: true,
      delegate: _HomeHeaderDelegate(
        topPadding: topPadding,
        ref: ref,
        outerContext: context,
        userName: name,
      ),
    );
  }
}

class _HomeHeaderDelegate extends SliverPersistentHeaderDelegate {
  _HomeHeaderDelegate({
    required this.topPadding,
    required this.ref,
    required this.outerContext,
    required this.userName,
  });

  final double topPadding;
  final WidgetRef ref;
  final BuildContext outerContext;
  final String userName;

  static const double _expandedHeight = 150;

  @override
  double get minExtent => kToolbarHeight + topPadding;

  @override
  double get maxExtent => _expandedHeight + topPadding;

  String _greeting() {
    final hour = DateTime.now().hour;
    final l10n = AppLocalizations.of(outerContext)!;
    if (hour < 12) return l10n.goodMorning;
    if (hour < 17) return l10n.goodAfternoon;
    return l10n.goodEvening;
  }

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    //t=1.0 when fully expanded,0.0 when fully collapsed
    final t = (1.0 - shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
    final radius = t * 30.0;
    final br = BorderRadius.vertical(bottom: Radius.circular(radius));

    final name = userName;

    return Material(
      color:
          Colors.transparent, //corner gaps show through to the page background
      child: Container(
        decoration: BoxDecoration(
          borderRadius: br,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primaryDark, Color(0xFF0A1628)],
          ),
        ),
        child: ClipRRect(
          borderRadius: br,
          child: Stack(
            children: [
              // ──AI pattern texture─────────────────────────────────────
              Positioned.fill(
                child: Opacity(
                  opacity: 0.18,
                  child: Image.asset(
                    'assets/images/learn_pattern.png',
                    repeat: ImageRepeat.repeat,
                  ),
                ),
              ),

              // ──Pinned toolbar(always visible) ─────────────────────────
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
                      'Meducyte',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    const NotificationBadge(),
                    const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: ShowMenuMed(),
                    ),
                  ],
                ),
              ),

              // ──Expanded greeting(fades out as it collapses) ────────────
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
                            _greeting(),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            name.isNotEmpty ? 'Dr. $name' : 'Dr.',
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
  bool shouldRebuild(_HomeHeaderDelegate oldDelegate) {
    return oldDelegate.topPadding != topPadding ||
        oldDelegate.ref != ref ||
        oldDelegate.userName != userName;
  }
}
