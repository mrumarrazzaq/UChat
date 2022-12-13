import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

CheckInternetConnectivity() async {
  bool hasInternet = await InternetConnectionChecker().hasConnection;

  final text = hasInternet ? 'Internet' : 'No internet connection';
  final color = hasInternet ? Colors.green : Colors.red;
  showSimpleNotification(
    Text('$text',
        style: const TextStyle(
          color: Colors.white,
        )),
    leading: const Icon(Icons.wifi_off),
    background: color,
  );
  return hasInternet;
}

checkAdvanceInternetConnectivity() async {
  print('Advance Internet Connectivity Checker Called');
  ConnectivityResult result = ConnectivityResult.none;
  result = await Connectivity().checkConnectivity();
  if (result != ConnectivityResult.mobile ||
      result != ConnectivityResult.wifi) {
    showSimpleNotification(
      Text('Connect Mobile Network',
          style: TextStyle(
            color: Colors.white,
          )),
      leading: Icon(Icons.mobiledata_off),
      background: Colors.red,
    );
  } else if (result != ConnectivityResult.wifi) {
    showSimpleNotification(
      const Text('Connect Wifi Network',
          style: TextStyle(
            color: Colors.white,
          )),
      leading: Icon(Icons.wifi_off),
      background: Colors.red,
    );
  } else {
    showSimpleNotification(
      const Text('Connection extablish',
          style: TextStyle(
            color: Colors.white,
          )),
      leading: Icon(Icons.wifi_off),
      background: Colors.green,
    );
  }
}
