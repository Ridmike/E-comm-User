import 'package:e_com_user/models/product.dart';
import 'package:e_com_user/screen/product_details/product_details_screen.dart';
import 'package:e_com_user/screen/product_details/provider/product_details_provider.dart';
import 'package:e_com_user/core/data/data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductGridView extends StatefulWidget {
  final List<Product> items;
  final Function(Product)? onFavoriteToggle;

  const ProductGridView({
    super.key,
    required this.items,
    this.onFavoriteToggle,
  });

  @override
  State<ProductGridView> createState() => _ProductGridViewState();
}

class _ProductGridViewState extends State<ProductGridView> {
  void _toggleFavorite(Product product) {
    setState(() {
      product.isFavorite = !(product.isFavorite ?? false);
    });
    widget.onFavoriteToggle?.call(product);
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics:
          const NeverScrollableScrollPhysics(), // prevents nested scrolling
      shrinkWrap: true, // important when inside SingleChildScrollView
      itemCount: widget.items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, 
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.6, 
      ),
      itemBuilder: (context, index) {
        final product = widget.items[index];

        // Calculate discount percentage
        double discount = 0;
        if (product.price != null && product.offerPrice != null) {
          discount = 100 - ((product.offerPrice! / product.price!) * 100);
        }

        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChangeNotifierProvider(
                  create: (context) => ProductDetailProvider(
                    Provider.of<DataProvider>(context, listen: false),
                  ),
                  child: ProductDetailScreen(product),
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product image
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: AspectRatio(
                        aspectRatio: 1, 
                        child:
                            product.images != null && product.images!.isNotEmpty
                            ? Image.network(
                                product.images!.first.url ?? "",
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      color: Colors.grey.shade200,
                                      child: const Icon(
                                        Icons.image,
                                        size: 50,
                                        color: Colors.grey,
                                      ),
                                    ),
                              )
                            : Container(
                                color: Colors.grey.shade200,
                                child: const Icon(
                                  Icons.image,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              ),
                      ),
                    ),
                    // Discount badge
                    if (discount > 0)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "OFF ${discount.toStringAsFixed(0)}%",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    // Favorite Icon
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            _toggleFavorite(product);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  (product.isFavorite ?? false)
                                      ? 'Added ${product.name} to favorites'
                                      : 'Removed ${product.name} from favorites',
                                ),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(50),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              (product.isFavorite ?? false)
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: Colors.red,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Product info
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name ?? "No name",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            height: 1.2,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "\$${product.offerPrice?.toStringAsFixed(2) ?? product.price?.toStringAsFixed(2) ?? '0.00'}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                  if (product.price != null &&
                                      product.offerPrice != null &&
                                      product.price! > product.offerPrice!)
                                    Text(
                                      "\$${product.price?.toStringAsFixed(2) ?? ''}",
                                      style: const TextStyle(
                                        decoration: TextDecoration.lineThrough,
                                        fontSize: 12,
                                        color: Colors.grey,
                                        height: 1.2,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
