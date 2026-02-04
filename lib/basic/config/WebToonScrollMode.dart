import 'package:pikapika/i18.dart';
import 'package:flutter/material.dart';

import '../Method.dart';

enum WebToonScrollMode {
  IMAGE,
  SCREEN, // Distance
}

const _propertyName = "webToonScrollMode";

WebToonScrollMode _webToonScrollMode = WebToonScrollMode.IMAGE;

Future initWebToonScrollMode() async {
  var value = await method.loadProperty(_propertyName, "0");
  if (value == "1") {
    _webToonScrollMode = WebToonScrollMode.SCREEN;
  } else {
    _webToonScrollMode = WebToonScrollMode.IMAGE;
  }
}

WebToonScrollMode currentWebToonScrollMode() => _webToonScrollMode;

Widget webToonScrollModeSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return ListTile(
        title: Text(tr("settings.web_toon_scroll_mode.title")),
        subtitle: Text(_webToonScrollMode == WebToonScrollMode.SCREEN
            ? tr("settings.web_toon_scroll_mode.screen")
            : tr("settings.web_toon_scroll_mode.image")),
        onTap: () async {
          var result = await showDialog<WebToonScrollMode>(
            context: context,
            builder: (BuildContext context) {
              return SimpleDialog(
                title: Text(tr("settings.web_toon_scroll_mode.choose")),
                children: [
                   SimpleDialogOption(
                    onPressed: () {
                      Navigator.pop(context, WebToonScrollMode.IMAGE);
                    },
                    child: Text(tr("settings.web_toon_scroll_mode.image")),
                  ),
                  SimpleDialogOption(
                    onPressed: () {
                      Navigator.pop(context, WebToonScrollMode.SCREEN);
                    },
                    child: Text(tr("settings.web_toon_scroll_mode.screen")),
                  ),
                ],
              );
            },
          );
          if (result != null) {
            await method.saveProperty(
                _propertyName, result == WebToonScrollMode.SCREEN ? "1" : "0");
            _webToonScrollMode = result;
            setState(() {});
          }
        },
      );
    },
  );
}
