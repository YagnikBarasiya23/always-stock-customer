import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

enum ConnectivityStatus { online, offline }

class ConnectivityCubit extends Cubit<ConnectivityStatus> {
  late StreamSubscription _subscription;

  ConnectivityCubit() : super(ConnectivityStatus.offline) {
    _init();
  }

  Future<void> _init() async {
    final hasAccess = await ConnectivityService.hasInternetAccess;
    emit(hasAccess ? ConnectivityStatus.online : ConnectivityStatus.offline);

    _subscription = ConnectivityService.onStatusChange.listen((status) {
      emit(status == InternetStatus.connected ? ConnectivityStatus.online : ConnectivityStatus.offline);
    });
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}

abstract class ConnectivityService {
  static final InternetConnection _instance = InternetConnection();

  static InternetConnection get instance => _instance;

  static Future<bool> get hasInternetAccess => _instance.hasInternetAccess;

  static Stream<InternetStatus> get onStatusChange => _instance.onStatusChange;
}
