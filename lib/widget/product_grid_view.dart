import 'package:e_com_user/screen/product_details/product_details_screen.dart';
import 'package:e_com_user/utility/animations/open_container_wraper.dart';
import 'package:e_com_user/widget/product_grid_title.dart';
import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductGridView extends StatelessWidget {
  const ProductGridView({
    super.key,
    required this.items,
  });

  final List<Product> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: GridView.builder(
        itemCount: items.length,
        shrinkWrap: true,
        physics: const ScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: 10 / 16,
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
        itemBuilder: (context, index) {
          Product product = items[index];
          return OpenContainerWrapper(
            nextScreen: ProductDetailScreen(product),
            child: ProductGridTile(
              product: product,
              index: index,
              isPriceOff: product.offerPrice != 0,
            ),
          );
        },
      ),
    );
  }
}