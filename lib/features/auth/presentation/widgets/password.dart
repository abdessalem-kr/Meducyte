import 'package:meducyte_app/export.dart';

class PasswordRequirementsWidget extends ConsumerWidget {
  const PasswordRequirementsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signUpState = ref.watch(signUpProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        _RequirementItem(
          text: context.l10n.authPassAtLeast8,
          isMet: signUpState.hasMinLength,
        ),
        _RequirementItem(
          text: context.l10n.authPassUppercase,
          isMet: signUpState.hasUppercase,
        ),
        _RequirementItem(
          text: context.l10n.authPassNumber,
          isMet: signUpState.hasNumber,
        ),
        _RequirementItem(
          text: context.l10n.authPassSpecial,
          isMet: signUpState.hasSpecialChar,
        ),
      ],
    );
  }
}

class _RequirementItem extends StatelessWidget {
  final String text;
  final bool isMet;

  const _RequirementItem({required this.text, required this.isMet});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.circle_outlined,
            size: 18,
            color: isMet ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: isMet ? Colors.green : Colors.grey[600],
                fontWeight: isMet ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
