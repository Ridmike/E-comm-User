import 'package:e_com_user/utility/constants.dart';
import '../../../core/data/data_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_storage/get_storage.dart';
import '../../../models/product.dart';

class FavoriteProvider extends ChangeNotifier {
  final DataProvider _dataProvider;
  final box = GetStorage();
  List<Product> favoriteProduct = [];
  FavoriteProvider(this._dataProvider);

  //  Update To Favorite List
  updateToFavoriteList(String productId) {
    List<dynamic> favouriteList = box.read(FAVORITE_PRODUCT_LIST) ?? [];
    if (favouriteList.contains(productId)) {
      favouriteList.remove(productId);
    } else {
      favouriteList.add(productId);
    }
    checkIsItemFavourite(productId);
    box.write(FAVORITE_PRODUCT_LIST, favouriteList);
    loadFavoriteItems();
    notifyListeners();
  }

  //  Check Is Item Favorite
  bool checkIsItemFavourite(String productId) {
    List<dynamic> favouriteList = box.read(FAVORITE_PRODUCT_LIST) ?? [];
    bool isExist = favouriteList.contains(productId);
    return isExist;
  }

  //  Load Favorite Items
  loadFavoriteItems() {
    List<dynamic> favouriteList = box.read(FAVORITE_PRODUCT_LIST) ?? [];
    favoriteProduct = _dataProvider.products.where((product) {
      return favouriteList.contains(product.sId);
    }).toList();
    notifyListeners();
  }

  //  Clear Favorite List
  clearFavoriteList() {
    box.remove(FAVORITE_PRODUCT_LIST);
    notifyListeners();
  }
}
