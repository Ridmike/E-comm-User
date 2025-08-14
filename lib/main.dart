import 'package:e_com_user/utility/animations/app_theme.dart';
import 'screen/home_screen.dart';
import 'screen/login_screen/login_screen.dart';
import 'screen/login_screen/provider/user_provider.dart';
import 'utility/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cart/cart.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:ui' show PointerDeviceKind;
import 'package:provider/provider.dart';
import 'core/data/data_provider.dart';
import 'models/user.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  var cart = FlutterCart();
  // OneSignal.initialize("YOUR_ONE_SIGNAL_APP_ID");
  // OneSignal.Notifications.requestPermission(true);
  await cart.initializeCart(isPersistenceSupportEnabled: true);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => DataProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider(context.dataProvider)),
      ],
      child: const MyApp(),
    ),
  );
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    User? loginUser = context.userProvider.getLoginUsr();
    return GetMaterialApp(
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
        },
      ),
      debugShowCheckedModeBanner: false,
      home: loginUser?.sId == null ? const LoginScreen() : const HomeScreen(),
      theme: AppTheme.lightAppTheme,
    );
  }
}
