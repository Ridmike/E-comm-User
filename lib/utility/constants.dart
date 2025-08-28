import 'package:flutter/foundation.dart';

String get MAIN_URL {
  // Running on web
  if (kIsWeb) {
    return 'http://localhost:3000';
  }
  // Running on Android Emulator
  else if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2:3000'; // Special Android emulator address for localhost
  }
  // Running on physical device - REPLACE THIS WITH YOUR COMPUTER'S IP ADDRESS
  else {
    return 'http://192.168.1.11:3000'; // Your computer's IP address
  }
}

const USER_INFO_BOX = 'USER_INFO_BOX';
const FAVORITE_PRODUCT_LIST = 'FAVORITE_PRODUCT_LIST';
