import 'package:flutter/material.dart';
import 'package:meducyte_app/core/themes/app_colors.dart';

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

    if (error is Exception) {
      final errorText = error.toString().toLowerCase();
      if (errorText.contains('dio')) {
        if (errorText.contains('connection')) {
          message = 'No internet connection. Please check your network.';
        } else if (errorText.contains('401')) {
          message = 'Incorrect email or password.';
        } else if (errorText.contains('500')) {
          message = 'Server error. Please try again later.';
        }
      }
    } else if (error is String) {
      message = error;
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
