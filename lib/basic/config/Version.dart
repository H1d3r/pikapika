import 'dart:async' show Future;
import 'dart:convert';
import 'package:event/event.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pikapika/basic/Common.dart';
import 'package:pikapika/basic/Cross.dart';

import '../Method.dart';
import 'IgnoreUpgradeConfirm.dart';

const repoOwnerUrl =
    "https://api.github.com/repos/ComicSparks/glxx/releases/tags/pikapika";
const _releasesUrl = "https://github.com/OWNER/pikapika/releases";
const _versionUrl =
    "https://api.github.com/repos/OWNER/pikapika/releases/latest";
const _versionAssets = 'lib/assets/version.txt';

late String _version;
String? _latestVersion;
String? _latestVersionInfo;

Future initVersion() async {
  // 当前版本
  try {
    _version = (await rootBundle.loadString(_versionAssets)).trim();
  } catch (e) {
    _version = "dirty";
  }
}

var versionEvent = Event<EventArgs>();

String currentVersion() {
  return _version;
}

String? latestVersion() {
  return _latestVersion;
}

String? latestVersionInfo() {
  return _latestVersionInfo;
}

Future autoCheckNewVersion() {
  // if (!isPro) {
  //   return Future.value();
  // }
  return _versionCheck();
}

Future manualCheckNewVersion(BuildContext context) async {
  try {
    defaultToast(context, "检查更新中");
    await _versionCheck();
    defaultToast(context, "检查更新成功");
  } catch (e) {
    defaultToast(context, "检查更新失败 : $e");
  }
}

bool dirtyVersion() {
  return "dirty" == _version;
}

// maybe exception
Future _versionCheck() async {
  if (!dirtyVersion()) {
    // 检查更新只能使用defaultHttpClient, 而不能使用pika的client, 否则会 "tls handshake failure"
    var owner =
        jsonDecode(await method.defaultHttpClientGet(repoOwnerUrl))["body"]
            .toString()
            .trim();
    var json = jsonDecode(await method
        .defaultHttpClientGet(_versionUrl.replaceAll("OWNER", owner)));
    if (json["name"] != null) {
      String latestVersion = (json["name"]);
      if (latestVersion != _version) {
        _latestVersion = latestVersion;
        _latestVersionInfo = json["body"] ?? "";
      }
    }
  } // else dirtyVersion
  versionEvent.broadcast();
}

var _display = true;

void versionPop(BuildContext context) {
  final latest = latestVersion();
  if (latest == null || !_display) {
    return;
  }

  final force = _isForceUpgrade(currentVersion(), latest);
  if (!force && ignoreUpgradeConfirm) {
    return;
  }

  _display = false;
  TopConfirm.topConfirm(
    context,
    "发现新版本",
    force ? "发现新版本 $latest，请立即更新后继续使用" : "发现新版本 $latest，建议更新",
    force: force,
    primaryText: "去下载",
    onPrimary: _openRelease,
  );
}

class _SemVer {
  final int major;
  final int minor;
  final int patch;

  const _SemVer(this.major, this.minor, this.patch);

  static _SemVer? parse(String input) {
    final m = RegExp(r'(\\d+)\\.(\\d+)\\.(\\d+)').firstMatch(input);
    if (m == null) return null;
    return _SemVer(
      int.parse(m.group(1)!),
      int.parse(m.group(2)!),
      int.parse(m.group(3)!),
    );
  }
}

bool _isForceUpgrade(String current, String latest) {
  final c = _SemVer.parse(current);
  final l = _SemVer.parse(latest);
  if (c == null || l == null) return false;

  if (l.major != c.major) return true;
  if (l.minor != c.minor) return true;
  return false;
}

Future<void> _openRelease() async {
  try {
    final owner =
        jsonDecode(await method.defaultHttpClientGet(repoOwnerUrl))["body"]
            .toString()
            .trim();
    await openUrl(_releasesUrl.replaceAll("OWNER", owner));
  } catch (_) {
    // ignore
  }
}

class TopConfirm {
  static topConfirm(BuildContext context, String title, String message,
      {bool force = false,
      String primaryText = "朕知道了",
      Future<void> Function()? onPrimary,
      Function()? afterIKnown}) {
    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(builder: (BuildContext context) {
      return LayoutBuilder(
        builder: (
          BuildContext context,
          BoxConstraints constraints,
        ) {
          var mq = MediaQuery.of(context).size.width - 30;
          return Material(
            color: Colors.transparent,
            child: Container(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(.35),
              ),
              child: Column(
                children: [
                  Expanded(child: Container()),
                  Container(
                    width: mq,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Container(height: 30),
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 28,
                          ),
                        ),
                        Container(height: 15),
                        Text(
                          message,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                        Container(height: 25),
                        MaterialButton(
                          elevation: 0,
                          color: Colors.black.withOpacity(.1),
                          onPressed: () {
                            if (onPrimary != null) {
                              onPrimary();
                            }
                            if (!force) {
                              overlayEntry.remove();
                            }
                            afterIKnown?.call();
                          },
                          child: Text(primaryText),
                        ),
                        Container(height: 30),
                      ],
                    ),
                  ),
                  Expanded(child: Container()),
                ],
              ),
            ),
          );
        },
      );
    });
    final overlay = Overlay.of(context);
    overlay.insert(overlayEntry);
  }
}
