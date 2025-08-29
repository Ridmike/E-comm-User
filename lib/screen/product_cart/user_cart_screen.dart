import 'package:e_com_user/screen/product_cart/components/byu_now.dart';
import 'package:e_com_user/screen/product_cart/components/cart_list_section.dart';
import 'package:e_com_user/screen/product_cart/components/empty_cart.dart';
import 'package:e_com_user/utility/animations/animated_switcher_wrapper.dart';

import 'provider/cart_provider.dart';
import '../../utility/extensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utility/app_color.dart';

class UserCartScreen extends StatelessWidget {
  const UserCartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero, () {
      //  Get Cart Items
      context.cartProvider.getCartItems();
    });
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Cart",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColor.darkOrange,
          ),
        ),
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              cartProvider.myCartItems.isEmpty
                  ? const EmptyCart()
                  : Consumer<CartProvider>(
                      builder: (context, cartProvider, child) {
                        return CartListSection(
                          cartProducts: cartProvider.myCartItems,
                        );
                      },
                    ),

              //? total price section
              Container(
                margin: const EdgeInsets.only(bottom: 15),
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    AnimatedSwitcherWrapper(
                      child: Text(
                        "\$${context.cartProvider.getCartSubTotal()}", //  Amount to Cart SubTotal
                        // key: ValueKey<double>(cartProvider.getCartSubTotal()),
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFEC6813),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              //? buy now button
              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 30,
                    right: 30,
                    bottom: 20,
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(20),
                    ),
                    onPressed: context.cartProvider.myCartItems.isEmpty
                        ? null
                        : () {
                            showCustomBottomSheet(context);
                          },
                    child: const Text(
                      "Buy Now",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
