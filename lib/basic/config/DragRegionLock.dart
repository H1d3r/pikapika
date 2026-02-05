import 'package:pikapika/i18.dart';
import 'package:flutter/material.dart';

import '../Common.dart';
import '../Method.dart';

const _propertyName = "dragRegionLock";

late bool _dragRegionLock;

Future initDragRegionLock() async {
  _dragRegionLock = (await method.loadProperty(_propertyName, "true")) == "true";
}

bool dragRegionLock() {
  return _dragRegionLock;
}

Future<void> setDragRegionLock(bool value) async {
  await method.saveProperty(_propertyName, "$value");
  _dragRegionLock = value;
}

Widget dragRegionLockSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return SwitchListTile(
        value: _dragRegionLock,
        title: Text(tr("settings.drag_region_lock.title")),
        onChanged: (target) async {
          await method.saveProperty(_propertyName, "$target");
          _dragRegionLock = target;
          setState(() {});
        },
      );
    },
  );
}
