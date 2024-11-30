import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:connectivity_hive_bloc/config/utils/logger.dart';
import 'package:connectivity_hive_bloc/domain/services/internet_connection_services.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';

part 'internet_connection_state.dart';

class InternetConnectionCubit extends Cubit<InternetConnectionState> {
  final InternetConnectionServices _internetConnectionServices;
  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  InternetConnectionCubit(this._internetConnectionServices, this._connectivity)
      : super(InternetConnectionInitial()) {
    _checkInitialConnection(); // Memeriksa koneksi saat inisialisasi
    trackConnectivityChange(); // Memulai pemantauan perubahan koneksi
    checkConnection();
  }

  Future<void> _checkInitialConnection() async {
    bool isConnected =
        await _internetConnectionServices.checkInternetConnection();
    logger.d('status internet is $isConnected');
    if (isConnected) {
      emit(InternetStatusConnected());
    } else {
      emit(
          InternetStatusDisconnected()); // Emit disconnected state jika tidak terhubung
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> result) {
    if (result.first == ConnectivityResult.none) {
      emit(InternetStatusDisconnected());
    } else {
      emit(
          InternetStatusConnected()); // Emit connected state jika ada konektivitas
    }
  }

  // Method untuk memeriksa koneksi internet secara manual
  Future<void> checkConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    logger.d(
        'connectivityResult in cubit: $connectivityResult');

    // Check for various connectivity states
    if (connectivityResult.first == ConnectivityResult.none) {
      logger.d('connection return false in cubit, emiting InternetStatusDisconnected');
      emit(InternetStatusDisconnected());
      // return false; // Not connected to any network
    } else
      logger.d('connection return true');
    emit(
        InternetStatusConnected()); // Emit connected state jika ada konektivitas
    // return true; // Connected to mobile data, Wi-Fi, Ethernet, or VPN
  }

  void trackConnectivityChange() {
    _subscription = _connectivity.onConnectivityChanged.listen((result) {
      _updateConnectionStatus(result);
    });
  }

  @override
  Future<void> close() {
    _subscription
        ?.cancel(); // Pastikan untuk membatalkan langganan saat Cubit ditutup
    return super.close();
  }
}
