import 'dart:convert';
import 'dart:io';

class ConvertTool {

  static Future<String> fileToString({required File file, Encoding encoding = utf8}) async{
    try {
      if (!file.existsSync()){
        throw Exception('文件不存在。');
      }

      final contents = await file.readAsString(encoding: encoding);
      return contents;
    } catch (e) {
      print('文件读取时出现错误: $e');
      rethrow;
    }
  }
}

