import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract interface class INetworkInfo {
  Future<bool> get isConnected;
}

final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfo(Connectivity());
});

class NetworkInfo implements INetworkInfo{
  final Connectivity _connectivity;

  NetworkInfo(this._connectivity);

  @override
  Future<bool> get isConnected async{
    final result = await _connectivity.checkConnectivity(); // wifi/mobile data on xa ki off xa check garxa
    if(result.contains(ConnectivityResult.none)) {
      return false;
    }
    // return await _hasInternetConnection();
    return true;
  }

  // [internet xa ki xaina check garne]
  Future<bool> _hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch(_) {
      return false;
    }
  }
}