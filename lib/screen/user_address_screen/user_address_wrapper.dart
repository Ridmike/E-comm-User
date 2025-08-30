import 'package:e_com_user/core/data/data_provider.dart';
import 'package:e_com_user/screen/profile/provider/profile_provider.dart';
import 'package:e_com_user/screen/user_address_screen/user_address.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserAddressPageWrapper extends StatelessWidget {
  const UserAddressPageWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileProvider(context.read<DataProvider>()),
      child: const UserAddressPage(),
    );
  }
}
