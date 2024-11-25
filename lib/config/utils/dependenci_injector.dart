import 'package:connectivity_hive_bloc/domain/services/api_client.dart';
import 'package:connectivity_hive_bloc/domain/services/internet_connection_services.dart';
import 'package:connectivity_hive_bloc/domain/services/token_service.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';

final di = GetIt.instance;
Future<void> init() async {
  /// Network services
  di.registerSingleton<Dio>(Dio());

  // token services
  di.registerSingleton(TokenService());

  /// internet connection services
  di.registerSingleton(InternetConnectionServices());

  /// Hive DataBase
  // await Hive.init();

  
  di.registerSingleton(ApiClient(di<TokenService>()));
  // di.registerLazySingleton(() => TokenService());
}
