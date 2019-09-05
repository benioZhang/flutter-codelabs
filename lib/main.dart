import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'animation/animation_tutorial.dart';
import 'animation/hero_animations.dart';
import 'baby_names.dart';
import 'cupertino_store/app.dart';
import 'cupertino_store/app_state_model.dart';
import 'first_dart_app.dart';
import 'friendlychat.dart';
import 'shrine/app.dart';

// https://flutter.dev/docs/codelabs
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Codelabs',
      home: HomePage(title: 'Codelabs'),
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}

class Codelab {
  final title;
  final widget;

  Codelab(this.title, this.widget);
}

class HomePage extends StatelessWidget {
  final codelabs = [
    Codelab('Write Your First Flutter App', FirstDartApp()),
    Codelab('Building Beautiful UIs with Flutter', FriendlyChatApp()),
    Codelab('Firebase for Flutter', BabyNamesApp()),
    Codelab('MDC 101~104 Flutter', ShrineApp()),
    Codelab(
        'Building a Cupertino app with Flutter',
        ChangeNotifierProvider<AppStateModel>(
          builder: (context) => AppStateModel()..loadProducts(),
          child: CupertinoStoreApp(),
        )),
    Codelab('Animation Tutorial', AnimationTutorial()),
    Codelab('Hero Animations', HeroAnimationDemo()),
  ];
  final String title;
  final _biggerFont = const TextStyle(fontSize: 18);

  HomePage({Key key, this.title});

  @override
  Widget build(BuildContext context) {
    final tiles = codelabs.map((lab) {
      return ListTile(
        title: Text(
          lab.title,
          style: _biggerFont,
        ),
        onTap: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (BuildContext context) {
            return lab.widget;
          }));
        },
      );
    });

    final divided = ListTile.divideTiles(
      tiles: tiles,
      context: context,
    ).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(this.title),
      ),
      body: ListView(
        children: divided,
      ),
    );
  }
}
