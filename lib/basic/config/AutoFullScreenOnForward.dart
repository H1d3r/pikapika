/// 前进时自动全屏

import 'package:pikapika/i18.dart';
import 'package:flutter/material.dart';

import '../Common.dart';
import '../Method.dart';

const _propertyName = "autoFullScreenOnForward";
late bool _autoFullScreenOnForward;

Future<void> initAutoFullScreenOnForward() async {
  _autoFullScreenOnForward =
      (await method.loadProperty(_propertyName, "false")) == "true";
}

bool currentAutoFullScreenOnForward() {
  return _autoFullScreenOnForward;
}

Future<void> setAutoFullScreenOnForward(bool value) async {
  _autoFullScreenOnForward = value;
  await method.saveProperty(_propertyName, "$value");
}

Widget autoFullScreenOnForwardSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return SwitchListTile(
        value: _autoFullScreenOnForward,
        title: Text(tr("settings.auto_full_screen_on_forward.title")),
        onChanged: (a) async {
          await method.saveProperty(_propertyName, "$a");
          _autoFullScreenOnForward = a;
          setState(() {});
        },
      );
    },
  );
}
