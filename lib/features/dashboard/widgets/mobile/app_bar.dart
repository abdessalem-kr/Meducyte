import 'package:meducyte_app/export.dart';

class ShowMenuMed extends ConsumerWidget {
  const ShowMenuMed({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return PopupMenuButton<int>(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Theme.of(context).cardColor,
      tooltip: '',
      offset: const Offset(0, 40),
      icon: Icon(
        Iconsax.more_circle,
        size: 26,
        color: Colors.white,
        //Theme.of(context).iconTheme.color,
      ),
      constraints: const BoxConstraints(maxWidth: 200),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 0,
          child: Row(
            children: [
              const Icon(Iconsax.profile_2user, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(l10n.profile, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 1,
          child: Row(
            children: [
              const Icon(Iconsax.setting, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(l10n.settings, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 2,
          child: Row(
            children: [
              const Icon(Iconsax.logout, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(l10n.logout, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ),
      ],
      onSelected: (int value) {
        if (value == 0) {
          context.push(AppRoutes.profile);
        } else if (value == 1) {
          context.push(AppRoutes.settings);
        } else if (value == 2) {
          ref.read(authControllerProvider.notifier).logout();
        }
      },
    );
  }
}
