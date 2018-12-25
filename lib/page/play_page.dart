import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:screen/screen.dart';

class PlayPage extends StatefulWidget {
  PlayPage({Key key, @required this.title, @required this.url})
      : super(key: key);
  final String title;
  final String url;

  @override
  State<StatefulWidget> createState() {
    return _PlayPage();
  }
}

class _PlayPage extends State<PlayPage> {
  VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.url);
    Screen.keepOn(true);
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: "to_play_page",
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Builder(builder: (context) { // deBug 显示 url
//          Scaffold.of(context).showSnackBar(SnackBar(
//            content: Text(widget.url),
//          ));
          return Chewie(
            _controller,
            aspectRatio: 16 / 9,
            autoPlay: true,
            placeholder: Container(
              color: Colors.grey,
              child: Center(
                child: Text("正在努力加载中..."),
              ),
            ),
          );
        }),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
