import 'package:connectivity_hive_bloc/config/routes/route_name.dart';
import 'package:connectivity_hive_bloc/main.dart';
import 'package:connectivity_hive_bloc/presentation/ui/features/auth/view/login_page.dart';
import 'package:connectivity_hive_bloc/presentation/ui/features/auth/view/register_page.dart';
import 'package:connectivity_hive_bloc/presentation/ui/features/home/view/home.dart';
import 'package:connectivity_hive_bloc/presentation/ui/not_found.dart';
import 'package:flutter/material.dart';

class Routes {
  static Route onRoute(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>?;
    switch (settings.name) {
      case RouteName.routeInital:
        return MaterialPageRoute(
          builder: (_) => const HomeScope(),
        );
      case RouteName.login:
        return MaterialPageRoute(
          builder: (_) => const LoginPageScope(),
        );
        case RouteName.register:
        return MaterialPageRoute(
          builder: (_) => const RegisterPageScope(),
        );
        case RouteName.home:
        return MaterialPageRoute(
          builder: (_) => const HomeScope(),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const NotFound(),
        );
    }
  }
}
