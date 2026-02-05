/// 屏蔽的分类

import 'dart:convert';

import 'package:pikapika/i18.dart';
import 'package:flutter/material.dart';

import '../Method.dart';
import '../store/Categories.dart';
import 'ShadowCategoriesEvent.dart';

const _propertyName = "shadowCategories";
late List<String> shadowCategories;

/// 获取封印的类型
Future<List<String>> _loadShadowCategories() async {
  var value = await method.loadProperty(_propertyName, jsonEncode(<String>[]));
  return List.of(jsonDecode(value)).map((e) => "$e").toList();
}

/// 保存封印的类型
Future<dynamic> _saveShadowCategories(List<String> value) {
  return method.saveProperty(_propertyName, jsonEncode(value));
}

Future<void> initShadowCategories() async {
  shadowCategories = await _loadShadowCategories();
}

Future<void> _chooseShadowCategories(BuildContext context) async {
  final theme = Theme.of(context);
  final result = await showDialog<List<String>>(
    context: context,
    builder: (ctx) => _ShadowCategoriesDialog(
      theme: theme,
      items: storedCategories,
      initialValue: shadowCategories,
    ),
  );
  if (result != null) {
    await _saveShadowCategories(result);
    shadowCategories = result;
    shadowCategoriesEvent.broadcast();
  }
}

Widget shadowCategoriesActionButton(BuildContext context) {
  return IconButton(
    onPressed: () {
      _chooseShadowCategories(context);
    },
    icon: const Icon(Icons.hide_source),
  );
}

Widget shadowCategoriesSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return ListTile(
        title: Text(tr("settings.shadow_categories.title")),
        subtitle: Text(jsonEncode(shadowCategories)),
        onTap: () async {
          await _chooseShadowCategories(context);
          setState(() {});
        },
      );
    },
  );
}

const chooseShadowCategories = _chooseShadowCategories;

class _ShadowCategoriesDialog extends StatefulWidget {
  final ThemeData theme;
  final List<String> items;
  final List<String> initialValue;

  const _ShadowCategoriesDialog({
    required this.theme,
    required this.items,
    required this.initialValue,
  });

  @override
  State<_ShadowCategoriesDialog> createState() => _ShadowCategoriesDialogState();
}

class _ShadowCategoriesDialogState extends State<_ShadowCategoriesDialog> {
  late final Set<String> _selected = {...widget.initialValue};
  String _query = "";

  @override
  Widget build(BuildContext context) {
    final visibleItems = widget.items
        .where((e) => _query.isEmpty || e.toLowerCase().contains(_query))
        .toList();

    return AlertDialog(
      backgroundColor: widget.theme.scaffoldBackgroundColor,
      title: Text(tr("settings.shadow_categories.title")),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: tr("settings.shadow_categories.search_hint"),
              ),
              onChanged: (v) {
                setState(() {
                  _query = v.trim().toLowerCase();
                });
              },
            ),
            const SizedBox(height: 12),
            Flexible(
              child: Scrollbar(
                thumbVisibility: true,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: visibleItems.length,
                  itemBuilder: (ctx, index) {
                    final item = visibleItems[index];
                    final checked = _selected.contains(item);
                    return CheckboxListTile(
                      value: checked,
                      dense: true,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Text(item, style: widget.theme.textTheme.bodyMedium),
                      activeColor: widget.theme.primaryColor,
                      onChanged: (v) {
                        setState(() {
                          if (v == true) {
                            _selected.add(item);
                          } else {
                            _selected.remove(item);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(tr("app.cancel")),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_selected.toList()),
          child: Text(tr("app.confirm")),
        ),
      ],
    );
  }
}
