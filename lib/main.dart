import 'package:e_com_user/screen/login_screen/login_screen.dart';
import 'package:e_com_user/utility/animations/app_theme.dart';
import 'screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:ui' show PointerDeviceKind;
import 'package:provider/provider.dart';
import 'package:flutter_cart/flutter_cart.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  var cart = FlutterCart();
  //complete add one signal app id

  await cart.initializeCart(isPersistenceSupportEnabled: true);

  runApp(
    MultiProvider(
      providers: [Provider<FlutterCart>.value(value: cart)],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch},
      ),
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
      theme: AppTheme.lightAppTheme,
    );
  }
}
