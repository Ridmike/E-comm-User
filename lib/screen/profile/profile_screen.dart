import 'package:e_com_user/screen/user_address_screen/user_address_wrapper.dart';
import 'package:e_com_user/screen/user_order_screen/user_order_screen.dart';
import 'package:e_com_user/utility/animations/open_container_wrapper.dart';
import 'package:e_com_user/widget/navigation_tile.dart';
import '../login_screen/login_screen.dart';
import '../../utility/extensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utility/app_color.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Assuming your theme and colors are defined elsewhere in your app
    const TextStyle linkStyle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
    );
    const TextStyle titleStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 20,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Account",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColor.darkOrange,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(
            height: 200,
            child: CircleAvatar(
              radius: 80,
              backgroundImage: AssetImage('assets/profile_pic.png'),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              "${context.userProvider.getLoginUsr()?.name}",
              style: titleStyle,
            ),
          ),
          const SizedBox(height: 40),
          const OpenContainerWrapper(
            nextScreen: UserOrderScreen(),
            child: NavigationTile(icon: Icons.list, title: 'My Orders'),
          ),
          const SizedBox(height: 15),
          const OpenContainerWrapper(
            nextScreen: UserAddressPageWrapper(),
            child: NavigationTile(
              icon: Icons.location_on,
              title: 'My Addresses',
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.darkOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                context.userProvider.logOutUser();
                Get.offAll(const LoginScreen());
              },
              child: const Text('Logout', style: TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }
}
