/// 显示模式, 仅安卓有效

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pikapika/basic/Method.dart';
import 'package:pikapika/i18.dart';

import '../Common.dart';
import 'IsPro.dart';

const _propertyName = "androidDisplayMode";
List<String> _modes = [];
String _androidDisplayMode = "";

Future initAndroidDisplayMode() async {
  if (Platform.isAndroid) {
    _androidDisplayMode = await method.loadProperty(_propertyName, "");
    _modes = await method.loadAndroidModes();
    await _changeMode();
  }
}

Future _changeMode() async {
  await method.setAndroidMode(_androidDisplayMode);
}

Future<void> _chooseAndroidDisplayMode(BuildContext context) async {
  if (Platform.isAndroid) {
    List<String> list = [""];
    list.addAll(_modes);
    String? result = await chooseListDialog<String>(
      context,
      tr('settings.android_display_mode.dialog_title'),
      list,
    );
    if (result != null) {
      await method.saveProperty(_propertyName, result);
      _androidDisplayMode = result;
      await _changeMode();
    }
  }
}

Widget androidDisplayModeSetting() {
  if (Platform.isAndroid) {
    return StatefulBuilder(
      builder: (BuildContext context, void Function(void Function()) setState) {
        return ListTile(
          title: Text(
            tr('settings.android_display_mode.title') + (!isPro ? "(${tr('app.pro')})" : ""),
            style: TextStyle(
              color: !isPro ? Colors.grey : null,
            ),
          ),
          subtitle: Text(_androidDisplayMode),
          onTap: () async {
            if (!isPro) {
              defaultToast(context, tr('app.pro_required'));
              return;
            }
            await _chooseAndroidDisplayMode(context);
            setState(() {});
          },
        );
      },
    );
  }
  return Container();
}
