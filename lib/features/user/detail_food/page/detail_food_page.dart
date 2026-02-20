import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodapin/components/app_theme.dart';
import 'package:foodapin/data/repositories/cart_repository/cart_repository.dart';
import 'package:foodapin/data/repositories/food_repository/food_repository.dart';
import 'package:foodapin/features/user/detail_food/bloc/cart/cart_bloc.dart';
import 'package:foodapin/features/user/detail_food/bloc/cart/cart_event.dart';
import 'package:foodapin/features/user/detail_food/bloc/cart/cart_state.dart';
import 'package:foodapin/features/user/detail_food/bloc/detail_food/detail_food_bloc.dart';
import 'package:foodapin/features/user/detail_food/bloc/detail_food/detail_food_event.dart';
import 'package:foodapin/features/user/detail_food/bloc/detail_food/detail_food_state.dart';
import 'package:lottie/lottie.dart';

class DetailFoodPage extends StatefulWidget {
  const DetailFoodPage({super.key});
  
  @override
  State<DetailFoodPage> createState() => _DetailFoodPageState();
}

class _DetailFoodPageState extends State<DetailFoodPage> {
  int quantity = 1;

  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => WillPopScope(
        onWillPop: () async => false, 
        child: Center(
          child: Lottie.asset(
            'assets/loading.json',
            width: 200,
            height: 200,
            repeat: true,
          ),
        ),
      ),
    );
  }

  void closeLoadingDialog(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

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
          create: (context) => DetailFoodBloc(foodRepository: context.read<FoodRepository>())
            ..add(FetchFoodDetail(foodId: foodId)),
        ),
        BlocProvider(
          create: (context) => CartBloc(cartRepository: context.read<CartRepository>()),
        ),
      ],
      child: BlocListener<CartBloc, CartState>(
        listenWhen: (previous, current) {

          return current is CartSuccess || current is CartFailure || 
                 (current is CartLoading && previous is! CartLoading);
        },
        listener: (context, state) {
        if (state is CartLoading) {
          showLoadingDialog(context);
        }

        if (state is CartSuccess) {
          Navigator.of(context, rootNavigator: true).pop();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );

          Navigator.pushNamedAndRemoveUntil(
            context,
            '/my-cart',
            (route) => route.isFirst,
          );
        }

        if (state is CartFailure) {
          Navigator.of(context, rootNavigator: true).pop();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },

        child: BlocBuilder<DetailFoodBloc, DetailFoodState>(
          builder: (context, state) {
            if (state is DetailFoodLoading) {
              return Scaffold(
                body: SafeArea(
                  child: Center(
                    child: Lottie.asset(
                      'assets/loading.json',
                      width: 200,
                      height: 200,
                      repeat: true,
                    ),
                  ),
                ),
              );
            }
            
            if (state is DetailFoodError) {
              return Scaffold(
                body: SafeArea(
                  child: Center(
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
                            context.read<DetailFoodBloc>().add(
                              FetchFoodDetail(foodId: foodId),
                            );
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
                  ),
                ),
              );
            }
            
            if (state is DetailFoodLoaded) {
              final food = state.food;
              final finalPrice = food.priceDiscount ?? food.price ?? 0;
              
              return Scaffold(
                body: SafeArea(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Center(
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
                                        child: const Icon(
                                          Icons.arrow_back,
                                          color: AppTheme.black,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                          "Details",
                                          style: AppTheme.headingStyle
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      food.isLike == true 
                                        ? Icons.favorite 
                                        : Icons.favorite_border,
                                      color: food.isLike == true 
                                        ? AppTheme.primary 
                                        : AppTheme.black,
                                    ),
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
                                                size: 80,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        food.name,
                                        style: AppTheme.headingStyle,
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        if (food.priceDiscount != null && food.price != null)
                                          Text(
                                            "Rp ${food.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}",
                                            style: AppTheme.titleDetail.copyWith(
                                              color: Colors.grey,
                                              decoration: TextDecoration.lineThrough,
                                            ),
                                          ),
                                        Text(
                                          "Rp ${finalPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}",
                                          style: AppTheme.titleDetail.copyWith(
                                            color: AppTheme.primary,
                                          ),
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
                                      Text(
                                        " ${food.rating}",
                                        style: AppTheme.subtitleDetail,
                                      ),
                                      const SizedBox(width: 16),
                                    ],
                                    if (food.totalLikes != null) ...[
                                      const Icon(Icons.thumb_up, color: AppTheme.primary, size: 20),
                                      Text(
                                        " ${food.totalLikes}",
                                        style: AppTheme.subtitleDetail,
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text("Description", style: AppTheme.titleDetail),
                                const SizedBox(height: 8),
                                Text(
                                  food.description,
                                  style: AppTheme.subtitleDetail,
                                ),
                                const SizedBox(height: 16),
                                if (food.ingredients.isNotEmpty) ...[
                                  Text("Ingredients", style: AppTheme.titleDetail),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: food.ingredients.map((ingredient) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppTheme.fourtenary,
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(
                                            color: AppTheme.tertiary,
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          ingredient,
                                          style: AppTheme.cardBody.copyWith(
                                            color: AppTheme.black,
                                          ),
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
                      ],
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
                        color: AppTheme.black.withValues(alpha:0.08),
                        blurRadius: 20,
                        offset: const Offset(0, -6),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Center(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          if (quantity > 1) {
                                            setState(() {
                                              quantity--;
                                            });
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade200,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(Icons.remove),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Text(
                                        quantity.toString(),
                                        style: AppTheme.headingStyle,
                                      ),
                                      const SizedBox(width: 16),
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            quantity++;
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: AppTheme.primary,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                            Icons.add,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  child: Text(
                                    "Rp ${(finalPrice * quantity).toString().replaceAllMapped(
                                      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                      (Match m) => '${m[1]}.',
                                    )}",
                                    style: AppTheme.titleDetail.copyWith(
                                      color: AppTheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed:  (){
                                if (food.id != null) {
                                  context.read<CartBloc>().add(
                                    AddToCart(
                                      foodId: food.id!,
                                      quantity: quantity,
                                    ),
                                  );
                                }
                              },
                              child: Text(
                                "Add To Cart",
                                style: AppTheme.buttonStyle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }
            
            return Scaffold(
              body: Center(
                child: Lottie.asset(
                  'assets/loading.json',
                  width: 200,
                  height: 200,
                  repeat: true,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}