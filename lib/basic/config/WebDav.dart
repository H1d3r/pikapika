import 'package:pikapika/i18.dart';
import 'package:event/event.dart';
import 'package:flutter/material.dart';

import '../Common.dart';
import '../Method.dart';
import 'IsPro.dart';

const _webdavRootPropertyName = "webdavRoot";
const _webdavUsernamePropertyName = "webdavUsername";
const _webdavPasswordPropertyName = "webdavPassword";
const _autoSyncHistoryToWebdavPropertyName = "autoSyncHistoryToWebdav";
const _useLocalFavoritePropertyName = "useLocalFavorite";
const _autoSyncLocalFavoriteToWebdavPropertyName = "autoSyncLocalFavoriteToWebdav";

late String _webdavRoot;
late String _webdavUsername;
late String _webdavPassword;
late bool _autoSyncHistoryToWebdav;
late bool _useLocalFavorite;
late bool _autoSyncLocalFavoriteToWebdav;

String get webdavRoot => _webdavRoot;
String get webdavUsername => _webdavUsername;
String get webdavPassword => _webdavPassword;
bool get useLocalFavorite => _useLocalFavorite;

final useLocalFavoriteEvent = Event();

Future initWebDav() async {
  _webdavRoot = await method.loadProperty(
    _webdavRootPropertyName,
    "",
  );
  if (_webdavRoot == "https://your.dav.host/folder") {
    _webdavRoot = "";
  }
  _webdavUsername = await method.loadProperty(
    _webdavUsernamePropertyName,
    "",
  );
  _webdavPassword = await method.loadProperty(
    _webdavPasswordPropertyName,
    "",
  );
  _useLocalFavorite = await method.loadProperty(
        _useLocalFavoritePropertyName,
        "false",
      ) ==
      "true";
  if (!isPro) {
    _autoSyncHistoryToWebdav = false;
    _autoSyncLocalFavoriteToWebdav = false;
    return;
  }
  _autoSyncHistoryToWebdav = await method.loadProperty(
        _autoSyncHistoryToWebdavPropertyName,
        "false",
      ) ==
      "true";
  _autoSyncLocalFavoriteToWebdav = await method.loadProperty(
        _autoSyncLocalFavoriteToWebdavPropertyName,
        "false",
      ) ==
      "true";
  if (_autoSyncLocalFavoriteToWebdav && _webdavRoot.isNotEmpty) {
    try {
      await method.mergeLocalFavoritesFromWebDav(
        _webdavRoot,
        _webdavUsername,
        _webdavPassword,
      );
    } catch (e, s) {
      print("$e\n$s");
    }
  }
}

Future setUseLocalFavorite(bool value) async {
  await method.saveProperty(
    _useLocalFavoritePropertyName,
    value ? "true" : "false",
  );
  _useLocalFavorite = value;
  useLocalFavoriteEvent.broadcast();
}

Widget useLocalFavoriteSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return SwitchListTile(
        value: _useLocalFavorite,
        onChanged: (bool value) async {
          await setUseLocalFavorite(value);
          setState(() {});
        },
        title: Text(tr("settings.use_local_favorite")),
        subtitle: Text(tr("settings.use_local_favorite_desc")),
      );
    },
  );
}

Future syncLocalFavoriteToWebdav(BuildContext context) async {
  if (_webdavRoot.isEmpty) {
    defaultToast(context, tr("settings.webdav.not_set"));
    return;
  }
  try {
    await method.mergeLocalFavoritesFromWebDav(
      _webdavRoot,
      _webdavUsername,
      _webdavPassword,
    );
    defaultToast(context, tr("settings.local_favorite_sync.sync_success"));
  } catch (e, s) {
    print("$e\n$s");
    defaultToast(context, tr("settings.local_favorite_sync.sync_failed"));
  }
}

Widget localFavoriteSyncAutoTile() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return SwitchListTile(
        value: _autoSyncLocalFavoriteToWebdav && isPro,
        onChanged: isPro
            ? (bool value) async {
                await method.saveProperty(
                  _autoSyncLocalFavoriteToWebdavPropertyName,
                  value ? "true" : "false",
                );
                setState(() {
                  _autoSyncLocalFavoriteToWebdav = value;
                });
                if (value) {
                  syncLocalFavoriteToWebdav(context);
                }
              }
            : null,
        title: Text(
          tr("settings.local_favorite_sync.auto_sync") +
              (isPro ? "" : " (${tr('app.pro')})"),
          style: TextStyle(
            color: isPro ? null : Colors.grey,
          ),
        ),
        subtitle: Text(tr("settings.local_favorite_sync.auto_sync_desc")),
      );
    },
  );
}

Widget localFavoriteSyncManualTile() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return ListTile(
        onTap: () async {
          await syncLocalFavoriteToWebdav(context);
        },
        title: Text(tr("settings.local_favorite_sync.manual_sync")),
      );
    },
  );
}

Future syncWebDavIfAuto(BuildContext context) async {
  if (_autoSyncHistoryToWebdav) {
    try {
      await method.mergeHistoriesFromWebDav(
        _webdavRoot,
        _webdavUsername,
        _webdavPassword,
        "pk.histories",
        "all",
      );
    } catch (e, s) {
      print("$e\n$s");
      defaultToast(context, tr("settings.webdav.sync_failed"));
    }
  }
}

Future syncHistoryToWebdav(BuildContext context) async {
  try {
    await method.mergeHistoriesFromWebDav(
      _webdavRoot,
      _webdavUsername,
      _webdavPassword,
      "pk.histories",
      "all",
    );
    defaultToast(context, tr("settings.webdav.sync_success"));
  } catch (e, s) {
    print("$e\n$s");
    defaultToast(context, tr("settings.webdav.sync_failed"));
  }
}

Future uploadHistoryToWebdav(BuildContext context) async {
  try {
    await method.mergeHistoriesFromWebDav(
      _webdavRoot,
      _webdavUsername,
      _webdavPassword,
      "pk.histories",
      "up",
    );
    defaultToast(context, tr("settings.webdav.sync_success"));
  } catch (e, s) {
    print("$e\n$s");
    defaultToast(context, tr("settings.webdav.sync_failed"));
  }
}

List<Widget> webDavSettings(BuildContext context) {
  return [
    //
    StatefulBuilder(
      builder: (BuildContext context, void Function(void Function()) setState) {
        return ListTile(
            title: Text(
              tr("settings.webdav.path"),
            ),
            subtitle:
                Text(_webdavRoot.isEmpty ? tr("settings.webdav.not_set") : _webdavRoot),
            onTap: () async {
              String? input = await displayTextInputDialog(
                context,
                src: _webdavRoot,
                title: tr("settings.webdav.path"),
                hint: tr("settings.webdav.path_hint"),
              );
              if (input != null) {
                await method.saveProperty(_webdavRootPropertyName, input);
                setState(() {
                  _webdavRoot = input == "https://your.dav.host/folder" ? "" : input;
                });
              }
            });
      },
    ),
    //
    StatefulBuilder(
      builder: (BuildContext context, void Function(void Function()) setState) {
        return ListTile(
          title: Text(
              tr("settings.webdav.username"),
            ),
            subtitle: Text(_webdavUsername),
            onTap: () async {
              String? input = await displayTextInputDialog(
                context,
                src: _webdavUsername,
                title: tr("settings.webdav.username"),
                hint: tr("settings.webdav.username_hint"),
              );
              if (input != null) {
                await method.saveProperty(_webdavUsernamePropertyName, input);
                setState(() {
                  _webdavUsername = input;
                });
              }
            });
      },
    ),
    //
    StatefulBuilder(
      builder: (BuildContext context, void Function(void Function()) setState) {
        return ListTile(
            title: Text(
              tr("settings.webdav.password"),
            ),
            subtitle: Text(_webdavPassword),
            onTap: () async {
              String? input = await displayTextInputDialog(
                context,
                src: _webdavPassword,
                title: tr("settings.webdav.password"),
                hint: tr("settings.webdav.password_hint"),
              );
              if (input != null) {
                await method.saveProperty(_webdavPasswordPropertyName, input);
                setState(() {
                  _webdavPassword = input;
                });
              }
            });
      },
    ),
    //
    ListTile(
      title: Text(tr('settings.history_sync')),
      dense: true,
    ),
    //
    StatefulBuilder(
      builder: (BuildContext context, void Function(void Function()) setState) {
        return ListTile(
          title: Text(
            tr("settings.webdav.auto_sync_history_to_webdav") +
                (isPro ? "" : "(${tr("app.pro")})"),
            style: TextStyle(
              color: !isPro ? Colors.grey : null,
            ),
          ),
          subtitle: Text(
            _autoSyncHistoryToWebdav ? tr("app.yes") : tr("app.no"),
            style: TextStyle(
              color: !isPro ? Colors.grey : null,
            ),
          ),
          onTap: () async {
            if (!isPro) {
              return;
            }
            String? result = await chooseListDialog<String>(
                context,
                tr("settings.webdav.auto_sync_history_to_webdav"),
                [tr("app.yes"), tr("app.no")]);
            if (result != null) {
              var target = result == tr("app.yes");
              await method.saveProperty(
                  _autoSyncHistoryToWebdavPropertyName, "$target");
              _autoSyncHistoryToWebdav = target;
            }
            setState(() {});
          },
        );
      },
    ),
    //
    ListTile(
        title: Text(tr("settings.webdav.sync_history_to_webdav")),
        onTap: () async {
          await syncHistoryToWebdav(context);
        }),
    //
    ListTile(
        title: Text(tr("settings.webdav.upload_history_to_webdav")),
        subtitle: Text(tr("settings.webdav.upload_history_to_webdav_desc")),
        onTap: () async {
          await uploadHistoryToWebdav(context);
        }),
    //
    const Divider(),
    ListTile(
      title: Text(tr('settings.local_favorite_sync_title')),
      dense: true,
    ),
    localFavoriteSyncAutoTile(),
    localFavoriteSyncManualTile(),
  ];
}
