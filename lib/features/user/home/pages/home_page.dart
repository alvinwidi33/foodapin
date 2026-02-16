import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodapin/components/app_theme.dart';
import 'package:foodapin/components/navbar.dart';
import 'package:foodapin/features/user/home/bloc/home_bloc.dart';
import 'package:foodapin/features/user/home/bloc/home_event.dart';
import 'package:foodapin/features/user/home/bloc/home_state.dart';
import 'package:lottie/lottie.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
   final int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<HomeBloc>().add(const FetchFoods());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
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

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FilterBottomSheet(
        onApplyFilter: (sortKey) {
          if (sortKey != null) {
            context.read<HomeBloc>().add(SortFoods(sortKey: sortKey));
          }
          Navigator.pop(context);
        },
        onClearFilter: () {
          context.read<HomeBloc>().add(const ClearSearchAndSort());
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width * 0.92;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: screenWidth,
            child: Column(
              children: [
                const SizedBox(height: 16),
                Text("Home", style: AppTheme.headingStyle),
                const SizedBox(height: 24),
                Row(
                  children: [
                    InkWell(
                      onTap: _showFilterBottomSheet,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.black.withValues(alpha: 0.1),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: const Icon(
                          Icons.filter_alt_sharp,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        decoration: AppTheme.inputContainerDecoration,
                        child: TextField(
                          controller: _searchController,
                          onChanged: (query) {
                            context.read<HomeBloc>().add(SearchFoods(query));
                          },
                          decoration: AppTheme.inputDecoration("Search for food").copyWith(
                            prefixIcon: const Icon(
                              Icons.search,
                              color: AppTheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                Expanded(
                  child: BlocBuilder<HomeBloc, HomeState>(
                    builder: (context, state) {
                      if (state is HomeLoading) {
                        return Center(
                          child: Lottie.asset('assets/loading.json',
                          width: 200,
                          height: 200,
                          repeat: true,
                          ), 
                        );
                      }
                      if (state is HomeLoaded) {
                        if (state.visibleFoods.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No food found',
                                  style: AppTheme.bodyStyle.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return RefreshIndicator(
                          color: AppTheme.primary,
                          onRefresh: () async {
                            context.read<HomeBloc>().add(const FetchFoods(isRefresh: true));
                          },
                          child: GridView.builder(
                            controller: _scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.only(bottom: 16),
                            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 220, 
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              mainAxisExtent: 232
                            ),
                            itemCount: state.visibleFoods.length + (state.isLoadingMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index >= state.visibleFoods.length) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: CircularProgressIndicator(
                                      color: AppTheme.primary,
                                    ),
                                  ),
                                );
                              }
                              
                              final food = state.visibleFoods[index];
                              
                              return Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/detail-food', 
                                        arguments: food.id,
                                      );
                                    },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppTheme.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha:0.08),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Stack(
                                          children: [
                                            Container(
                                              height: 120,
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                color: AppTheme.tertiary,
                                                borderRadius: const BorderRadius.only(
                                                  topLeft: Radius.circular(16),
                                                  topRight: Radius.circular(16),
                                                ),
                                              ),
                                              child: ClipRRect(
                                                borderRadius: const BorderRadius.only(
                                                  topLeft: Radius.circular(16),
                                                  topRight: Radius.circular(16),
                                                ),
                                                child: food.imageUrl.isNotEmpty
                                                    ? Image.network(
                                                        food.imageUrl,
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (context, error, stackTrace) {
                                                          return const Center(
                                                            child: Icon(
                                                              Icons.fastfood,
                                                              color: AppTheme.primary,
                                                              size: 40,
                                                            ),
                                                          );
                                                        },
                                                      )
                                                    : const Center(
                                                        child: Icon(
                                                          Icons.fastfood,
                                                          color: AppTheme.primary,
                                                          size: 40,
                                                        ),
                                                      ),
                                              ),
                                            ),
                                            // Love button
                                            Positioned(
                                              top: 8,
                                              right: 8,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: AppTheme.white,
                                                  shape: BoxShape.circle,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black.withValues(alpha:0.15),
                                                      blurRadius: 4,
                                                      offset: const Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                child: IconButton(
                                                  padding: EdgeInsets.zero,
                                                  constraints: const BoxConstraints(
                                                    minWidth: 32,
                                                    minHeight: 32,
                                                  ),
                                                  icon: Icon(
                                                    food.isLike ?? false
                                                        ? Icons.favorite
                                                        : Icons.favorite_border,
                                                    color: food.isLike ?? false
                                                        ? AppTheme.primary
                                                        : Colors.grey.shade400,
                                                    size: 18,
                                                  ),
                                                  onPressed: () {
                                                    context.read<HomeBloc>().add(
                                                      ToggleLikeFood(
                                                        foodId: food.id.toString(),
                                                        isCurrentlyLiked: food.isLike ?? false,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        // Content
                                        Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                food.name.isNotEmpty
                                                    ? food.name[0].toUpperCase() + food.name.substring(1)
                                                    : '',
                                                style: AppTheme.cardTitle,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            const SizedBox(height: 6),
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.star,
                                                    color: Colors.amber,
                                                    size: 14,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    food.rating?.toStringAsFixed(1) ?? '0.0',
                                                    style: AppTheme.cardBody.copyWith(
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 11,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 6),
                                              // Price
                                              Text(
                                                food.price == null 
                                                    ? 'Free'
                                                    : 'Rp ${food.price?.toString() ?? '0'}',
                                                style: AppTheme.cardBody.copyWith(
                                                  color: AppTheme.primary,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }
                      
                      if (state is HomeError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                state.message,
                                style: AppTheme.bodyStyle.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  context.read<HomeBloc>().add(const FetchFoods());
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primary,
                                  foregroundColor: AppTheme.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                ),
                                child: Text(
                                  'Retry',
                                  style: AppTheme.buttonStyle,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child:CurvedBottomNavBar(
          currentIndex: _currentIndex, 
          onTap: (index){
            if (index == _currentIndex) return;
            if (index == 0) {
              Navigator.pushReplacementNamed(context, '/home');
            } else if (index == 1) {
              Navigator.pushReplacementNamed(context, '/my-orders');
            } else if (index == 2) {
              Navigator.pushReplacementNamed(context, '/my-likes');
            } else if (index == 3) {
              Navigator.pushReplacementNamed(context, '/profile');
            }
          }
        ) ,
      ),
    );
  }
}

class _FilterBottomSheet extends StatefulWidget {
  final Function(String?) onApplyFilter;
  final VoidCallback onClearFilter;

  const _FilterBottomSheet({
    required this.onApplyFilter,
    required this.onClearFilter,
  });

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  String? _selectedSort;

  final Map<String, String> _sortOptions = {
    'name_asc': 'Name (A-Z)',
    'name_desc': 'Name (Z-A)',
    'price_asc': 'Price (Low to High)',
    'price_desc': 'Price (High to Low)',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter & Sort',
                  style: AppTheme.headingStyle.copyWith(fontSize: 18),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          
          const Divider(),
          
          // Sort Options
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sort By',
                  style: AppTheme.titleDetail,
                ),
                const SizedBox(height: 16),
                
                // Sort options list
                ..._sortOptions.entries.map((entry) {
                  return RadioListTile<String>(
                    value: entry.key,
                    groupValue: _selectedSort,
                    onChanged: (value) {
                      setState(() {
                        _selectedSort = value;
                      });
                    },
                    title: Text(
                      entry.value,
                      style: AppTheme.bodyStyle.copyWith(fontSize: 14),
                    ),
                    activeColor: AppTheme.primary,
                    contentPadding: EdgeInsets.zero,
                  );
                }),
              ],
            ),
          ),
          
          // Action Buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Row(
              children: [
                // Clear button
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onClearFilter,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.primary, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'Clear',
                      style: AppTheme.buttonStyle.copyWith(
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Apply button
                Expanded(
                  child: Container(
                    decoration: AppTheme.buttonDecorationPrimary,
                    child: ElevatedButton(
                      onPressed: () => widget.onApplyFilter(_selectedSort),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        'Apply',
                        style: AppTheme.buttonStyle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}