import 'package:flutter/material.dart';
import 'package:pikapika/i18.dart';

import '../Method.dart';

const _readerZoomMinPropertyName = "readerZoomMinScale";
const _readerZoomMaxPropertyName = "readerZoomMaxScale";

late double _readerZoomMinScale;
late double _readerZoomMaxScale;

double get readerZoomMinScale => _readerZoomMinScale;
double get readerZoomMaxScale => _readerZoomMaxScale;

Future<void> initReaderZoomScale() async {
  _readerZoomMinScale =
      double.tryParse(await method.loadProperty(_readerZoomMinPropertyName, "0.1")) ??
          0.1;
  _readerZoomMaxScale =
      double.tryParse(await method.loadProperty(_readerZoomMaxPropertyName, "2.0")) ??
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
            method.saveProperty(
              _readerZoomMinPropertyName,
              newValue.toStringAsFixed(1),
            );
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
            method.saveProperty(
              _readerZoomMaxPropertyName,
              newValue.toStringAsFixed(1),
            );
          },
        ),
      );
    },
  );
}
