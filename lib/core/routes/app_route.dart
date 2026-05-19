import 'package:meducyte_app/export.dart';

typedef AppRouteBuilder = Widget Function(BuildContext, GoRouterState);

class AppRoute {
  final String path;
  final String? name;
  final AppRouteBuilder builder;
  final List<AppRoute> children;

  const AppRoute({
    required this.path,
    required this.builder,
    this.name,
    this.children = const [],
  });

  GoRoute toGoRoute() {
    return GoRoute(
      path: path,
      name: name,
      builder: (context, state) => builder(context, state),
      routes: children.map((c) => c.toGoRoute()).toList(),
    );
  }
}
