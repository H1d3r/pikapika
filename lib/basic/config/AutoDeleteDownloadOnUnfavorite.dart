import 'package:flutter/material.dart';
import 'package:pikapika/i18.dart';

import '../Common.dart';
import '../Method.dart';
import 'IsPro.dart';

const _propertyName = "autoDeleteDownloadOnUnfavorite";

late bool _autoDeleteDownloadOnUnfavorite;

Future initAutoDeleteDownloadOnUnfavorite() async {
  _autoDeleteDownloadOnUnfavorite =
      (await method.loadProperty(_propertyName, "false")) == "true";
  if (_autoDeleteDownloadOnUnfavorite && !isPro) {
    _autoDeleteDownloadOnUnfavorite = false;
    await method.saveProperty(_propertyName, "false");
  }
}

bool autoDeleteDownloadOnUnfavorite() {
  return _autoDeleteDownloadOnUnfavorite;
}

Widget autoDeleteDownloadOnUnfavoriteSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return SwitchListTile(
        value: _autoDeleteDownloadOnUnfavorite,
        title: Text(
          tr("settings.auto_delete_download_on_unfavorite") +
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
          _autoDeleteDownloadOnUnfavorite = value;
          setState(() {});
        },
      );
    },
  );
}
