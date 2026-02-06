import 'package:pikapika/basic/Common.dart';
import 'package:pikapika/basic/Method.dart';
import 'package:flutter/material.dart';
import 'package:pikapika/i18.dart';

const _propertyName = "gestureSpeed";

late double _gestureSpeed;

Future initGestureSpeed() async {
  _gestureSpeed = double.parse(await method.loadProperty(_propertyName, "1.0"));
}

double currentGestureSpeed() {
  return _gestureSpeed;
}

Future<void> setGestureSpeed(double value) async {
  _gestureSpeed = value;
  await method.saveProperty(_propertyName, "$value");
}

Widget gestureSpeedSetting() {
  return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
    return ListTile(
      title: Text(tr("settings.gesture_speed.title")),
      subtitle: Text("${currentGestureSpeed().toStringAsFixed(1)}x"),
      onTap: () async {
        double value = currentGestureSpeed();
        await showDialog(
          context: context,
          builder: (context) {
            return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  title: Text(tr("settings.gesture_speed.title")),
                  content: SizedBox(
                    height: 100,
                    child: Column(
                      children: [
                        Text("${value.toStringAsFixed(1)}x"),
                        Slider(
                          min: 0.1,
                          max: 5.0,
                          divisions: 49,
                          value: value,
                          onChanged: (v) {
                            setState(() {
                              value = v;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(tr("app.cancel")),
                    ),
                    TextButton(
                      onPressed: () async {
                        await setGestureSpeed(value);
                        Navigator.of(context).pop();
                      },
                      child: Text(tr("app.confirm")),
                    ),
                  ],
                );
              },
            );
          },
        );
        setState(() {});
      },
    );
  });
}
