import 'package:connectivity_hive_bloc/domain/model/post.dart';
import 'package:connectivity_hive_bloc/domain/provider/post/local/post_infinite_local_service.dart';
import 'package:connectivity_hive_bloc/domain/provider/post/local/post_infinite_provider.dart';
import 'package:connectivity_hive_bloc/domain/provider/post/local/post_local_provider.dart';
import 'package:connectivity_hive_bloc/domain/provider/post/local/post_local_service.dart';
import 'package:connectivity_hive_bloc/domain/provider/post/remote/post_remote_provider.dart';
import 'package:connectivity_hive_bloc/domain/services/api_client.dart';
import 'package:connectivity_hive_bloc/domain/services/internet_connection_services.dart';
import 'package:connectivity_hive_bloc/domain/services/token_service.dart';
import 'package:connectivity_hive_bloc/presentation/ui/features/home/bloc/post_bloc.dart';
import 'package:connectivity_hive_bloc/presentation/ui/features/home/repository/post_repository.dart';
import 'package:connectivity_hive_bloc/presentation/ui/features/infinite_scroll/repository/postInfiniteRepository.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

final di = GetIt.instance;
Future<void> init() async {
  /// Network services
  di.registerSingleton<Dio>(Dio());

  // token services
  di.registerSingleton(TokenService());

  /// internet connection services
  di.registerSingleton(InternetConnectionServices());

  /// Hive DataBase
  await Hive.initFlutter();

  // Daftarkan adapter hanya sekali
  Hive.registerAdapter(PostAdapter());

  di.registerSingleton(ApiClient(di<TokenService>()));
  // di.registerLazySingleton(() => TokenService());

  // post local service
  di.registerSingleton<PostLocalService>(PostLocalService());
  await di<PostLocalService>().initDataBase();

  di.registerSingleton<PostInfiniteLocalService>(PostInfiniteLocalService());
  await di<PostInfiniteLocalService>().initDataBase();

  // post local proivder
  di.registerSingleton(
      PostLocalProvider(postLocalService: di<PostLocalService>()));

  // post infinite Provider
  di.registerSingleton<PostInfiniteProvider>(PostInfiniteProvider(
      PostInfiniteLocalService: di<PostInfiniteLocalService>()));

  //post remote provider
  di.registerSingleton<PostRemoteProvider>(PostRemoteProvider());

  // post repository
  di.registerSingleton<PostRepository>(
      PostRepository(di<PostRemoteProvider>(), di<PostLocalProvider>()));

  //post infinite repository
  di.registerSingleton<PostInfiniteRepository>(
    PostInfiniteRepository(
      di<PostRemoteProvider>(),
      di<PostInfiniteProvider>(),
    ),
  );

  // post Bloc
  di.registerSingleton<PostBloc>(PostBloc(di<PostRepository>()));
}
