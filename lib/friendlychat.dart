import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// https://codelabs.developers.google.com/codelabs/flutter

final ThemeData kIOSTheme = ThemeData(
  primarySwatch: Colors.green,
  primaryColor: Colors.grey[100],
  primaryColorBrightness: Brightness.light,
);
final ThemeData kDefaultTheme = ThemeData(
  primarySwatch: Colors.purple,
  accentColor: Colors.orangeAccent[400],
);

class FriendlyChatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Friendlychat',
      theme: defaultTargetPlatform == TargetPlatform.iOS
          ? kIOSTheme
          : kDefaultTheme,
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen>
    with TickerProviderStateMixin<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isComposing = false;

  @override
  void dispose() {
    for (ChatMessage msg in _messages) {
      msg.animationController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Friendlychat'),
        elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0 : 4,
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Flexible(
              child: ListView.builder(
                itemBuilder: (context, index) => _messages[index],
                padding: const EdgeInsets.all(8),
                reverse: true,
                itemCount: _messages.length,
              ),
            ),
            Divider(
              height: 1,
            ),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
              ),
              child: _buildTextComposer(),
            ),
          ],
        ),
        decoration: Theme.of(context).platform == TargetPlatform.iOS
            ? BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey[200]),
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildTextComposer() {
    return IconTheme(
        data: IconThemeData(
          color: Theme.of(context).accentColor,
        ),
        child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: <Widget>[
                Flexible(
                    child: TextField(
                  controller: _textController,
                  onChanged: (String text) {
                    setState(() => _isComposing = text.length > 0);
                  },
                  onSubmitted: _handleSubmitted,
                  decoration: InputDecoration.collapsed(
                    hintText: 'Send a message',
                  ),
                )),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: Theme.of(context).platform == TargetPlatform.iOS
                      ? CupertinoButton(
                          child: Text('Send'),
                          onPressed: _isComposing
                              ? () => _handleSubmitted(_textController.text)
                              : null,
                        )
                      : IconButton(
                          icon: Icon(Icons.send),
                          onPressed: _isComposing
                              ? () => _handleSubmitted(_textController.text)
                              : null, // onPressed 为 null，IconButton不可点击
                        ),
                ),
              ],
            )));
  }

  void _handleSubmitted(String text) {
    _textController.clear();
    setState(() => _isComposing = false);
    var message = ChatMessage(
      text: text,
      animationController: AnimationController(
        duration: Duration(milliseconds: 600),
        vsync: this,
      ),
    );
    setState(() {
      _messages.insert(0, message);
    });
    message.animationController.forward();
  }
}

const String _name = "Benio";

class ChatMessage extends StatelessWidget {
  final String text;
  final AnimationController animationController;

  ChatMessage({this.text, this.animationController});

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: CurvedAnimation(
        parent: animationController,
        curve: Curves.easeOut,
      ),
      axisAlignment: 0,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(right: 16),
              child: CircleAvatar(
                child: Text(_name[0]),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    _name,
                    style: Theme.of(context).textTheme.subhead,
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 5),
                    child: Text(text),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
