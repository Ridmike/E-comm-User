import 'package:e_com_user/core/data/data_provider.dart';
import 'package:e_com_user/screen/login_screen/provider/user_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';


extension Providers on BuildContext {
  DataProvider get dataProvider => Provider.of<DataProvider>(this, listen: false);
  UserProvider get userProvider => Provider.of<UserProvider>(this, listen: false);
  
}






