import 'dart:async';
import 'package:connectivity_hive_bloc/config/utils/logger.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class InternetConnectionServices {
  // Function to check if the device is connected to the internet
  Future<bool> checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    logger.d(
        'InterentConnectionServices : connectivityResult is $connectivityResult');

    // Check for various connectivity states
    if (connectivityResult.first == ConnectivityResult.none) {
      logger.d('connection return false');
      return false; // Not connected to any network
    } else
      logger.d('connection return true');
    return true; // Connected to mobile data, Wi-Fi, Ethernet, or VPN
  }
}
