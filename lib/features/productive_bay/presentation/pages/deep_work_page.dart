import 'package:meducyte_app/export.dart';
import 'package:collection/collection.dart';
import 'package:meducyte_app/features/productive_bay/data/providers/pomodoro_provider.dart';
import 'package:meducyte_app/features/productive_bay/data/providers/ambient_sound_provider.dart';
import 'package:meducyte_app/features/productive_bay/domain/models/pomodoro_models.dart';

class DeepWorkPage extends ConsumerStatefulWidget {
  const DeepWorkPage({super.key});

  @override
  ConsumerState<DeepWorkPage> createState() => _DeepWorkPageState();
}

class _DeepWorkPageState extends ConsumerState<DeepWorkPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(pomodoroProvider);
    final notifier = ref.read(pomodoroProvider.notifier);
    final tasksAsync = ref.watch(productiveBayProvider);
    final theme = Theme.of(context);

    final minutes = session.remainingSeconds ~/ 60;
    final seconds = session.remainingSeconds % 60;

    final gradientColors = _getGradientColors(session.type, theme);

    //Find active task
    final activeTask = tasksAsync.maybeWhen(
      data: (tasks) => tasks.firstWhereOrNull((t) => t.id == session.taskId),
      orElse: () => null,
    );

    return PopScope(
      canPop: session.state != PomodoroState.running,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldExit = await _showExitConfirmation(context);
        if (shouldExit && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                //Back Button
                Positioned(
                  top: 20,
                  left: 20,
                  child: IconButton(
                    icon: const Icon(Iconsax.arrow_left_2, color: Colors.white),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ),

                //Content
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSessionBadge(session.type),
                      const SizedBox(height: 48),
                      ScaleTransition(
                        scale:
                            Tween(
                              begin: 1.0,
                              end: session.state == PomodoroState.running
                                  ? 1.05
                                  : 1.0,
                            ).animate(
                              CurvedAnimation(
                                parent: _pulseController,
                                curve: Curves.easeInOut,
                              ),
                            ),
                        child: Text(
                          "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}",
                          style: const TextStyle(
                            fontSize: 100,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -4,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                offset: Offset(0, 10),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          activeTask?.title ?? context.l10n.deepWorkMode,
                          key: ValueKey(activeTask?.id ?? 'none'),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (activeTask != null)
                        Text(
                          "SÉANCE DE FOCUS",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2,
                          ),
                        ),
                      const SizedBox(height: 64),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildMainButton(
                            onPressed: () {
                              if (session.state == PomodoroState.running) {
                                notifier.pauseSession();
                              } else {
                                notifier.startSession();
                              }
                            },
                            icon: session.state == PomodoroState.running
                                ? Iconsax.pause
                                : Iconsax.play,
                            size: 84,
                          ),
                          const SizedBox(width: 32),
                          _buildSecondaryButton(
                            onPressed: () => notifier.stopSession(),
                            icon: Iconsax.refresh,
                          ),
                        ],
                      ),
                      const SizedBox(height: 80),
                      _buildAmbientSelector(theme),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Color> _getGradientColors(PomodoroSessionType type, ThemeData theme) {
    switch (type) {
      case PomodoroSessionType.work:
        return [theme.primaryColor, theme.primaryColor.withOpacity(0.8)];
      case PomodoroSessionType.shortBreak:
        return [Colors.green.shade600, Colors.green.shade400];
      case PomodoroSessionType.longBreak:
        return [Colors.blue.shade700, Colors.blue.shade500];
    }
  }

  Widget _buildSessionBadge(PomodoroSessionType type) {
    String label;
    IconData icon;
    switch (type) {
      case PomodoroSessionType.work:
        label = context.l10n.deepWork;
        icon = Iconsax.flash;
        break;
      case PomodoroSessionType.shortBreak:
        label = context.l10n.shortBreak;
        icon = Iconsax.coffee;
        break;
      case PomodoroSessionType.longBreak:
        label = context.l10n.longBreak;
        icon = Iconsax.moon;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainButton({
    required VoidCallback onPressed,
    required IconData icon,
    required double size,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(size / 2),
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.black, size: size * 0.4),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required VoidCallback onPressed,
    required IconData icon,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildAmbientSelector(ThemeData theme) {
    final activeSound = ref.watch(ambientSoundProvider);
    final sounds = [
      _AmbientSound('None', context.l10n.none, Iconsax.volume_slash),
      _AmbientSound('Forest', context.l10n.forest, Iconsax.tree),
      _AmbientSound('Rain', context.l10n.rain, Iconsax.cloud_drizzle),
      _AmbientSound('Waves', context.l10n.waves, Iconsax.status_up),
      _AmbientSound('Wind', context.l10n.wind, Iconsax.wind),
      _AmbientSound('Cafe', context.l10n.cafe, Iconsax.coffee),
      _AmbientSound('Library', context.l10n.library, Iconsax.book_1),
      _AmbientSound('Brown Noise', context.l10n.brownNoise, Iconsax.speaker),
    ];

    return Column(
      children: [
        Text(
          "AMBIENT SOUND",
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 60,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemCount: sounds.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final sound = sounds[index];
              final isSelected =
                  activeSound == sound.id ||
                  (activeSound == null && sound.id == 'None');
              return InkWell(
                onTap: () =>
                    ref.read(ambientSoundProvider.notifier).playSound(sound.id),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white
                        : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    sound.icon,
                    color: isSelected ? theme.primaryColor : Colors.white,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<bool> _showExitConfirmation(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Quitter le mode Focus?"),
            content: const Text(
              "Votre session est en cours.Voulez-vous vraiment l'interrompre?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("CONTINUER"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  "QUITTER",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }
}

class _AmbientSound {
  final String id;
  final String name;
  final IconData icon;
  _AmbientSound(this.id, this.name, this.icon);
}
