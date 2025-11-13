import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:universityclassroommanagement/features/shared/presentaion/widgets/ShowSnackBarMessage.dart';

class ConnectivityService{
  ConnectivityService._();
  static final ConnectivityService _instance = ConnectivityService._();
  factory ConnectivityService() => _instance;

  final Connectivity _connectivity = Connectivity();
  final ValueNotifier<bool> isOffline = ValueNotifier(false);
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  Future<void> initialize()async{
    final result =await _connectivity.checkConnectivity();
    isOffline.value = result.contains(ConnectivityResult.none);
    _subscription = _connectivity.onConnectivityChanged.listen((result){
      final offline = result.contains(ConnectivityResult.none);
      if(isOffline.value != offline){
        isOffline.value = offline;
        Get.snackbar(offline?"🚫 Offline":"🌐 Online", offline?"You are offline now":"You are online now");
      }
    });
  }

  void dispose()=>_subscription?.cancel();

}