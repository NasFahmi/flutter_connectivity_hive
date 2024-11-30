import 'package:connectivity_hive_bloc/config/routes/route_name.dart';
import 'package:connectivity_hive_bloc/config/routes/routes.dart';
import 'package:connectivity_hive_bloc/config/utils/dependenci_injector.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main()async {
  WidgetsFlutterBinding.ensureInitialized();

  await init();
  runApp(const AppScope());
}
class AppScope extends StatelessWidget {
  const AppScope({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return App();
  }
}

class App extends StatelessWidget {
  const App({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: RouteName.routeInital,
      onGenerateRoute: Routes.onRoute,
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
    );
  }
}
