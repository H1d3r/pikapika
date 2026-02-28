import 'package:flutter/material.dart';
import 'package:pikapika/i18.dart';

import '../Common.dart';
import '../Method.dart';
import 'IsPro.dart';

const _propertyName = "autoDownloadOnFavorite";

late bool _autoDownloadOnFavorite;

Future initAutoDownloadOnFavorite() async {
  _autoDownloadOnFavorite =
      (await method.loadProperty(_propertyName, "false")) == "true";
  if (_autoDownloadOnFavorite && !isPro) {
    _autoDownloadOnFavorite = false;
    await method.saveProperty(_propertyName, "false");
  }
}

bool autoDownloadOnFavorite() {
  return _autoDownloadOnFavorite;
}

Widget autoDownloadOnFavoriteSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return SwitchListTile(
        value: _autoDownloadOnFavorite,
        title: Text(
          tr("settings.auto_download_on_favorite") +
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
          _autoDownloadOnFavorite = value;
          setState(() {});
        },
      );
    },
  );
}
