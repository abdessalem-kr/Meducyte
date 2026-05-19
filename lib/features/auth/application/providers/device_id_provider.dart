import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

final deviceIdProvider = FutureProvider<String>((ref) async {
  final deviceInfoPlugin = DeviceInfoPlugin();

  try {
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfoPlugin.androidInfo;
      //Use the correct field name depending on device_info_plus version
      final id = androidInfo.id;
      return id;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfoPlugin.iosInfo;
      final id =
          iosInfo.identifierForVendor ??
          'ios_unknown_${DateTime.now().millisecondsSinceEpoch}';
      return id;
    } else {
      return 'unsupported_platform_${DateTime.now().millisecondsSinceEpoch}';
    }
  } catch (e) {
    return 'error_device_${DateTime.now().millisecondsSinceEpoch}';
  }
});
