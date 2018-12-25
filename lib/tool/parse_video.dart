import 'package:dio/dio.dart';
import 'dart:convert';

class ParseVideo {
  ParseVideo(this._url);

  static const BODY_API = "http://api.youyitv.com/lekan/oko.php?url=";
  static const LEKAN_API = "http://api.youyitv.com/lekan/api.php";

  String _body;
  final String _url;

  Dio dioInstance() {
    Options options = Options(headers: {
      "User-Agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.84 Safari/537.36",
    });

    return Dio(options);
  }

  Future<String> getVideoUrl() async {
    try {
      var pcVideoUrl = await _getPcVideoUrl();
      var md5 = await _getMd5();

      FormData formData = FormData.from({
        "id": pcVideoUrl,
        "md5": md5,
        "lg": 1
      });

      Response response = await dioInstance().post(LEKAN_API, data: formData);
      if (response.statusCode != 200) {
        throw "获取视频地址失败: " + response.toString();
      }
      Map<String, dynamic> jsonData= jsonDecode(response.data);

      if (jsonData['success'] != 1) {
        throw "获取视频地址失败: " + response.toString();
      }

      if(!jsonData['url'].toString().startsWith("http")) {
        throw "获取视频地址失败: " + response.toString();
      }
//      print(pcVideoUrl);
//      print(md5);
//      print(jsonData['url']);

      return Uri.decodeFull(jsonData['url']);
    } catch(e) {
      print("获取视频失败: " + e.toString());
      return null;
    }
  }

  Future<String> _getPcVideoUrl() async {
    var body = await _getBody();

    RegExp regExp = RegExp(
      "{\"id\": \"(.*)\",\"type",
    );

    Match matchUrl = regExp.firstMatch(body);

    if (matchUrl == null) {
      throw "没有匹配到 Pc Video Url";
    }

    return matchUrl.group(1);
  }

  Future<String> _getMd5() async {
    var body = await _getBody();

    RegExp regExp = RegExp(
      "eval\((.*)\)",
    );

    String matchString = regExp.allMatches(body).toList()[1].group(1);
    String md5Byte = matchString.substring(2, matchString.length - 3);

    List md5ByteList = md5Byte.split(r"\x")..removeAt(0);

    md5ByteList = md5ByteList.sublist(17, md5ByteList.length - 3);

    String md5String = '';
    md5ByteList.forEach((v) {
      md5String += Utf8Decoder().convert([int.parse("0x" + v)]);
    });
    return md5String;
  }

  Future<String> _getBody() async {
    if (_body != null) {
      return _body;
    }

    Dio dio = dioInstance();

    await dio.get(BODY_API + _url).then((value) {
      if (value.statusCode != 200) {
        throw "获取 Body 出错 " + value.toString();
      }
      _body = value.data;
    });

    return _body;
  }
}
