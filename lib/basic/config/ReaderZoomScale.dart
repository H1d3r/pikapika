import 'package:flutter/material.dart';
import 'package:pikapika/i18.dart';

import '../Method.dart';

const _readerZoomMinPropertyName = "readerZoomMinScale";
const _readerZoomMaxPropertyName = "readerZoomMaxScale";
const _readerZoomDoubleTapPropertyName = "readerZoomDoubleTapScale";

late double _readerZoomMinScale;
late double _readerZoomMaxScale;
late double _readerZoomDoubleTapScale;

double get readerZoomMinScale => _readerZoomMinScale;
double get readerZoomMaxScale => _readerZoomMaxScale;
double get readerZoomDoubleTapScale => _readerZoomDoubleTapScale;

Future<void> setReaderZoomMinScale(double value) async {
  _readerZoomMinScale = value;
  await method.saveProperty(
    _readerZoomMinPropertyName,
    value.toStringAsFixed(1),
  );
}

Future<void> setReaderZoomMaxScale(double value) async {
  _readerZoomMaxScale = value;
  await method.saveProperty(
    _readerZoomMaxPropertyName,
    value.toStringAsFixed(1),
  );
}

Future<void> setReaderZoomDoubleTapScale(double value) async {
  _readerZoomDoubleTapScale = value;
  await method.saveProperty(
    _readerZoomDoubleTapPropertyName,
    value.toStringAsFixed(1),
  );
}

Future<void> initReaderZoomScale() async {
  _readerZoomMinScale =
      double.tryParse(await method.loadProperty(_readerZoomMinPropertyName, "1.0")) ??
          1.0;
  _readerZoomMaxScale =
      double.tryParse(await method.loadProperty(_readerZoomMaxPropertyName, "2.0")) ??
          2.0;
  _readerZoomDoubleTapScale =
      double.tryParse(await method.loadProperty(_readerZoomDoubleTapPropertyName, "2.0")) ??
          2.0;
}

Widget readerZoomMinScaleSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return ListTile(
        title: Text(
          "${tr("settings.reader_zoom.out_title")} : ${_readerZoomMinScale.toStringAsFixed(1)}x",
        ),
        subtitle: Slider(
          min: 0.1,
          max: 1.0,
          divisions: 9,
          value: _readerZoomMinScale.clamp(0.1, 1.0).toDouble(),
          label: "${_readerZoomMinScale.toStringAsFixed(1)}x",
          onChanged: (double value) {
            final newValue = (value * 10).roundToDouble() / 10;
            setState(() {
              _readerZoomMinScale = newValue;
            });
            setReaderZoomMinScale(newValue);
          },
        ),
      );
    },
  );
}

Widget readerZoomMaxScaleSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return ListTile(
        title: Text(
          "${tr("settings.reader_zoom.in_title")} : ${_readerZoomMaxScale.toStringAsFixed(1)}x",
        ),
        subtitle: Slider(
          min: 1.0,
          max: 30.0,
          divisions: 29,
          value: _readerZoomMaxScale.clamp(1.0, 30.0).toDouble(),
          label: "${_readerZoomMaxScale.toStringAsFixed(1)}x",
          onChanged: (double value) {
            final newValue = value.roundToDouble();
            setState(() {
              _readerZoomMaxScale = newValue;
            });
            setReaderZoomMaxScale(newValue);
          },
        ),
      );
    },
  );
}

Widget readerZoomDoubleTapScaleSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return ListTile(
        title: Text(
          "${tr("settings.reader_zoom.double_tap_title")} : ${_readerZoomDoubleTapScale.toStringAsFixed(1)}x",
        ),
        subtitle: Slider(
          min: 1.5,
          max: 5.0,
          divisions: 7,
          value: _readerZoomDoubleTapScale.clamp(1.5, 5.0).toDouble(),
          label: "${_readerZoomDoubleTapScale.toStringAsFixed(1)}x",
          onChanged: (double value) {
            final newValue = (value * 2).roundToDouble() / 2;
            setState(() {
              _readerZoomDoubleTapScale = newValue;
            });
            setReaderZoomDoubleTapScale(newValue);
          },
        ),
      );
    },
  );
}
