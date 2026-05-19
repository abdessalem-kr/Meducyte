//sign_up_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

class SignUpState {
  final List<String> interest;
  final int currentStep;
  final TimeOfDay studyTime;
  final int studyHours;
  final int studyMinutes;
  final String? learningGoal;
  final String? heardFrom;
  final String? quizPreference;
  final int? selectedYear;
  final String? faculte;
  final DateTime? nextExamDate;
  final bool enableDailyChallenge;
  final bool showToFaculty;
  final bool obscurePassword;
  final bool obscureConfirm;
  final bool acceptedTerms;
  final String? passwordError;
  final bool hasMinLength;
  final bool hasUppercase;
  final bool hasNumber;
  final bool hasSpecialChar;

  //Avatar State
  final String selectedAvatar;

  const SignUpState({
    this.interest = const [],
    this.currentStep = 0,
    this.studyTime = const TimeOfDay(hour: 8, minute: 0),
    this.studyHours = 1,
    this.studyMinutes = 0,
    this.learningGoal,
    this.heardFrom,
    this.quizPreference,
    this.selectedYear,
    this.faculte,
    this.nextExamDate,
    this.enableDailyChallenge = true,
    this.showToFaculty = true,
    this.obscurePassword = true,
    this.obscureConfirm = true,
    this.acceptedTerms = false,
    this.passwordError,
    this.hasMinLength = false,
    this.hasUppercase = false,
    this.hasNumber = false,
    this.hasSpecialChar = false,
    this.selectedAvatar = 'avatar_1',
  });

  SignUpState copyWith({
    List<String>? interest,
    int? currentStep,
    TimeOfDay? studyTime,
    int? studyHours,
    int? studyMinutes,
    String? learningGoal,
    String? heardFrom,
    String? quizPreference,
    int? selectedYear,
    String? faculte,
    DateTime? nextExamDate,
    bool? enableDailyChallenge,
    bool? showToFaculty,
    bool? obscurePassword,
    bool? obscureConfirm,
    bool? acceptedTerms,
    String? passwordError,
    bool? hasMinLength,
    bool? hasUppercase,
    bool? hasNumber,
    bool? hasSpecialChar,
    String? selectedAvatar,
  }) {
    return SignUpState(
      interest: interest ?? this.interest,
      currentStep: currentStep ?? this.currentStep,
      studyTime: studyTime ?? this.studyTime,
      studyHours: studyHours ?? this.studyHours,
      studyMinutes: studyMinutes ?? this.studyMinutes,
      learningGoal: learningGoal ?? this.learningGoal,
      heardFrom: heardFrom ?? this.heardFrom,
      quizPreference: quizPreference ?? this.quizPreference,
      selectedYear: selectedYear ?? this.selectedYear,
      faculte: faculte ?? this.faculte,
      nextExamDate: nextExamDate ?? this.nextExamDate,
      enableDailyChallenge: enableDailyChallenge ?? this.enableDailyChallenge,
      showToFaculty: showToFaculty ?? this.showToFaculty,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      obscureConfirm: obscureConfirm ?? this.obscureConfirm,
      acceptedTerms: acceptedTerms ?? this.acceptedTerms,
      passwordError: passwordError ?? this.passwordError,
      hasMinLength: hasMinLength ?? this.hasMinLength,
      hasUppercase: hasUppercase ?? this.hasUppercase,
      hasNumber: hasNumber ?? this.hasNumber,
      hasSpecialChar: hasSpecialChar ?? this.hasSpecialChar,
      selectedAvatar: selectedAvatar ?? this.selectedAvatar,
    );
  }

  bool get isPasswordValid =>
      hasMinLength && hasUppercase && hasNumber && hasSpecialChar;
}

class SignUpNotifier extends StateNotifier<SignUpState> {
  SignUpNotifier() : super(const SignUpState()) {
    passwordController.addListener(_onPasswordChanged);
    confirmPasswordController.addListener(_onConfirmPasswordChanged);
  }

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final PageController pageController = PageController();

  void _onPasswordChanged() {
    final password = passwordController.text;

    if (password.isEmpty) {
      state = state.copyWith(
        passwordError: null,
        hasMinLength: false,
        hasUppercase: false,
        hasNumber: false,
        hasSpecialChar: false,
      );
    } else {
      final hasMin = password.length >= 8;
      final hasUpper = RegExp(r'[A-Z]').hasMatch(password);
      final hasNum = RegExp(r'[0-9]').hasMatch(password);
      final hasSpecial = RegExp(r'[!@#\$&*~]').hasMatch(password);

      state = state.copyWith(
        hasMinLength: hasMin,
        hasUppercase: hasUpper,
        hasNumber: hasNum,
        hasSpecialChar: hasSpecial,
        passwordError: (hasMin && hasUpper && hasNum && hasSpecial)
            ? null
            : validatePassword(password),
      );
    }
  }

  void _onConfirmPasswordChanged() {
    //Trigger rebuild to check password match
    state = state.copyWith();
  }

  void nextStep() {
    if (state.currentStep < 9) {
      state = state.copyWith(currentStep: state.currentStep + 1);
      pageController.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
      pageController.previousPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    }
  }

  void toggleInterest(String interest) {
    final List<String> updatedInterest = List.from(state.interest);
    if (updatedInterest.contains(interest)) {
      updatedInterest.remove(interest);
    } else {
      updatedInterest.add(interest);
    }
    state = state.copyWith(interest: updatedInterest);
  }

  void updateStudyTime(TimeOfDay newTime) {
    state = state.copyWith(studyTime: newTime);
  }

  void updateStudyHours(int hours) {
    state = state.copyWith(studyHours: hours);
  }

  void updateStudyMinutes(int minutes) {
    state = state.copyWith(studyMinutes: minutes);
  }

  void updateLearningGoal(String? goal) {
    state = state.copyWith(learningGoal: goal);
  }

  void updateHeardFrom(String? source) {
    state = state.copyWith(heardFrom: source);
  }

  void updateSelectedAvatar(String val) {
    state = state.copyWith(selectedAvatar: val);
  }

  void updateQuizPreference(String? preference) {
    state = state.copyWith(quizPreference: preference);
  }

  void updateSelectedYear(int? year) {
    state = state.copyWith(selectedYear: year);
  }

  void updateFaculte(String? val) {
    state = state.copyWith(faculte: val);
  }

  void updateNextExamDate(DateTime? val) {
    state = state.copyWith(nextExamDate: val);
  }

  void updateEnableDailyChallenge(bool val) {
    state = state.copyWith(enableDailyChallenge: val);
  }

  void updateShowToFaculty(bool val) {
    state = state.copyWith(showToFaculty: val);
  }

  void toggleObscurePassword() {
    state = state.copyWith(obscurePassword: !state.obscurePassword);
  }

  void toggleObscureConfirm() {
    state = state.copyWith(obscureConfirm: !state.obscureConfirm);
  }

  void updateAcceptedTerms(bool accepted) {
    state = state.copyWith(acceptedTerms: accepted);
  }

  void updatePasswordError(String? error) {
    state = state.copyWith(passwordError: error);
  }

  String? validatePassword(String value) {
    if (value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'At least 8 characters';
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Include at least one uppercase';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) return 'Include at least one number';
    if (!RegExp(r'[!@#\$&*~]').hasMatch(value)) {
      return 'Include at least one special character';
    }
    return null;
  }

  bool isNextEnabled() {
    switch (state.currentStep) {
      case 0: //Interests
        return state.interest.isNotEmpty;
      case 1: //Identity(Faculté)
        return state.faculte != null;
      case 2: //Milestone(Next Exam Date)
        return state.nextExamDate != null;
      case 3: //Engagement(Daily Challenge)
        return true; //Always enabled(toggle)
      case 4: //Community(Faculty Visibility)
        return true; //Always enabled(toggle)
      case 5: //Quiz Preference
        return state.quizPreference != null;
      case 6: //Schedule(Study Time)
        return state.studyHours > 0 || state.studyMinutes > 0;
      case 7: //Discovery(Heard From)
        return state.heardFrom != null;
      case 8: //Credentials
        return nameController.text.trim().isNotEmpty &&
            emailController.text.trim().isNotEmpty &&
            passwordController.text.isNotEmpty &&
            confirmPasswordController.text.isNotEmpty &&
            passwordController.text == confirmPasswordController.text &&
            state.isPasswordValid &&
            state.acceptedTerms &&
            state.selectedYear != null;
      default:
        return false;
    }
  }

  void reset() {
    passwordController.removeListener(_onPasswordChanged);
    confirmPasswordController.removeListener(_onConfirmPasswordChanged);

    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    nameController.clear();
    mobileController.clear();

    if (pageController.hasClients) {
      pageController.jumpToPage(0);
    }

    state = const SignUpState();

    passwordController.addListener(_onPasswordChanged);
    confirmPasswordController.addListener(_onConfirmPasswordChanged);
  }

  @override
  void dispose() {
    passwordController.removeListener(_onPasswordChanged);
    confirmPasswordController.removeListener(_onConfirmPasswordChanged);

    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameController.dispose();
    mobileController.dispose();
    pageController.dispose();
    super.dispose();
  }
}

final signUpProvider =
    StateNotifierProvider.autoDispose<SignUpNotifier, SignUpState>((ref) {
      return SignUpNotifier();
    });
