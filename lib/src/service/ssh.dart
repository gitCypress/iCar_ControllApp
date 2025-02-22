import 'dart:convert';
import 'dart:io';

import 'package:dartssh2/dartssh2.dart';
import 'package:icar/src/utils/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constant/constant_export.dart';

class SSHService {
  // 单例实例
  static final SSHService _instance = SSHService._internal();

  // 工厂构造方法，返回单例
  factory SSHService() => _instance;

  // 私有的内部构造方法
  SSHService._internal();

  SSHClient? _sshClient;
  SftpClient? _sftpClient;
  bool _isConnected = false;

  bool get isConnected => _isConnected; // 当前连接状态

  // 连接 SSH 的方法
  Future<void> connect() async {

    var prefs = await SharedPreferences.getInstance();

    if (isConnected) {
      throw Exception('SSH client is already connected.');
    }

    try {
      var host = prefs.getString(AppStrings.spKeyword.ipAddress) ?? 'localhost';
      var port =
          int.tryParse(prefs.getString(AppStrings.spKeyword.port) ?? '22') ??
              22;
      var username = prefs.getString(AppStrings.spKeyword.username) ?? 'root';
      var password = prefs.getString(AppStrings.spKeyword.password);

      // 创建 Socket，并通过密码认证连接
      final socket = await SSHSocket.connect(host, port);
      _sshClient = SSHClient(
        socket,
        username: username,
        onPasswordRequest: () => password,
      );
      _sftpClient = await _sshClient!.sftp();

      _isConnected = true;
      Tips.snackBar(AppStrings.ssh.connectSuccess);

      // 连接测试
      // final result = await _sshClient!.execute('echo "Connected to $host"');
      // print('$result~~~'); // 连接成功，输出结果
    } catch (e) {
      Tips.snackBar(AppStrings.ssh.connectFailed);
      // print('Error connecting to SSH: $e');
      rethrow;
    }
  }

  // 断开连接的方法
  Future<void> disconnect() async {
    if (!isConnected) {
      throw Exception('SSH client is not connected.');
    }

    try {
      _sshClient?.close(); // 关闭连接
      // 清理资源
      _sshClient = null;
      _sftpClient = null;
      print('SSH connection closed.');

      _isConnected = false;
      Tips.snackBar(AppStrings.ssh.disconnectSuccess);
    } catch (e) {
      print('Error disconnecting SSH: $e');
      rethrow;
    }
  }

  // 执行命令的方法
  Future<String> execute(String command) async {
    if (!isConnected) {
      throw Exception('SSH client is not connected.');
    }

    try {
      final result = await _sshClient!.run(command);
      return utf8.decode(result);
    } catch (e) {
      print('Error executing command: $e');
      rethrow;
    }
  }

  // 文件上传，不会意外创建文件
  Future<void> uploadFile(String localPath, String remotePath) async {
    // 检查启动状态
    if (_sftpClient == null) {
      throw Exception('SFTP client isn\'t initialized.');
    }

    // 读取本地文件
    final localFile = File(localPath);
    if (!await localFile.exists()) {  // 检查本地文件是否存在
      throw Exception('File[$localPath] don\'t exist.');
    }
    final lBytes = await localFile.readAsBytes();

    // 写远程文件
    final remoteFile = await _sftpClient?.open(  // 生成远程文件句柄
      localPath,
      mode: SftpFileOpenMode.write,
    );
    await remoteFile?.writeBytes(lBytes);

    await remoteFile?.close();
  }


  // 下载文件
  Future<void> downloadFile({required String? remotePath, required String localPath}) async {
    // 检查sftp服务
    if (_sftpClient == null) {
      throw Exception('SFTP client isn\'t initialized.');
    }
    if (remotePath == null){
      throw Exception('Remote path is blank!');
    }

    // 远程文件句柄，读取模式
    final remoteFile = await _sftpClient!.open(
      remotePath,
      mode: SftpFileOpenMode.read,
    );
    final rBytes = await remoteFile.readBytes();

    remoteFile.close();

    final localFile = File(localPath);
    await localFile.writeAsBytes(rBytes);
  }

  // 读取远程文件
  Future<String> getRemoteFileAsString(String? remotePath) async{
    // 检查sftp服务
    if (_sftpClient == null) {
      throw Exception('SFTP client isn\'t initialized.');
    }
    if (remotePath == null){
      throw Exception('Remote path is blank!');
    }

    // print("- [debug]: $remotePath");

    final rFile = await _sftpClient!.open(remotePath);
    final bytes = await rFile.readBytes();
    return latin1.decode(bytes);
  }
}
