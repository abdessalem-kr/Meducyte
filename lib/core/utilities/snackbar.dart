import 'package:meducyte_app/export.dart';

class AppSnackBars {
  static void _show(
    BuildContext context,
    String message, {
    Color? background,
    IconData? icon,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: background ?? Colors.grey[800],
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: duration,
      ),
    );
  }

  // ✅ SUCCESS
  static void success(BuildContext context, String message) {
    _show(
      context,
      message,
      background: Colors.green.shade600,
      icon: Icons.check_circle_outline,
    );
  }

  // ⚠️ WARNING
  static void warning(BuildContext context, String message) {
    _show(
      context,
      message,
      background: Colors.orange.shade700,
      icon: Icons.warning_amber_rounded,
    );
  }

  // ❌ ERROR
  static void error(BuildContext context, dynamic error) {
    String message = 'An unexpected error occurred. Please try again.';

    if (error is DioException) {
      message = ApiException.fromDioError(error).message;
    } else if (error is ApiException) {
      message = error.message;
    } else if (error is Exception) {
      final errorText = error.toString();
      if (errorText.toLowerCase().contains('dio')) {
        message = 'A network error occurred. Please try again.';
      } else {
        message = errorText.replaceAll('Exception: ', '');
      }
    } else if (error is String) {
      final lowerError = error.toLowerCase();
      if (lowerError.contains('dioexception') ||
          lowerError.contains('dio error') ||
          lowerError.contains('dio_exception') ||
          (lowerError.contains('dio') &&
              (lowerError.contains('connection') ||
                  lowerError.contains('timeout') ||
                  lowerError.contains('status') ||
                  lowerError.contains('response')))) {
        if (lowerError.contains('connection') || lowerError.contains('timeout')) {
          message = 'No internet connection. Please check your network.';
        } else if (lowerError.contains('401') || lowerError.contains('unauthorized')) {
          message = 'Incorrect email or password.';
        } else if (lowerError.contains('500') || lowerError.contains('server')) {
          message = 'Server error. Please try again later.';
        } else {
          message = 'A network error occurred. Please try again.';
        }
      } else {
        message = error;
      }
    } else if (error != null) {
      message = error.toString();
    }

    _show(
      context,
      message,
      background: Colors.red.shade700,
      icon: Icons.error_outline,
    );
  }

  // ℹ️ INFO
  static void info(BuildContext context, String message) {
    _show(
      context,
      message,
      background: AppColors.primaryDark,
      icon: Icons.info_outline,
    );
  }
}
