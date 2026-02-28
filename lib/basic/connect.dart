import 'dart:io';

import 'package:flutter/services.dart';

const MethodChannel _networkChannel = MethodChannel('network');

Future<bool> isMobileNetwork() async {
  if (!Platform.isAndroid && !Platform.isIOS) {
    return false;
  }
  final result = await _networkChannel.invokeMethod<bool>('getIsMobile');
  return result ?? false;
}

Future<void> checkConnectivity() async {
  final isMobile = await isMobileNetwork();
  if (isMobile) {
    print('使用移动网络');
  } else {
    print('非移动网络');
  }
}
