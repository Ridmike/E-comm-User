import 'package:e_com_user/core/data/data_provider.dart';
import 'package:e_com_user/screen/login_screen/provider/user_provider.dart';
import 'package:e_com_user/screen/product_by_category/provider/product_by_category_provider.dart';
import 'package:e_com_user/screen/product_cart/provider/cart_provider.dart';
import 'package:e_com_user/screen/product_details/provider/product_details_provider.dart';
import 'package:e_com_user/screen/product_favourite/provider/favorite_provider.dart';
import 'package:e_com_user/screen/profile/provider/profile_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';


extension Providers on BuildContext {
  DataProvider get dataProvider => Provider.of<DataProvider>(this, listen: false);
  UserProvider get userProvider => Provider.of<UserProvider>(this, listen: false);
  ProductByCategoryProvider get proByCProvider => Provider.of<ProductByCategoryProvider>(this, listen: false);
  FavoriteProvider get favoriteProvider => Provider.of<FavoriteProvider>(this, listen: false);
  ProductDetailProvider get productDetailProvider => Provider.of<ProductDetailProvider>(this, listen: false);
  CartProvider get cartProvider => Provider.of<CartProvider>(this, listen: false);
  ProfileProvider get profileProvider => Provider.of<ProfileProvider>(this, listen: false);
}






