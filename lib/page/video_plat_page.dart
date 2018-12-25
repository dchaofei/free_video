import 'package:flutter/material.dart';
import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';
import 'package:video/tool/parse_video.dart';
import 'play_page.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class VideoPlatPage extends StatefulWidget {
  VideoPlatPage({Key key, this.url, this.title}) : super(key: key);
  final String url;
  final String title;

  @override
  State<StatefulWidget> createState() {
    return _VideoPlatPageState();
  }
}

class _VideoPlatPageState extends State<VideoPlatPage> {
  InAppWebViewController _controller;
  double progress = 0;
  bool play = false;
  bool canPlay = false;
  bool showLoad = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[_buildCloseButton()],
      ),
      body: WillPopScope(
        onWillPop: _onWillPop,
        child: ModalProgressHUD(
          inAsyncCall: showLoad,
          child: Column(
            children: <Widget>[
              _buildProgress(),
              Builder(builder: (context) {
                return _buildWebView(context);
              }),
            ],
          ),
        ),
      ),
      floatingActionButton:
          Builder(builder: (context) => _buildPlayButton(context)),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Future<bool> _onWillPop() async {
    if (showLoad == true) {
      print("取消 load");
      _hiddenLoad();
      return false;
    } else if (await _controller.canGoBack()) {
      print("可以 goback");
      _hiddenPlayButton();
      _controller.goBack();
    } else {
      print("直接返回");
      return true;
    }
    return false;
  }

  Widget _buildProgress() {
    if (progress == 1.0) {
      return Container();
    }
    if (progress != 0) {
      return LinearProgressIndicator(
        value: progress,
      );
    }
    return Container();
  }

  bool _urlIsVideo(String url) {
    List<Map<String, String>> formats = [
      {"title": "腾讯视频", "format": "/cover/"},
      {"title": "优酷", "format": "/video/id_"},
      {"title": "爱奇艺", "format": "iqiyi.com/v_"},
      {"title": "爱奇艺", "format": "iqiyi.com/a_"},
    ];

    for (var v in formats) {
      if (url.contains(v["format"])) {
        return true;
      }
    }
    return false;
  }

  Widget _buildWebView(context) {
    return Expanded(
      child: InAppWebView(
        initialUrl: widget.url,
        initialHeaders: {
          "user-agent":
              "Mozilla/5.0 (Linux; Android 8.0.0; Pixel 2 XL Build/OPD1.170816.004) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.84 Mobile Safari/537.36"
        },
        onWebViewCreated: (InAppWebViewController controller) {
          _controller = controller;
        },
        onProgressChanged: (InAppWebViewController controller, int progress) {
          setState(() {
            this.progress = progress / 100;
          });

          if (progress > 7.0) {
            _canShowPlayButton();
          }
        },
        onLoadStart: (controller, url) {
          _hiddenPlayButton();
          if (_urlIsVideo(url)) {
            _showPlayButton();
          } else {// deBug 显示 url
//            Scaffold.of(context).showSnackBar(
//              SnackBar(content: Text(url)),
//            );
          }
        },
      ),
    );
  }

  Widget _buildCloseButton() {
    return FlatButton(
      onPressed: () {
        Navigator.of(context).pop(true);
      },
      child: Icon(
        Icons.close,
        color: Colors.white,
        semanticLabel: "关闭",
      ),
      splashColor: Theme.of(context).splashColor,
      highlightColor: Colors.transparent,
      shape: CircleBorder(),
    );
  }

  void _showPlayButton() {
    if (play) {
      return;
    }
    setState(() {
      play = true;
    });
  }

  void _hiddenPlayButton() {
    if (!play || !canPlay) {
      return;
    }
    setState(() {
      play = false;
      canPlay = false;
    });
  }

  void _canShowPlayButton() {
    if (!play) {
      return;
    }

    if (canPlay) {
      return;
    }
    setState(() {
      canPlay = true;
    });
  }

  void _showLoad() {
    setState(() {
      showLoad = true;
    });
  }

  void _hiddenLoad() {
    setState(() {
      showLoad = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _playButtonOnPressed() async {
    _showLoad();
    var url = await _controller.getUrl();
    var parse = ParseVideo(url);
    var videoUrl = await parse.getVideoUrl();
    var title = await _controller.getTitle();
    if (videoUrl != null) {
      if (showLoad == false) {
        return;
      }
      _hiddenLoad();
      if (!videoUrl.startsWith("http")) {
        Scaffold.of(context).showSnackBar(
          SnackBar(content: Text("视频地址非法格式: " + videoUrl)),
        );
        return;
      }
      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return PlayPage(
          url: videoUrl,
          title: title,
        );
      }));
    } else {
      _hiddenLoad();
      Scaffold.of(context).showSnackBar(
        SnackBar(content: Text("没有获取到视频地址: " + url)),
      );
    }
  }

  Widget _buildPlayButton(context) {
    if (!play || !canPlay) {
      return Container();
    }

    return PlayButton(onPressCallback: _playButtonOnPressed,);
  }
}

class PlayButton extends StatefulWidget {
  PlayButton({@required this.onPressCallback});

  final onPressCallback;

  @override
  State<StatefulWidget> createState() {
    return _PlayButtonState();
  }
}

class _PlayButtonState extends State<PlayButton>
    with SingleTickerProviderStateMixin {
  Animation<double> animation;
  AnimationController controller;

  @override
  void initState() {
    controller =
        AnimationController(vsync: this, duration: Duration(seconds: 5));
    animation = Tween(begin: 0.0, end: 3.0).animate(controller)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          controller.reset();
          controller.forward();
        } else if (status == AnimationStatus.dismissed) {
          controller.forward();
        }
      });
    controller.forward();

    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: animation,
      child: FloatingActionButton(
        heroTag: "to_play_page",
        child: Icon(Icons.play_circle_filled),
        onPressed: widget.onPressCallback,
      ),
    );
  }
}

