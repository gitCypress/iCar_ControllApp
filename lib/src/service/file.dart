import 'dart:convert';
import 'package:icar/src/service/service_export.dart';
import 'package:path/path.dart' as p;

import 'package:path_provider/path_provider.dart';


class Paths {
  static Future<String> getTempDirPath() async {
    final dir = await getTemporaryDirectory();
    return dir.path;
  }

  // example
  // windows: C:\Users\27301\AppData\Roaming\edu.emlicar.controller\icar
  // Android: /data/user/0/edu.emlicar.controller/files
  static Future<String> getAppDataPath({String joinPath = ''}) async {
    final dir = await getApplicationSupportDirectory();
    return p.join(dir.path, joinPath);
  }
}

// 管理远程和本地配置信息
class ConfigService {

}


class EntityUpperConfig {
  int speedStraight;
  int speedCurve;
  int speedBridge;
  int speedRing;

  String capAddr;
  int bufferSize;
  int capWidth;
  int capHeight;
  int capFPS;

  int imgWidth;
  int imgHeight;
  int controlLine;

  String commAddr;
  int commHeader;

  bool debugComm;
  bool debugImg;
  bool debugCamera;

  EntityUpperConfig(
      this.speedStraight,
      this.speedCurve,
      this.speedBridge,
      this.speedRing,
      this.capAddr,
      this.bufferSize,
      this.capWidth,
      this.capHeight,
      this.capFPS,
      this.imgWidth,
      this.imgHeight,
      this.controlLine,
      this.commAddr,
      this.commHeader,
      this.debugComm,
      this.debugImg,
      this.debugCamera);

  factory EntityUpperConfig.fromJsonString(String jsonString) {
    final Map<String, dynamic> jMap = jsonDecode(jsonString);
    return EntityUpperConfig(
        jMap["speedStraight"],
        jMap["speedCurve"],
        jMap["speedBridge"],
        jMap["speedRing"],
        jMap["capAddr"],
        jMap["bufferSize"],
        jMap["capWidth"],
        jMap["capHeight"],
        jMap["capFPS"],
        jMap["imgWidth"],
        jMap["imgHeight"],
        jMap["controlLine"],
        jMap["commAddr"],
        jMap["commHeader"],
        jMap["debugComm"],
        jMap["debugImg"],
        jMap["debugCamera"]);
  }
}
