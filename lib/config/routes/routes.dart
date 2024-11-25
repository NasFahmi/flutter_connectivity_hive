import 'package:connectivity_hive_bloc/presentation/ui/not_found.dart';
import 'package:flutter/material.dart';

class Routes {
  static Route onRoute(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>?;
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (_) => const NotFound(),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const NotFound(),
        );
    }
  }
}
