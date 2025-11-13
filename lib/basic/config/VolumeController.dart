/// 音量键翻页

import 'dart:io';

import 'package:flutter/material.dart';

import '../Method.dart';
import 'package:pikapika/i18.dart';

const _propertyName = "volumeController";
late bool volumeController;

Future<void> initVolumeController() async {
  volumeController =
      (await method.loadProperty(_propertyName, "false")) == "true";
}

Widget volumeControllerSetting() {
  if (Platform.isAndroid) {
    return StatefulBuilder(builder:
        (BuildContext context, void Function(void Function()) setState) {
      return SwitchListTile(
          value: volumeController,
          title: Text(tr('settings.volume_controller.title')),
          onChanged: (target) async {
            await method.saveProperty(_propertyName, "$target");
            volumeController = target;
            setState(() {});
          });
    });
  }
  return Container();
}
