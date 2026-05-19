import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/core/themes/quiz_theme_extension.dart';

class QuizTopBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onClose;
  final String timerText;
  final VoidCallback? onChatTap;
  final VoidCallback? onFlagTap;
  final VoidCallback? onStarTap;
  final VoidCallback? onStarLongPress;
  final VoidCallback? onShareTap;
  final VoidCallback? onFontSizeTap;
  final bool isStarred;
  final bool isInSrs;
  final bool showTimer;
  final bool isTrial;
  final int? trialQuestionIndex;
  final int trialLimit;

  const QuizTopBar({
    super.key,
    required this.onClose,
    required this.timerText,
    this.onChatTap,
    this.onFlagTap,
    this.onStarTap,
    this.onStarLongPress,
    this.onShareTap,
    this.onFontSizeTap,
    this.isStarred = false,
    this.isInSrs = false,
    this.showTimer = true,
    this.isTrial = false,
    this.trialQuestionIndex,
    this.trialLimit = 10,
  });

  @override
  Widget build(BuildContext context) {
    final quizTheme = Theme.of(context).extension<QuizThemeExtension>()!;
    final primaryColor = Theme.of(context).primaryColor;

    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 8,
        right: 8,
        bottom: 8,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          //Center:Timer&Trial Badge
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showTimer)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Iconsax.timer_1,
                      color: quizTheme.secondaryTextColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      timerText,
                      style: TextStyle(
                        color: quizTheme.primaryTextColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          //Left&Right content
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: onClose,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  Iconsax.close_circle,
                  color: quizTheme.secondaryTextColor,
                  size: 28,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _TopBarAction(
                    onTap: onChatTap,
                    icon: Iconsax.messages_3,
                    color: primaryColor,
                  ),
                  const SizedBox(width: 10),
                  _TopBarAction(
                    onTap: onStarTap,
                    onLongPress: onStarLongPress,
                    icon: isStarred ? Iconsax.star5 : Iconsax.star,
                    color: isStarred ? Colors.amber : primaryColor,
                  ),
                  const SizedBox(width: 6),
                  _buildMoreMenu(context, primaryColor, quizTheme),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);

  Widget _buildMoreMenu(
    BuildContext context,
    Color primaryColor,
    QuizThemeExtension quizTheme,
  ) {
    final l10n = context.l10n;
    return PopupMenuButton<String>(
      icon: Icon(Iconsax.more, color: quizTheme.secondaryTextColor, size: 24),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      offset: const Offset(0, 40),
      onSelected: (value) {
        switch (value) {
          case 'font':
            onFontSizeTap?.call();
            break;
          case 'report':
            onFlagTap?.call();
            break;
          case 'share':
            onShareTap?.call();
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'font',
          child: Row(
            children: [
              Icon(Iconsax.text_italic, color: primaryColor, size: 20),
              const SizedBox(width: 12),
              Text(l10n.textSize),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'share',
          child: Row(
            children: [
              Icon(Iconsax.gallery_export, color: primaryColor, size: 20),
              const SizedBox(width: 12),
              Text(l10n.shareQuestion),
            ],
          ),
        ),
        const PopupMenuDivider(height: 1),
        PopupMenuItem(
          value: 'report',
          child: Row(
            children: [
              const Icon(Iconsax.flag, color: Colors.redAccent, size: 20),
              const SizedBox(width: 12),
              Text(
                l10n.reportQuestion,
                style: const TextStyle(color: Colors.redAccent),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TopBarAction extends StatelessWidget {
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final IconData icon;
  final Color color;

  const _TopBarAction({
    required this.onTap,
    this.onLongPress,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(10),
      child: Icon(icon, color: color, size: 24),
    );
  }
}
