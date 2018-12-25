import 'package:flutter/material.dart';
import 'video_plat_page.dart';

class HomePage extends StatelessWidget {
  final List<Map<String, String>> _list = [
    {"title": "腾讯视频", "url": "http://m.v.qq.com/tv.html"},
    {"title": "优酷", "url": "https://tv.youku.com/"},
    {"title": "爱奇艺", "url": "http://m.iqiyi.com/vip"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('影视'),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
        ),
        itemCount: _list.length,
        itemBuilder: (BuildContext context, int index) {
          var _map = _list[index];
          return VideoPlatGrid(
            url: _map['url'],
            title: _map['title'],
          );
        },
      ),
    );
  }
}

class VideoPlatGrid extends StatelessWidget {
  VideoPlatGrid({Key key, @required this.url, @required this.title}) : super(key: key);
  final String url;
  final String title;

  void _onTap(context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return VideoPlatPage(url: url, title: title,);
    }));
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        _onTap(context);
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white),
        ),
        child: Center(
          child: Text(title),
        ),
      ),
    );
  }
}
