import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodapin/components/app_theme.dart';
import 'package:foodapin/data/repositories/food_repository/food_repository.dart';
import 'package:foodapin/features/admin/detail_food_admin/bloc/delete/delete_food_bloc.dart';
import 'package:foodapin/features/admin/detail_food_admin/bloc/delete/delete_food_event.dart';
import 'package:foodapin/features/admin/detail_food_admin/bloc/delete/delete_food_state.dart';
import 'package:foodapin/features/admin/detail_food_admin/bloc/detail/detail_food_admin_bloc.dart';
import 'package:foodapin/features/admin/detail_food_admin/bloc/detail/detail_food_admin_event.dart';
import 'package:foodapin/features/admin/detail_food_admin/bloc/detail/detail_food_admin_state.dart';
import 'package:lottie/lottie.dart';

class DetailFoodAdminPage extends StatefulWidget {
  const DetailFoodAdminPage({super.key});

  @override
  State<DetailFoodAdminPage> createState() => _DetailFoodAdminPageState();
}

class _DetailFoodAdminPageState extends State<DetailFoodAdminPage> {
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args == null) {
      return const Scaffold(body: Center(child: Text("Food ID not found")));
    }

    final String foodId = args.toString();

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              DetailFoodAdminBloc(foodRepository: context.read<FoodRepository>())
                ..add(FetchFoodAdminDetail(foodId: foodId)),
        ),
        BlocProvider(
          create: (context) =>
              DeleteFoodBloc(foodRepository: context.read<FoodRepository>()),
        ),
      ],
      child: BlocListener<DeleteFoodBloc, DeleteFoodState>(
        listenWhen: (prev, curr) =>
            curr.success != prev.success || curr.errorMessage != prev.errorMessage,
        listener: (context, state) {
          if (state.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Makanan berhasil dihapus'),
                backgroundColor: Colors.green.shade600,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.all(16),
              ),
            );
            Navigator.pop(context, true);
          }
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red.shade600,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.all(16),
              ),
            );
          }
        },
        child: BlocBuilder<DetailFoodAdminBloc, DetailFoodAdminState>(
          builder: (context, state) {
            if (state is DetailFoodAdminLoading) {
              return Scaffold(
                body: SafeArea(
                  child: Center(
                    child: Lottie.asset('assets/loading.json', width: 200, height: 200, repeat: true),
                  ),
                ),
              );
            }

            if (state is DetailFoodAdminError) {
              return Scaffold(
                body: SafeArea(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          state.message,
                          style: AppTheme.bodyStyle.copyWith(color: Colors.grey.shade600),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => context
                              .read<DetailFoodAdminBloc>()
                              .add(FetchFoodAdminDetail(foodId: foodId)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: AppTheme.white,
                          ),
                          child: Text('Retry', style: AppTheme.buttonStyle),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            if (state is DetailFoodAdminLoaded) {
              final food = state.food;
              final finalPrice = food.priceDiscount ?? food.price ?? 0;

              return Scaffold(
                body: SafeArea(
                  child: SingleChildScrollView(
                    child: Center(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.92,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                InkWell(
                                  onTap: () => Navigator.pop(context),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppTheme.white,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Icon(Icons.arrow_back, color: AppTheme.black),
                                  ),
                                ),
                                Expanded(
                                  child: Center(
                                    child: Text("Details", style: AppTheme.headingStyle),
                                  ),
                                ),
                                const SizedBox(width: 40),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  width: 320,
                                  height: 400,
                                  color: Colors.grey[200],
                                  child: food.imageUrl.isNotEmpty
                                      ? Image.network(
                                          food.imageUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => const Center(
                                            child: Icon(Icons.fastfood, color: AppTheme.primary, size: 80),
                                          ),
                                        )
                                      : const Center(
                                          child: Icon(Icons.fastfood, color: AppTheme.primary, size: 80),
                                        ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(food.name, style: AppTheme.headingStyle),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    if (food.priceDiscount != null && food.price != null)
                                      Text(
                                        "Rp ${food.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}",
                                        style: AppTheme.titleDetail.copyWith(
                                          color: Colors.grey,
                                          decoration: TextDecoration.lineThrough,
                                        ),
                                      ),
                                    Text(
                                      "Rp ${finalPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}",
                                      style: AppTheme.titleDetail.copyWith(color: AppTheme.primary),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                if (food.rating != null) ...[
                                  const Icon(Icons.star, color: Colors.amber, size: 20),
                                  Text(" ${food.rating}", style: AppTheme.subtitleDetail),
                                  const SizedBox(width: 16),
                                ],
                                if (food.totalLikes != null) ...[
                                  const Icon(Icons.thumb_up, color: AppTheme.primary, size: 20),
                                  Text(" ${food.totalLikes}", style: AppTheme.subtitleDetail),
                                ],
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text("Description", style: AppTheme.titleDetail),
                            const SizedBox(height: 8),
                            Text(food.description, style: AppTheme.subtitleDetail),
                            const SizedBox(height: 16),
                            if (food.ingredients.isNotEmpty) ...[
                              Text("Ingredients", style: AppTheme.titleDetail),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: food.ingredients.map((ingredient) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppTheme.fourtenary,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: AppTheme.tertiary, width: 1),
                                    ),
                                    child: Text(
                                      ingredient,
                                      style: AppTheme.cardBody.copyWith(color: AppTheme.black),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                bottomNavigationBar: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.black.withValues(alpha: 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, -6),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: BlocBuilder<DeleteFoodBloc, DeleteFoodState>(
                        builder: (context, deleteState) {
                          return Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: deleteState.isLoading
                                      ? null
                                      : () => _confirmDelete(context, food.id!),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: AppTheme.secondary, width: 2),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 20),
                                  ),
                                  icon: deleteState.isLoading
                                      ? Center(child: Lottie.asset('assets/loading.json', width: 200, height: 200, repeat: true))
                                      : const Icon(Icons.delete_outline, color: AppTheme.secondary, size: 20),
                                  label: Text(
                                    'Delete',
                                    style: AppTheme.buttonStyle.copyWith(color: AppTheme.secondary),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    final result = await Navigator.pushNamed(
                                      context,
                                      '/update-food',
                                      arguments: food.id,
                                    );

                                    if (result == true) {
                                      Navigator.pop(context, true);
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                  ),
                                  icon: const Icon(Icons.edit_outlined, color: AppTheme.white, size: 20),
                                  label: Text('Update', style: AppTheme.buttonStyle),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              );
            }

            return Scaffold(
              body: Center(
                child: Lottie.asset('assets/loading.json', width: 200, height: 200, repeat: true),
              ),
            );
          },
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String foodId) {
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text('Delete Food', style: AppTheme.titleDetail),
      content: Text(
        'Are you sure want to delete this food?',
        style: AppTheme.bodyStyle.copyWith(fontSize: 14),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      actions: [
        SizedBox(
          width: double.infinity,
          child: Row(
            children: [
              Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: AppTheme.bodyStyle.copyWith(
                          color: AppTheme.secondary,
                        ),
                      ),
                    ),
                  ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    context.read<DeleteFoodBloc>().add(
                      DeleteFoodRequested(foodId),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('Delete', style: AppTheme.buttonStyle),
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