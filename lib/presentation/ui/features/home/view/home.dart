import 'dart:async';

import 'package:connectivity_hive_bloc/config/routes/route_name.dart';
import 'package:connectivity_hive_bloc/config/utils/dependenci_injector.dart';
import 'package:connectivity_hive_bloc/config/utils/logger.dart';
import 'package:connectivity_hive_bloc/domain/services/internet_connection_services.dart';
import 'package:connectivity_hive_bloc/presentation/ui/features/home/bloc/post_bloc.dart';
import 'package:connectivity_hive_bloc/presentation/ui/features/home/cubit/internet_connection_cubit.dart';
import 'package:connectivity_hive_bloc/presentation/ui/features/home/repository/post_repository.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_hive_bloc/domain/model/post.dart';

class HomeScope extends StatelessWidget {
  const HomeScope({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (context) =>
                PostBloc(di<PostRepository>())..add(FetchingAllPost())),
        BlocProvider(
            create: (context) => InternetConnectionCubit(
                di<InternetConnectionServices>(), Connectivity()))
      ],
      child: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late InternetConnectionCubit _internetConnectionCubit;
  @override
  initState() {
    super.initState();
    _internetConnectionCubit = context.read<InternetConnectionCubit>();
    _internetConnectionCubit.checkConnection();
    _internetConnectionCubit.trackConnectivityChange();
  }

// Be sure to cancel subscription after you are done
  @override
  dispose() {
    // subscription.cancel();
    _internetConnectionCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          BlocBuilder<InternetConnectionCubit, InternetConnectionState>(
            buildWhen: (previous, current) => previous != current,
            builder: (context, state) {
              logger.d('state internet $state');

              if (state is InternetStatusConnected) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Center(
                    child: Text('Connected'),
                  ),
                );
              } else if (state is InternetStatusDisconnected) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Center(
                    child: Text('Disconnected'),
                  ),
                );
              }
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Center(child: Text('Invalid')),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
        
              context.read<PostBloc>().add(FetchingAllPost());
            },
          ),
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, RouteName.infiniteScroll);
              },
              child: Text('Go To InfiniteScroll'),
            ),
            Expanded(
              child: BlocBuilder<PostBloc, PostState>(
                builder: (context, state) {
                  if (state is PostLoading) {
                    return Center(child: CircularProgressIndicator());
                  } else if (state is PostLoaded) {
                    return _buildPostList(state.posts);
                  } else if (state is PostError) {
              
                    return Center(child: Text('Sorry, Please Connect your device to the internet'));
                  } else {
                    return Center(child: Text('Something Went Wrong'));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostList(List<Post> posts) {
    // Assuming Post is a list of items, adjust accordingly based on your data structure
    return ListView.builder(
      itemCount: posts.length, // Update this to the actual number of posts
      itemBuilder: (context, index) {
        return ListTile(
          leading: CircleAvatar(
            child: Text('${index + 1}'),
          ),
          title: Text(
              posts[index].title), // Update this to the actual property of Post
          // Add more fields as necessary
        );
      },
    );
  }
}
