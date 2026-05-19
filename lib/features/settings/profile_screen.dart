import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/features/auth/presentation/widgets/notion_avatar_renderer.dart';
import 'package:meducyte_app/core/constants/avatar_assets.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isSaving = false;

  Future<void> _updateField(String key, dynamic value) async {
    setState(() => _isSaving = true);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    try {
      final user = ref.read(authControllerProvider).value;
      if (user == null) return;

      final Map<String, dynamic> data = user.toJson();
      data[key] = value;

      await ref.read(authControllerProvider.notifier).updateUser(data);

      if (key == 'next_exam_date') {
        ref.read(examEventsProvider.notifier).refresh();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.profileUpdatedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.profileUpdateFailed),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showAvatarSelection(String currentKey) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Choisissez votre identité",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              "Sélectionnez l'avatar qui vous ressemble",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemCount: AvatarAssets.readyAvatars.length,
                itemBuilder: (context, index) {
                  final key = AvatarAssets.readyAvatars.keys.elementAt(index);
                  final isSelected = key == currentKey;
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _updateField('avatar_key', key);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withOpacity(0.05)
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.grey.shade200,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Center(
                        child: NotionAvatarRenderer(avatarKey: key, size: 80),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showSelectionSheet({
    required String title,
    required String key,
    required List<String> options,
    required String? currentValue,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 24),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.only(left: 24, right: 24, bottom: 32),
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final opt = options[index];
                  final isSelected = opt == currentValue;
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _updateField(key, opt);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withOpacity(0.05)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.grey.shade200,
                          width: isSelected ? 2 : 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              opt,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.black87,
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Iconsax.tick_circle,
                              color: AppColors.primary,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInterestsSelection(List<String> currentInterests) {
    //Placeholder list of common medical interests if not found elsewhere
    final allInterests = [
      "Cardiology",
      "Neurology",
      "Pediatrics",
      "Surgery",
      "Emergency",
      "Internal Medicine",
      "Gynecology",
      "Radiology",
      "Dermatology",
      "Psychiatry",
    ];

    List<String> tempInterests = List.from(currentInterests);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Vos Intérêts Médicaux",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: allInterests.map((interest) {
                      final isSelected = tempInterests.contains(interest);
                      return FilterChip(
                        label: Text(interest),
                        selected: isSelected,
                        onSelected: (selected) {
                          setSheetState(() {
                            if (selected) {
                              tempInterests.add(interest);
                            } else {
                              tempInterests.remove(interest);
                            }
                          });
                        },
                        selectedColor: AppColors.primary.withOpacity(0.2),
                        checkmarkColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.black87,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _updateField('interests', tempInterests);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      "Enregistrer les intérêts",
                      style: TextStyle(fontWeight: FontWeight.bold),
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

  void _showEditDialog(
    String title,
    String key,
    String initialValue, {
    bool isNumber = false,
  }) {
    final controller = TextEditingController(text: initialValue);
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${l10n.editProfile}: $title'),
        content: TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          maxLines: isNumber ? 1 : null,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Enter$title',
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = isNumber
                  ? (int.tryParse(controller.text) ?? 1)
                  : controller.text;
              Navigator.pop(context);
              _updateField(key, value);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final userAsync = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.profile),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: theme.textTheme.titleLarge?.color,
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) return Center(child: Text(l10n.notLoggedIn));

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          NotionAvatarRenderer(
                            avatarKey: user.avatarKey ?? 'avatar_1',
                            size: 130,
                          ),
                          Positioned(
                            bottom: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => _showAvatarSelection(
                                user.avatarKey ?? 'avatar_1',
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: theme.scaffoldBackgroundColor,
                                    width: 3,
                                  ),
                                ),
                                child: const Icon(
                                  Iconsax.magicpen,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    _buildSectionHeader(l10n.name),
                    _buildInfoTile(
                      l10n.name,
                      user.name,
                      Iconsax.user,
                      onEdit: () =>
                          _showEditDialog(l10n.name, 'name', user.name),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoTile(
                      l10n.email,
                      user.email,
                      Iconsax.sms,
                      isEditable: false,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoTile(
                      l10n.year,
                      'Année${user.year}',
                      Iconsax.calendar,
                      onEdit: () => _showSelectionSheet(
                        title: l10n.year,
                        key: 'year',
                        options: ["1", "2", "3", "4", "5", "6", "7"],
                        currentValue: user.year.toString(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoTile(
                      l10n.specialty,
                      user.specialty.isEmpty ? 'Non spécifié' : user.specialty,
                      Iconsax.teacher,
                      onEdit: () => _showSelectionSheet(
                        title: l10n.specialty,
                        key: 'specialty',
                        options: [l10n.authFaculteConstantine],
                        currentValue: user.specialty,
                      ),
                    ),

                    const SizedBox(height: 32),
                    _buildSectionHeader(l10n.authCurrentFocusTitle),
                    _buildInfoTile(
                      l10n.profileLearningGoal,
                      user.learningGoal ?? 'Non défini',
                      Iconsax.status_up,
                      onEdit: () => _showSelectionSheet(
                        title: l10n.profileLearningGoal,
                        key: 'learning_goal',
                        options: [
                          "Préparation EMD",
                          "Examen National",
                          "Révision Clinique",
                          "Culture Médicale",
                        ],
                        currentValue: user.learningGoal,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoTile(
                      l10n.profileInterests,
                      user.interests.isEmpty
                          ? 'Aucun intérêt choisi'
                          : user.interests.join(", "),
                      Iconsax.heart,
                      onEdit: () => _showInterestsSelection(user.interests),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoTile(
                      l10n.profileNextExam,
                      user.nextExamDate != null
                          ? user.nextExamDate!.toIso8601String().split('T')[0]
                          : 'Non défini',
                      Iconsax.timer_1,
                      onEdit: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate:
                              user.nextExamDate ??
                              DateTime.now().add(const Duration(days: 30)),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365 * 2),
                          ),
                        );
                        if (date != null) {
                          _updateField(
                            'next_exam_date',
                            date.toUtc().toIso8601String(),
                          );
                        }
                      },
                    ),

                    const SizedBox(height: 32),
                    _buildSectionHeader('Habitudes d\'Étude'),
                    _buildInfoTile(
                      l10n.profileStudyTime,
                      user.studyTime ?? 'Non défini',
                      Iconsax.clock,
                      onEdit: () async {
                        final now = TimeOfDay.now();
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: now,
                        );
                        if (picked != null) {
                          _updateField(
                            'study_time',
                            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}',
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildInfoTile(
                      l10n.profileQuizPreference,
                      user.quizPreference ?? 'Non défini',
                      Iconsax.note_2,
                      onEdit: () => _showSelectionSheet(
                        title: l10n.profileQuizPreference,
                        key: 'quiz_preference',
                        options: [
                          l10n.authQuizDaily,
                          l10n.authQuizWeekly,
                          l10n.authQuizVideo,
                          l10n.authQuizPdf,
                        ],
                        currentValue: user.quizPreference,
                      ),
                    ),

                    const SizedBox(height: 32),
                    _buildSectionHeader(l10n.userPreferences),
                    SwitchListTile(
                      title: Text(
                        l10n.profileDailyChallenge,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      activeColor: AppColors.primary,
                      value: user.enableDailyChallenge,
                      onChanged: (val) =>
                          _updateField('enable_daily_challenge', val),
                    ),
                    SwitchListTile(
                      title: Text(
                        l10n.profileShowToFaculty,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      activeColor: AppColors.primary,
                      value: user.showToFaculty,
                      onChanged: (val) => _updateField('show_to_faculty', val),
                    ),

                    const SizedBox(height: 64),
                  ],
                ),
              ),
              if (_isSaving)
                Container(
                  color: Colors.black26,
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Colors.grey.shade500,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildInfoTile(
    String label,
    String value,
    IconData icon, {
    bool isEditable = true,
    VoidCallback? onEdit,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor.withOpacity(isEditable ? 1.0 : 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
      ),
      child: InkWell(
        onTap: isEditable ? onEdit : null,
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 20,
                color: AppColors.primary.withOpacity(isEditable ? 1.0 : 0.5),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.textTheme.bodySmall?.color?.withOpacity(
                        isEditable ? 0.6 : 0.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(
                        isEditable ? 1.0 : 0.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isEditable)
              Icon(
                Iconsax.arrow_right_3,
                size: 16,
                color: Colors.grey.shade300,
              ),
          ],
        ),
      ),
    );
  }
}
