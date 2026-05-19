import 'dart:math' as math;
import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/features/auth/presentation/widgets/password_strength_meter.dart';
import 'package:meducyte_app/features/auth/presentation/widgets/notion_avatar_renderer.dart';
import 'package:meducyte_app/core/constants/avatar_assets.dart';

class SignUpScreenMobile extends ConsumerStatefulWidget {
  const SignUpScreenMobile({super.key});

  @override
  ConsumerState<SignUpScreenMobile> createState() => _SignUpScreenMobileState();
}

class _SignUpScreenMobileState extends ConsumerState<SignUpScreenMobile> {
  final int totalSteps = 9;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _signUp() async {
    final notifier = ref.read(signUpProvider.notifier);
    final state = ref.read(signUpProvider);

    setState(() => _isLoading = true);

    // Validate all required fields first
    if (!notifier.isNextEnabled()) {
      setState(() => _isLoading = false);
      AppSnackBars.warning(
        context,
        'Please fill all required fields correctly.',
      );
      return;
    }

    // Build the data payload
    final data = {
      'name': notifier.nameController.text.trim(),
      'email': notifier.emailController.text.trim(),
      'password': notifier.passwordController.text.trim(),
      'password_confirmation': notifier.confirmPasswordController.text.trim(),
      'year': state.selectedYear ?? 0,
      'faculte': state.faculte ?? '',
      'next_exam_date': state.nextExamDate?.toIso8601String() ?? '',
      'enable_daily_challenge': state.enableDailyChallenge,
      'show_to_faculty': state.showToFaculty,
      'interests': state.interest,
      'learning_goal': state.learningGoal ?? '',
      'heard_from': state.heardFrom ?? '',
      'quiz_preference': state.quizPreference ?? '',
      'avatar_key': state.selectedAvatar,
      'study_time':
          '${state.studyTime.hour.toString().padLeft(2, '0')}:${state.studyTime.minute.toString().padLeft(2, '0')}',
      'study_duration': '${state.studyHours}h${state.studyMinutes}m',
    };

    // Only add mobile if not empty
    final mobile = notifier.mobileController.text.trim();
    if (mobile.isNotEmpty) {
      data['mobile'] = mobile;
    }

    // Debug: Print the data being sent
    // print('📤 Signup Request Data:');
    // print(data);

    try {
      await ref.read(authControllerProvider.notifier).signup(data);

      if (!mounted) return;

      AppSnackBars.success(
        context,
        'Registration successful! Please verify your email.',
      );

      context.go(
        AppRoutes.otpVerification,
        extra: {
          'email': notifier.emailController.text.trim(),
          'type': 'email_verification',
          'isFromSignup': true,
        },
      );
    } catch (e) {
      if (!mounted) return;
      // The logic for displaying errors is handled by the caller or specialized snackbars
      String message = e.toString();
      if (e is Exception) {
        message = e.toString().replaceFirst('Exception: ', '');
      }
      AppSnackBars.error(context, message);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(signUpProvider);
    final notifier = ref.read(signUpProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              _buildProgressBars(state),
              const SizedBox(height: 24),
              Expanded(
                child: PageView(
                  controller: notifier.pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildInterestPage(state, notifier),
                    _buildFacultePage(state, notifier),
                    _buildExamPage(state, notifier),
                    _buildDailyChallengePage(state, notifier),
                    _buildCommunityPage(state, notifier),
                    _buildQuizPreferencePage(state, notifier),
                    _buildStudyTimePage(state, notifier),
                    _buildHeardFromPage(state, notifier),
                    _buildCredentialsPage(state, notifier),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  if (state.currentStep > 0)
                    Expanded(
                      child: TextButton(
                        onPressed: notifier.previousStep,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(color: Colors.grey.shade400),
                          ),
                        ),
                        child: Text(
                          context.l10n.authBack,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  if (state.currentStep > 0) const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (!notifier.isNextEnabled()) {
                          AppSnackBars.warning(
                            context,
                            'Please fill all required fields correctly.',
                          );
                          return;
                        }
                        if (state.currentStep < totalSteps - 1) {
                          notifier.nextStep();
                        } else {
                          _isLoading ? null : _signUp();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        disabledBackgroundColor: Colors.grey.shade300,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeCap: StrokeCap.round,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              state.currentStep == totalSteps - 1
                                  ? context.l10n.authFinish
                                  : context.l10n.authContinue,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------- Progress Bar -------------------
  Widget _buildProgressBars(SignUpState state) {
    return Row(
      children: List.generate(totalSteps, (index) {
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            height: 8,
            decoration: BoxDecoration(
              color: state.currentStep >= index
                  ? AppColors.primary
                  : Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }),
    );
  }

  // ------------------- Pages -------------------

  Widget _buildInterestPage(SignUpState state, SignUpNotifier notifier) {
    final categories = {
      context.l10n.authMedicalSpec: [
        context.l10n.spec_cardiology,
        context.l10n.spec_neurology,
        context.l10n.spec_pulmonology,
        context.l10n.spec_hepatogastroenterologie,
        context.l10n.spec_nephrologie,
        context.l10n.spec_endocrinology,
        context.l10n.spec_hematologie,
        context.l10n.spec_rhumatologie,
        context.l10n.spec_infectiologie,
        context.l10n.spec_dermatologieetvenereologie,
        context.l10n.spec_psychiatrie,
      ],
      context.l10n.authSurgicalSpec: [
        context.l10n.spec_surgery,
        context.l10n.spec_orthopedics,
        context.l10n.spec_urology,
        context.l10n.spec_ophtalmologie,
        context.l10n.spec_orl,
        context.l10n.spec_gynecologieobstetrique,
        context.l10n.spec_anesthesiereanimation,
      ],
      context.l10n.authOtherDisciplines: [
        context.l10n.spec_pediatrie,
        context.l10n.spec_radiology,
        context.l10n.spec_pathology,
        context.l10n.spec_emergency,
        context.l10n.spec_general,
      ],
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              context.l10n.authInterests,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              context.l10n.authInterestsSub,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          const SizedBox(height: 32),
          ...categories.entries.map((category) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 12, top: 16),
                  child: Text(
                    category.key.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: category.value.map((opt) {
                    final isSelected = state.interest.contains(opt);
                    return InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => notifier.toggleInterest(opt),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withOpacity(0.05)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Text(
                          opt,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: isSelected
                                ? AppColors.primary
                                : Colors.black87,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStudyTimePage(SignUpState state, SignUpNotifier notifier) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            context.l10n.authStudySchedule,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.authStudyScheduleSub,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const SizedBox(height: 48),

          // Start Time Section
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Iconsax.calendar_tick,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      context.l10n.authDailyStartTime,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: state.studyTime,
                    );
                    if (picked != null) notifier.updateStudyTime(picked);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 32,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      state.studyTime.format(context),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Duration Section
          Text(
            context.l10n.authTargetDuration,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDurationCarousel(
                label: context.l10n.authHours,
                value: state.studyHours,
                max: 12,
                onChanged: notifier.updateStudyHours,
              ),
              const SizedBox(width: 24),
              _buildDurationCarousel(
                label: context.l10n.authMinutes,
                value: state.studyMinutes,
                step: 15,
                max: 45,
                onChanged: notifier.updateStudyMinutes,
              ),
            ],
          ),

          const SizedBox(height: 48),

          // Summary Card (Prescription Style)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(
                  Iconsax.info_circle,
                  color: Colors.white70,
                  size: 24,
                ),
                const SizedBox(height: 12),
                Text(
                  context.l10n.authDailyCommitment(
                    state.studyTime.format(context),
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  context.l10n.authStudyGoal(
                    state.studyHours,
                    state.studyMinutes,
                  ),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationCarousel({
    required String label,
    required int value,
    int step = 1,
    required int max,
    required Function(int) onChanged,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(16),
          ),
          height: 80,
          width: 80,
          child: ListWheelScrollView.useDelegate(
            itemExtent: 40,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: (index) => onChanged(index * step),
            childDelegate: ListWheelChildBuilderDelegate(
              builder: (context, index) {
                if (index < 0) return null;
                final displayValue = index * step;
                if (displayValue > max) return null;
                return Center(
                  child: Text(
                    "$displayValue",
                    style: TextStyle(
                      fontSize: displayValue == value ? 24 : 18,
                      fontWeight: displayValue == value
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: displayValue == value
                          ? AppColors.primary
                          : Colors.black54,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuizPreferencePage(SignUpState state, SignUpNotifier notifier) {
    final options = [
      context.l10n.authQuizDaily,
      context.l10n.authQuizWeekly,
      context.l10n.authQuizVideo,
      context.l10n.authQuizPdf,
    ];
    return _buildOptionPage(
      title: context.l10n.authQuizPreferenceTitle,
      image: 'assets/images/quiz.png',
      options: options,
      selectedOption: state.quizPreference,
      onSelect: notifier.updateQuizPreference,
    );
  }

  Widget _buildHeardFromPage(SignUpState state, SignUpNotifier notifier) {
    final options = [
      'Faculté / CHU',
      'Conférences Nationales',
      'Réseaux Sociaux (FB/IG)',
      'Ami / Collègue',
      'Publicité Meducyte',
      'Autre',
    ];
    return _buildOptionPage(
      title: context.l10n.authHowHeardTitle,
      subtitle: context.l10n.authHowHeardSub,
      image: 'assets/images/quiz.png',
      options: options,
      selectedOption: state.heardFrom,
      onSelect: notifier.updateHeardFrom,
    );
  }

  Widget _buildCredentialsPage(SignUpState state, SignUpNotifier notifier) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          // Avatar Maker Hero
          Center(
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () => _showAvatarMaker(state, notifier),
                  child: NotionAvatarRenderer(
                    avatarKey: state.selectedAvatar,
                    size: 100,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () => _showAvatarMaker(state, notifier),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: const Icon(
                        Iconsax.magicpen,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Créez votre identité Notion',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            context.l10n.authCreateAccount,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: notifier.nameController,
            decoration: InputDecoration(
              labelText: context.l10n.authFullName,
              prefixIcon: const Icon(Iconsax.user),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<int>(
            value: state.selectedYear,
            decoration: InputDecoration(
              labelText: context.l10n.authYear,
              prefixIcon: const Icon(Iconsax.teacher),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            items: List.generate(7, (index) {
              final year = index + 1;
              return DropdownMenuItem(
                value: year,
                child: Text('$year${year == 1 ? "er" : "ème"} Année'),
              );
            }),
            onChanged: (val) => notifier.updateSelectedYear(val),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: notifier.emailController,
            decoration: InputDecoration(
              labelText: context.l10n.authEmail,
              prefixIcon: const Icon(Iconsax.sms),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: notifier.mobileController,
            decoration: InputDecoration(
              labelText: context.l10n.authMobileOptional,
              prefixIcon: const Icon(Iconsax.call),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: notifier.passwordController,
            obscureText: state.obscurePassword,
            onChanged: (_) => notifier.updatePasswordError(
              notifier.validatePassword(notifier.passwordController.text),
            ),
            decoration: InputDecoration(
              labelText: context.l10n.authPasswordLabel,
              errorText: state.passwordError,
              prefixIcon: const Icon(Iconsax.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  state.obscurePassword ? Iconsax.eye_slash : Iconsax.eye,
                ),
                onPressed: notifier.toggleObscurePassword,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          PasswordStrengthMeter(
            hasMinLength: state.hasMinLength,
            hasUppercase: state.hasUppercase,
            hasNumber: state.hasNumber,
            hasSpecialChar: state.hasSpecialChar,
          ),
          const SizedBox(height: 8),
          const PasswordRequirementsWidget(),

          const SizedBox(height: 16),
          TextFormField(
            controller: notifier.confirmPasswordController,
            obscureText: state.obscureConfirm,
            onChanged: (_) {},
            decoration: InputDecoration(
              labelText: context.l10n.authConfirmPassword,
              errorText:
                  notifier.passwordController.text !=
                      notifier.confirmPasswordController.text
                  ? context.l10n.authPasswordsDoNotMatch
                  : null,
              prefixIcon: const Icon(Iconsax.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  state.obscureConfirm ? Iconsax.eye_slash : Iconsax.eye,
                ),
                onPressed: notifier.toggleObscureConfirm,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 16),
          Row(
            children: [
              Checkbox(
                value: state.acceptedTerms,
                onChanged: (val) => notifier.updateAcceptedTerms(val ?? false),
              ),
              Expanded(
                child: Wrap(
                  children: [
                    Text(context.l10n.authAcceptTerms),
                    GestureDetector(
                      onTap: () => context.push(AppRoutes.termsOfUse),
                      child: Text(
                        context.l10n.authTermsOfUse,
                        style: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    Text(context.l10n.authAnd),
                    GestureDetector(
                      onTap: () => context.push(AppRoutes.privacyPolicy),
                      child: Text(
                        context.l10n.authPrivacyPolicy,
                        style: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFacultePage(SignUpState state, SignUpNotifier notifier) {
    final options = [context.l10n.authFaculteConstantine];

    // Auto-select if it's the only option and not yet selected
    if (state.faculte == null && options.length == 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifier.updateFaculte(options.first);
      });
    }

    return _buildOptionPage(
      title: context.l10n.authFaculteTitle,
      subtitle: context.l10n.authFaculteSub,
      image: 'assets/images/quiz.png',
      options: options,
      selectedOption: state.faculte,
      onSelect: notifier.updateFaculte,
    );
  }

  Widget _buildExamPage(SignUpState state, SignUpNotifier notifier) {
    final now = DateTime.now();
    final daysRemaining = state.nextExamDate != null
        ? state.nextExamDate!.difference(now).inDays + 1
        : 0;

    return _buildActionPage(
      title: context.l10n.authExamDateTitle,
      subtitle: context.l10n.authExamDateSub,
      icon: Iconsax.timer_1,
      action: Column(
        children: [
          const SizedBox(height: 32),
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now().add(const Duration(days: 30)),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: AppColors.primary,
                        onPrimary: Colors.white,
                        onSurface: Colors.black,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) notifier.updateNextExamDate(picked);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.15),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.nextExamDate == null
                              ? 'Prêt à commencer ?'
                              : 'Objectif fixé !',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.nextExamDate == null
                              ? 'Sélectionnez votre prochain examen'
                              : 'Compte à rebours activé',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (state.nextExamDate != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              "J-$daysRemaining",
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                              ),
                            ),
                          )
                        else
                          Icon(
                            Iconsax.calendar_add,
                            color: AppColors.primary.withOpacity(0.3),
                            size: 32,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  _buildCountdownCircle(
                    daysRemaining,
                    state.nextExamDate != null,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "Ce compte à rebours sera épinglé sur votre tableau de bord 'Productive Bay'.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownCircle(int days, bool isSelected) {
    final color = isSelected ? AppColors.primary : Colors.grey.shade300;
    final displayDays = isSelected ? days : 0;
    final progress = isSelected ? (displayDays % 30) / 30 : 0.0;

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 100,
          height: 100,
          child: CircularProgressIndicator(
            value: isSelected ? math.max(0.05, progress) : 0,
            strokeWidth: 10,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            strokeCap: StrokeCap.round,
          ),
        ),
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.05),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isSelected ? days.toString() : '?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
              Text(
                "JOURS",
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                  color: color.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDailyChallengePage(SignUpState state, SignUpNotifier notifier) {
    return _buildActionPage(
      title: context.l10n.authDailyChallengeTitle,
      subtitle: context.l10n.authDailyChallengeSub,
      icon: Iconsax.status_up,
      action: _buildToggleItem(
        label: "Activer la notification quotidienne",
        value: state.enableDailyChallenge,
        onChanged: notifier.updateEnableDailyChallenge,
      ),
    );
  }

  Widget _buildCommunityPage(SignUpState state, SignUpNotifier notifier) {
    return _buildActionPage(
      title: context.l10n.authCommunityTitle,
      subtitle: context.l10n.authCommunitySub,
      icon: Iconsax.user_tag,
      action: _buildToggleItem(
        label: "Me rendre visible aux autres étudiants",
        value: state.showToFaculty,
        onChanged: notifier.updateShowToFaculty,
      ),
    );
  }

  Widget _buildActionPage({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget action,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 48, color: AppColors.primary),
          ),
          const SizedBox(height: 32),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const Spacer(),
          action,
          const Spacer(flex: 2),
        ],
      ),
    );
  }

  Widget _buildToggleItem({
    required String label,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildOptionPage({
    required String title,
    String? subtitle,
    required String image,
    required List<String> options,
    required String? selectedOption,
    required Function(String) onSelect,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Hero(tag: image, child: Image.asset(image, height: 120)),
          const SizedBox(height: 32),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            ),
          ],
          const SizedBox(height: 32),
          Column(
            children: options.map((opt) {
              final selected = selectedOption == opt;
              return GestureDetector(
                onTap: () => onSelect(opt),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary.withOpacity(0.05)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected
                          ? AppColors.primary
                          : Colors.grey.shade200,
                      width: selected ? 2 : 1.5,
                    ),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          opt,
                          style: TextStyle(
                            fontSize: 15,
                            color: selected
                                ? AppColors.primary
                                : Colors.black87,
                            fontWeight: selected
                                ? FontWeight.bold
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selected
                                ? AppColors.primary
                                : Colors.grey.shade300,
                            width: 2,
                          ),
                        ),
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: selected
                                ? AppColors.primary
                                : Colors.transparent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _showAvatarMaker(SignUpState state, SignUpNotifier notifier) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final currentState = ref.watch(signUpProvider);

            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
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
                  const SizedBox(height: 20),
                  Text(
                    'The Meducyte Identity',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                      color: Colors.black.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Live Preview
                  NotionAvatarRenderer(
                    avatarKey: currentState.selectedAvatar,
                    size: 140,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Choisissez votre avatar prêt à l\'emploi',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(child: _buildPremadeAvatars(notifier)),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Confirmer',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPremadeAvatars(SignUpNotifier notifier) {
    // Each premade just varies the skin tone
    final premades = AvatarAssets.readyAvatars.keys.toList();

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: premades.length,
      itemBuilder: (context, index) {
        final key = premades[index];
        final state = ref.watch(signUpProvider);
        final isSelected = state.selectedAvatar == key;

        return GestureDetector(
          onTap: () => notifier.updateSelectedAvatar(key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : Colors.black.withOpacity(0.05),
                width: 2,
              ),
            ),
            child: NotionAvatarRenderer(avatarKey: key, size: 60),
          ),
        );
      },
    );
  }
}
