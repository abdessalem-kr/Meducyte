import 'package:meducyte_app/export.dart';

final accessGatingServiceProvider = Provider<AccessGatingService>((ref) {
  final user = ref.watch(authControllerProvider).value;
  return AccessGatingService(user);
});

class AccessGatingService {
  final User? _user;
  AccessGatingService(this._user);

  ///Whether the user has paid for ANY plan
  bool get hasActiveSubscription => _user?.isSubscriber ?? false;

  ///Checks if the user has access to a specific module or lesson
  bool canAccessModule(dynamic module) {
    //1.Allow access if the module is marked as free/sample(for preview)
    if (module is LearnModule && module.isFree) return true;
    if (module is LearnLesson && module.isFree) return true;
    if (module is Map &&
        (module['is_free'] == true || module['is_sample'] == true)) {
      return true;
    }

    //Hardcoded check for testing purposes(IDs starting with'sample_')
    final String? moduleId = _getModuleId(module);
    if (moduleId != null && moduleId.startsWith('sample_')) return true;

    if (_user == null) return false;

    //Must have a subscription to use non-free features
    if (!hasActiveSubscription) return false;

    //Basic plans don't get module access(lesson reading)
    if (!_user.hasModuleAccess) return false;

    //Residency students/Full access plans get everything
    if (_user.hasPremiumAccess) return true;

    //Direct check based on backend-provided metadata if available
    if (module is Map && module['can_access'] != null) {
      return module['can_access'] as bool;
    }

    //Fallback:Check academic year match for students
    final int? moduleYear = _getModuleYear(module);
    if (moduleYear != null) {
      return moduleYear == _user.year;
    }

    return false;
  }

  ///Checks if AI features can be used
  bool canUseAi() {
    return _user?.hasAiAccess ?? false;
  }

  ///Helper to extract year from various module representations
  int? _getModuleYear(dynamic module) {
    if (module is LearnModule) return module.year;
    if (module is Map) return module['year'] as int?;
    return null;
  }

  String? _getModuleId(dynamic module) {
    if (module is LearnModule) return module.id;
    if (module is LearnLesson) return module.id;
    if (module is Map) return module['id']?.toString();
    return null;
  }
}
