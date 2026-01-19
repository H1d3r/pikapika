import 'package:pikapika/i18.dart';
import 'package:event/event.dart';
import 'package:flutter/material.dart';
import '../Method.dart';

const _propertyName = "hideOnlineFavorite";

late bool _hideOnlineFavorite;

bool get hideOnlineFavorite => _hideOnlineFavorite;

var hideOnlineFavoriteEvent = Event<EventArgs>();

Future initHideOnlineFavorite() async {
  _hideOnlineFavorite =
      (await method.loadProperty(_propertyName, "false")) == "true";
}

Widget hideOnlineFavoriteSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return SwitchListTile(
        title: Text(tr("settings.hide_online_favorite.title")),
        subtitle: Text(tr("settings.hide_online_favorite.desc")),
        value: _hideOnlineFavorite,
        onChanged: (value) async {
          await method.saveProperty(_propertyName, "$value");
          _hideOnlineFavorite = value;
          setState(() {});
          hideOnlineFavoriteEvent.broadcast();
        },
      );
    },
  );
}

