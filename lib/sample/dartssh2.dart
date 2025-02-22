import 'package:dartssh2/dartssh2.dart';

Future<void> main() async {
  final client = SSHClient(
    await SSHSocket.connect('62.234.217.104', 29371),
    username: 'test',
    onPasswordRequest: () => 'test',
  );

  // shell
  // final shell = await client.shell();
  // stdout.addStream(shell.stdout);
  // stderr.addStream(shell.stderr);
  //
  // await shell.done;
  // client.close();

  // command
  // try {
  //   final result = await client.run('sudo apt update');
  //   print('Command output: ${String.fromCharCodes(result)}');
  // } on SocketException catch (e) {
  //   print('连接失败，设备可能未启动。');
  // } finally {
  //   client.close();
  // }

  final sftp = await client.sftp();
  final items = await sftp.listdir('/home/test');
  for (final item in items){
    print(item.filename);
  }
  client.close();
}
