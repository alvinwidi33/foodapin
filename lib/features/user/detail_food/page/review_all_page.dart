import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodapin/components/app_theme.dart';
import 'package:foodapin/data/repositories/rating_repository/rating_repository.dart';
import 'package:foodapin/features/user/detail_food/bloc/rating/rating_bloc.dart';
import 'package:foodapin/features/user/detail_food/bloc/rating/rating_event.dart';
import 'package:foodapin/features/user/detail_food/bloc/rating/rating_state.dart';
import 'package:lottie/lottie.dart';

class ReviewAllPage extends StatefulWidget {
  const ReviewAllPage({super.key});

  @override
  State<ReviewAllPage> createState() => _ReviewAllPageState();
}

class _ReviewAllPageState extends State<ReviewAllPage> {
  int selectedRating = 0;
  final TextEditingController reviewController = TextEditingController();

  @override
  void dispose() {
    reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args == null) {
      return const Scaffold(body: Center(child: Text("Food ID not found")));
    }
    final String foodId = args.toString();

    return BlocProvider(
      create: (context) => RatingBloc(
        ratingRepository: context.read<RatingRepository>(),
      )..add(FetchRatingsByFood(foodId: foodId)),
      child: Scaffold(
        appBar: AppBar(
          title: Text("All Reviews", style: AppTheme.headingStyle),
          backgroundColor: AppTheme.white,
          foregroundColor: AppTheme.black,
          elevation: 0,
        ),
        body: BlocConsumer<RatingBloc, RatingState>(
          listener: (context, state) {
            if (state is RatingSuccess) {
              reviewController.clear();
              setState(() => selectedRating = 0);
              context.read<RatingBloc>().add(FetchRatingsByFood(foodId: foodId));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Review submitted")),
              );
            }

            if (state is RatingError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is RatingLoading;

            return Column(
              children: [
                // Form Submit Review
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Write a Review", style: AppTheme.titleDetail),
                      const SizedBox(height: 8),
                      Row(
                        children: List.generate(5, (index) {
                          final star = index + 1;
                          return GestureDetector(
                            onTap: () => setState(() => selectedRating = star),
                            child: Icon(
                              star <= selectedRating
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                              size: 30,
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: reviewController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: "Write your review...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppTheme.primary),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                          ),
                          onPressed: isLoading
                              ? null
                              : () {
                                  if (selectedRating == 0) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Please select a rating first"),
                                      ),
                                    );
                                    return;
                                  }
                                  context.read<RatingBloc>().add(
                                        CreateRatingEvent(
                                          foodId: foodId,
                                          rating: selectedRating,
                                          review: reviewController.text.trim(),
                                        ),
                                      );
                                },
                          child: isLoading
                              ? Center(child: Lottie.asset('assets/loading.json', width: 200, height: 200, repeat: true))
                              : const Text(
                                  "Submit",
                                  style: TextStyle(color: AppTheme.white),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(),

                // Daftar Review
                Expanded(
                  child: () {
                    if (state is RatingLoading) {
                      return Center(child: Lottie.asset('assets/loading.json', width: 200, height: 200, repeat: true));
                    }

                    if (state is RatingLoaded) {
                      if (state.ratings.isEmpty) {
                        return const Center(child: Text("No reviews yet."));
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.ratings.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          final r = state.ratings[index];
                          return ListTile(
                            leading: const CircleAvatar(
                              child: Icon(Icons.person),
                            ),
                            title: Text(r.user.email, style: AppTheme.titleDetail),
                            subtitle: r.review.isNotEmpty ? Text(r.review) : null,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star, color: Colors.amber, size: 16),
                                Text(r.rating.toString()),
                              ],
                            ),
                          );
                        },
                      );
                    }

                    return const SizedBox();
                  }(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}