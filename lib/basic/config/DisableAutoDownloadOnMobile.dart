import 'package:flutter/material.dart';
import 'package:pikapika/i18.dart';

import '../Common.dart';
import '../Method.dart';
import 'IsPro.dart';

const _propertyName = "disableAutoDownloadOnMobile";

late bool _disableAutoDownloadOnMobile;

Future initDisableAutoDownloadOnMobile() async {
  _disableAutoDownloadOnMobile =
      (await method.loadProperty(_propertyName, "false")) == "true";
  if (_disableAutoDownloadOnMobile && !isPro) {
    _disableAutoDownloadOnMobile = false;
    await method.saveProperty(_propertyName, "false");
  }
}

bool disableAutoDownloadOnMobile() {
  return _disableAutoDownloadOnMobile;
}

Widget disableAutoDownloadOnMobileSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return SwitchListTile(
        value: _disableAutoDownloadOnMobile,
        title: Text(
          tr("settings.disable_auto_download_on_mobile") +
              (!isPro ? "(${tr("app.pro")})" : ""),
          style: TextStyle(
            color: !isPro ? Colors.grey : null,
          ),
        ),
        subtitle: !isPro ? Text(tr("app.pro_required")) : null,
        onChanged: (value) async {
          if (!isPro) {
            defaultToast(context, tr("app.pro_required"));
            return;
          }
          await method.saveProperty(_propertyName, "$value");
          _disableAutoDownloadOnMobile = value;
          setState(() {});
        },
      );
    },
  );
}
