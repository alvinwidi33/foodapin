import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodapin/features/user/home/bloc/home_bloc.dart';
import 'package:foodapin/features/user/home/bloc/home_event.dart';
import 'package:foodapin/features/user/home/bloc/home_state.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  final SearchController _searchController = SearchController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<HomeBloc>().add(const FetchFoods());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

    void _onScroll() {
    if (!_scrollController.hasClients) return;

    final state = context.read<HomeBloc>().state;

    if (_isBottom && state is HomeLoaded && !state.isLoadingMore) {
      context.read<HomeBloc>().add(const LoadMoreFoods());
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
    final screenWidth = MediaQuery.of(context).size.width * 0.92;
    return Scaffold(
      body: SafeArea(
        child: SizedBox()
        
      )
    );
  }
}