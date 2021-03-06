import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import 'model/product.dart';
import 'login.dart';

const double _kFlingVelocity = 2.0;

class Backdrop extends StatefulWidget {
  final Category currentCategory;
  final Widget frontLayer;
  final Widget backLayer;
  final Widget frontTitle;
  final Widget backTitle;

  Backdrop({
    @required this.currentCategory,
    @required this.frontLayer,
    @required this.backLayer,
    @required this.frontTitle,
    @required this.backTitle,
  })  : assert(currentCategory != null),
        assert(frontLayer != null),
        assert(backLayer != null),
        assert(frontTitle != null),
        assert(backTitle != null);

  @override
  _BackdropState createState() => _BackdropState();
}

class _BackdropState extends State<Backdrop>
    with SingleTickerProviderStateMixin {
  final GlobalKey _backdropKey = GlobalKey(debugLabel: 'Backdrop');
  AnimationController _controller;

  @override
  Widget build(BuildContext context) {
    var appBar = AppBar(
      brightness: Brightness.light,
      elevation: 0,
      titleSpacing: 0,
      title: _BackdropTitle(
        listenable: _controller.view,
        onPress: _toggleBackdropLayerVisibility,
        frontTitle: widget.frontTitle,
        backTitle: widget.backTitle,
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(
            Icons.search,
            semanticLabel: 'login',
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (BuildContext context) => LoginPage()),
            );
          },
        ),
        IconButton(
          icon: Icon(
            Icons.tune,
            semanticLabel: 'login',
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (BuildContext context) => LoginPage()),
            );
          },
        )
      ],
    );
    return Scaffold(
      appBar: appBar,
      // LayoutBuilder是一个特殊Widget，其builder回调提供了大小约束。
      // 当Widget必须知道其父Widget的大小以便自行布局（并且父Widget大小不依赖于子Widget）时，使用LayoutBuilder
      body: LayoutBuilder(
        builder: _buildStack,
      ),
    );
  }

  Widget _buildStack(BuildContext context, BoxConstraints constraints) {
    const double layerTitleHeight = 48;
    final Size layerSize = constraints.biggest;
    final double layerTop = layerSize.height - layerTitleHeight;
    Animation<RelativeRect> layerAnimation = RelativeRectTween(
      begin: RelativeRect.fromLTRB(0, layerTop, 0, layerTop - layerSize.height),
      end: RelativeRect.fromLTRB(0, 0, 0, 0),
    ).animate(_controller.view);

    return Stack(
      key: _backdropKey,
      children: <Widget>[
        // 当backLayer不可见时，ExcludeSemantics会从语义树中排除backLayer
        ExcludeSemantics(
          child: widget.backLayer,
          excluding: _frontLayerVisible,
        ),
        PositionedTransition(
          rect: layerAnimation,
          child: _FrontLayer(
            onTap: _toggleBackdropLayerVisibility,
            child: widget.frontLayer,
          ),
        ),
      ],
    );
  }

  // 仅被调用一次
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      value: 1,
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _frontLayerVisible {
    final AnimationStatus status = _controller.status;
    return status == AnimationStatus.completed ||
        status == AnimationStatus.forward;
  }

  void _toggleBackdropLayerVisibility() {
    _controller.fling(
      velocity: _frontLayerVisible ? -_kFlingVelocity : _kFlingVelocity,
    );
  }

  @override
  void didUpdateWidget(Backdrop oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentCategory != oldWidget.currentCategory) {
      _toggleBackdropLayerVisibility();
    } else if (!_frontLayerVisible) {
      _controller.fling(velocity: _kFlingVelocity);
    }
  }
}

class _FrontLayer extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;

  _FrontLayer({
    Key key,
    this.onTap,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 16,
      shape: BeveledRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(46)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: Container(
              height: 40,
              alignment: AlignmentDirectional.centerStart,
            ),
          ),
          Expanded(
            child: child,
          )
        ],
      ),
    );
  }
}

class _BackdropTitle extends AnimatedWidget {
  final Function onPress;
  final Widget frontTitle;
  final Widget backTitle;

  const _BackdropTitle({
    Key key,
    Listenable listenable,
    this.onPress,
    @required this.frontTitle,
    @required this.backTitle,
  })  : assert(frontTitle != null),
        assert(backTitle != null),
        super(key: key, listenable: listenable);

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = this.listenable;
    return DefaultTextStyle(
      style: Theme.of(context).primaryTextTheme.title,
      softWrap: false,
      overflow: TextOverflow.ellipsis,
      child: Row(
        children: <Widget>[
          // branded icon
          SizedBox(
            width: 72,
            child: IconButton(
              padding: EdgeInsets.only(right: 8),
              onPressed: onPress,
              icon: Stack(
                children: <Widget>[
                  Opacity(
                    opacity: animation.value,
                    child: ImageIcon(AssetImage('assets/slanted_menu.png')),
                  ),
                  FractionalTranslation(
                    translation: Tween(
                      begin: Offset.zero,
                      end: Offset(1, 0),
                    ).evaluate(animation),
                    child: ImageIcon(AssetImage('assets/diamond.png')),
                  )
                ],
              ),
            ),
          ),
          // Here, we do a custom cross fade between backTitle and frontTitle.
          // This makes a smooth animation between the two texts.
          Stack(
            children: <Widget>[
              Opacity(
                opacity: CurvedAnimation(
                  parent: ReverseAnimation(animation),
                  curve: Interval(0.5, 1),
                ).value,
                child: FractionalTranslation(
                  translation: Tween(
                    begin: Offset.zero,
                    end: Offset(0.5, 0),
                  ).evaluate(animation),
                  child: Semantics(
                    label: 'hide categories menu',
                    child: ExcludeSemantics(child: backTitle),
                  ),
                ),
              ),
              Opacity(
                opacity: CurvedAnimation(
                  parent: animation,
                  curve: Interval(0.5, 1),
                ).value,
                child: FractionalTranslation(
                  translation: Tween(
                    begin: Offset(-0.25, 0),
                    end: Offset.zero,
                  ).evaluate(animation),
                  child: Semantics(
                    label: 'show categories menu',
                    child: ExcludeSemantics(child: frontTitle),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
