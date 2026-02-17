import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodapin/components/app_theme.dart';
import 'package:foodapin/data/repositories/cart_repository/cart_repository.dart';
import 'package:foodapin/features/user/my-cart/bloc/cart_bloc.dart';
import 'package:foodapin/features/user/my-cart/bloc/cart_event.dart';
import 'package:foodapin/features/user/my-cart/bloc/cart_state.dart';
import 'package:lottie/lottie.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final Set<String> selectedCartIds = {};

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CartBloc(
        cartRepository: context.read<CartRepository>(),
      )..add(const FetchCart()),
      child: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          // Loading
          if (state is CartLoading) {
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

          // Error
          if (state is CartError) {
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
                        onPressed: () => context.read<CartBloc>().add(const FetchCart()),
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
                        child: Text('Retry', style: AppTheme.buttonStyle),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          final carts = state is CartLoaded ? state.cart : [];

          final selectedCarts = carts.where((cart) => selectedCartIds.contains(cart.id)).toList();
          final int totalPrice = selectedCarts.fold<int>(
            0,
            (int sum, cart) {
              final int price =
                  (cart.food?.priceDiscount ?? cart.food?.price ?? 0).toInt();

              final int quantity = cart.quantity.toInt();

              return sum + (price * quantity);
            },
          );

          return Scaffold(
            backgroundColor: AppTheme.screen,
            body: SafeArea(
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.arrow_back, color: AppTheme.black, size: 20),
                          ),
                        ),
                        const Expanded(
                          child: Center(
                            child: Text(
                              "My Cart",
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        // Select All button
                        if (carts.isNotEmpty)
                          InkWell(
                            onTap: () {
                              setState(() {
                                if (selectedCartIds.length == carts.length) {
                                  selectedCartIds.clear();
                                } else {
                                  selectedCartIds.clear();
                                  selectedCartIds.addAll(carts.map((c) => c.id));
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: selectedCartIds.length == carts.length
                                    ? AppTheme.primary
                                    : AppTheme.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppTheme.primary),
                              ),
                              child: Text(
                                selectedCartIds.length == carts.length ? "Deselect All" : "Select All",
                                style: AppTheme.cardBody.copyWith(
                                  color: selectedCartIds.length == carts.length
                                      ? AppTheme.white
                                      : AppTheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Cart List
                  Expanded(
                    child: carts.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey.shade300),
                                const SizedBox(height: 16),
                                Text(
                                  "Your cart is empty",
                                  style: AppTheme.titleDetail.copyWith(color: Colors.grey.shade400),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Add some delicious food!",
                                  style: AppTheme.cardBody.copyWith(color: Colors.grey.shade400),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: carts.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final cart = carts[index];
                              final isSelected = selectedCartIds.contains(cart.id);
                              final food = cart.food;
                              final int itemPrice = ((food?.priceDiscount ?? food?.price ?? 0) * cart.quantity).toInt();

                              return Container(
                                decoration: BoxDecoration(
                                  color: AppTheme.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected ? AppTheme.primary : Colors.transparent,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      // Checkbox
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            if (isSelected) {
                                              selectedCartIds.remove(cart.id);
                                            } else {
                                              selectedCartIds.add(cart.id);
                                            }
                                          });
                                        },
                                        child: Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            color: isSelected ? AppTheme.primary : AppTheme.white,
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(
                                              color: isSelected ? AppTheme.primary : Colors.grey.shade300,
                                              width: 2,
                                            ),
                                          ),
                                          child: isSelected
                                              ? const Icon(Icons.check, color: AppTheme.white, size: 16)
                                              : null,
                                        ),
                                      ),
                                      const SizedBox(width: 12),

                                      // Food Image
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Container(
                                          width: 70,
                                          height: 70,
                                          color: Colors.grey.shade200,
                                          child: food?.imageUrl != null && food!.imageUrl.isNotEmpty
                                              ? Image.network(
                                                  food.imageUrl,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (_, __, ___) => const Icon(
                                                    Icons.fastfood,
                                                    color: AppTheme.primary,
                                                  ),
                                                )
                                              : const Icon(Icons.fastfood, color: AppTheme.primary),
                                        ),
                                      ),
                                      const SizedBox(width: 12),

                                      // Food Info
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // Name + Delete
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    food?.name ?? '-',
                                                    style: AppTheme.cardTitle,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    setState(() => selectedCartIds.remove(cart.id));
                                                    context.read<CartBloc>().add(
                                                      DeleteCart(cartId: cart.id),
                                                    );
                                                  },
                                                  child: Icon(Icons.close, size: 18, color: Colors.grey.shade400),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),

                                            // Price
                                            Row(
                                              children: [
                                                if (food?.priceDiscount != null && food?.price != null) ...[
                                                  Text(
                                                    "Rp ${food!.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}",
                                                    style: AppTheme.cardBody.copyWith(
                                                      color: Colors.grey,
                                                      decoration: TextDecoration.lineThrough,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 4),
                                                ],
                                                Text(
                                                  "Rp ${(food?.priceDiscount ?? food?.price ?? 0).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}",
                                                  style: AppTheme.cardBody.copyWith(color: Colors.grey.shade600),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),

                                            // Quantity Stepper + Total
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    // Minus
                                                    GestureDetector(
                                                      onTap: () {
                                                        context.read<CartBloc>().add(
                                                          UpdateCartQuantity(
                                                            cartId: cart.id,
                                                            quantity: cart.quantity - 1,
                                                          ),
                                                        );
                                                      },
                                                      child: Container(
                                                        width: 28,
                                                        height: 28,
                                                        decoration: BoxDecoration(
                                                          color: Colors.grey.shade100,
                                                          borderRadius: BorderRadius.circular(8),
                                                          border: Border.all(color: Colors.grey.shade300),
                                                        ),
                                                        child: const Icon(Icons.remove, size: 16),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 36,
                                                      alignment: Alignment.center,
                                                      child: Text(
                                                        cart.quantity.toString(),
                                                        style: AppTheme.cardTitle,
                                                      ),
                                                    ),
                                                    // Plus
                                                    GestureDetector(
                                                      onTap: () {
                                                        context.read<CartBloc>().add(
                                                          UpdateCartQuantity(
                                                            cartId: cart.id,
                                                            quantity: cart.quantity + 1,
                                                          ),
                                                        );
                                                      },
                                                      child: Container(
                                                        width: 28,
                                                        height: 28,
                                                        decoration: BoxDecoration(
                                                          color: AppTheme.primary,
                                                          borderRadius: BorderRadius.circular(8),
                                                        ),
                                                        child: const Icon(Icons.add, size: 16, color: AppTheme.white),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                // Item Total
                                                Text(
                                                  "Rp ${itemPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}",
                                                  style: AppTheme.cardTitle.copyWith(color: AppTheme.primary),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),

                  // Bottom Summary
                  if (carts.isNotEmpty)
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 20,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Text("Your Orders", style: AppTheme.titleDetail),
                                  const SizedBox(width: 8),
                                  Text(
                                    "(${selectedCartIds.length} item${selectedCartIds.length != 1 ? 's' : ''} selected)",
                                    style: AppTheme.cardBody.copyWith(color: Colors.grey),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Bill Total", style: AppTheme.subtitleDetail.copyWith(fontSize: 14, color: Colors.grey.shade600)),
                                  Text(
                                    "Rp ${totalPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}",
                                    style: AppTheme.subtitleDetail.copyWith(fontSize: 14),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Delivery Charge", style: AppTheme.subtitleDetail.copyWith(fontSize: 14, color: Colors.grey.shade600)),
                                  Text(
                                    selectedCartIds.isEmpty ? "Rp 0" : "Rp 5.000",
                                    style: AppTheme.subtitleDetail.copyWith(fontSize: 14),
                                  ),
                                ],
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Divider(),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Grand Total", style: AppTheme.titleDetail),
                                  Text(
                                    "Rp ${(totalPrice + (selectedCartIds.isEmpty ? 0 : 5000)).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}",
                                    style: AppTheme.titleDetail.copyWith(color: AppTheme.primary),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: selectedCartIds.isEmpty ? null : () {
                                    // Handle checkout
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: selectedCartIds.isEmpty
                                        ? Colors.grey.shade300
                                        : AppTheme.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    "Proceed to Pay",
                                    style: AppTheme.buttonStyle.copyWith(
                                      color: selectedCartIds.isEmpty ? Colors.grey.shade500 : AppTheme.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}