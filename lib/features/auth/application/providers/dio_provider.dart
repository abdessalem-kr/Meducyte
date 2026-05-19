import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/shared/providers/network_provider.dart';

final dioProvider = Provider<Dio>((ref) {
  return ref.watch(dioClientProvider).dio;
});
