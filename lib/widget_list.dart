import 'package:flutter/material.dart';

class WidgetList extends StatelessWidget {
  final List<Widget> widgets;
  final String title;

  const WidgetList({Key key, @required this.widgets, @required this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var tiles = widgets
        .map((e) => ListTile(
              title: Text(e.toStringShort()),
              onTap: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (BuildContext context) {
                  return e;
                }));
              },
            ))
        .toList();
    final divided = ListTile.divideTiles(
      tiles: tiles,
      context: context,
    ).toList();
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: ListView(
          children: divided,
        ));
  }
}
