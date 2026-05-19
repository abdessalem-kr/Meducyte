import 'dart:async';
import 'package:flutter/material.dart';

class LoginThrottler {
  static Timer? _timer;

  static void handleThrottle(BuildContext context, String message) {
    //Extract the number of seconds
    final regex = RegExp(r'(\d+)\s*seconds');
    final match = regex.firstMatch(message);
    if (match == null) return;

    final totalSeconds = int.parse(match.group(1)!);
    _startCountdown(context, totalSeconds);
  }

  static void _startCountdown(BuildContext context, int seconds) {
    int remaining = seconds;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    //Create a persistent snackbar with live countdown
    final controller = StreamController<int>();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remaining <= 0) {
        timer.cancel();
        controller.add(0);
        controller.close();
      } else {
        controller.add(remaining);
        remaining--;
      }
    });

    //Show the snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(seconds: seconds),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.redAccent.shade100,
        content: StreamBuilder<int>(
          stream: controller.stream,
          builder: (context, snapshot) {
            final remain = snapshot.data ?? seconds;
            final mins = (remain ~/ 60).toString().padLeft(2, '0');
            final secs = (remain % 60).toString().padLeft(2, '0');
            return Text(
              remain > 0
                  ? "Too many attempts.Try again in$mins:$secs"
                  : "You can try again now!",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
      ),
    );
  }

  static void cancel() {
    _timer?.cancel();
    _timer = null;
  }
}
