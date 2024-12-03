import 'package:connectivity_hive_bloc/config/utils/dependenci_injector.dart';
import 'package:connectivity_hive_bloc/config/utils/logger.dart';
import 'package:connectivity_hive_bloc/domain/services/internet_connection_services.dart';
import 'package:connectivity_hive_bloc/presentation/ui/features/home/cubit/internet_connection_cubit.dart';
import 'package:connectivity_hive_bloc/presentation/ui/features/infinite_scroll/bloc/post_infinite_bloc.dart';
import 'package:connectivity_hive_bloc/presentation/ui/features/infinite_scroll/repository/postInfiniteRepository.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InfiniteScrollScope extends StatelessWidget {
  const InfiniteScrollScope({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => InternetConnectionCubit(
            di<InternetConnectionServices>(),
            Connectivity(),
          ),
        ),
        BlocProvider(
          create: (context) =>
              PostInfiniteBloc(repository: di<PostInfiniteRepository>())..add(FetchPostsEvent()),
        )
      ],
      child: const InfiniteScroll(),
    );
  }
}

class InfiniteScroll extends StatefulWidget {
  const InfiniteScroll({super.key});

  @override
  State<InfiniteScroll> createState() => _InfiniteScrollState();
}

class _InfiniteScrollState extends State<InfiniteScroll> {
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
        title: const Text('Infinte Scroll'),
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
        ],
      ),
      body: SafeArea(
        child: PostInfiniteListView(),
      ),
    );
  }
}

class PostInfiniteListView extends StatefulWidget {
  const PostInfiniteListView({Key? key}) : super(key: key);

  @override
  _PostInfiniteListViewState createState() => _PostInfiniteListViewState();
}

class _PostInfiniteListViewState extends State<PostInfiniteListView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<PostInfiniteBloc>().add(FetchPostsEvent());
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<PostInfiniteBloc>().add(FetchPostsEvent());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostInfiniteBloc, PostInfiniteState>(
      builder: (context, state) {
        if (state is PostInfiniteInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is PostInfiniteError) {
          return Center(child: Text('Error: ${state.message}'));
        }

        if (state is PostInfiniteLoaded) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<PostInfiniteBloc>().add(RefreshPostsEvent());
            },
            child: ListView.builder(
              controller: _scrollController,
              itemCount: state.hasReachedMax
                  ? state.posts.length
                  : state.posts.length + 1,
              itemBuilder: (context, index) {
                if (index >= state.posts.length) {
                  return const Center(child: CircularProgressIndicator());
                }

                final post = state.posts[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text('${index + 1}'),
                  ),
                  title: Text(post.title),
                );
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
