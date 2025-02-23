import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;

import 'package:icar/src/constant/app_strings.dart';
import 'package:icar/src/utils/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../service/service_export.dart';
import 'ui_export.dart';
import '../constant/constant_export.dart';

final sshService = SSHService();

class ConfigurePage extends StatefulWidget {
  const ConfigurePage({super.key});

  @override
  State<ConfigurePage> createState() => _ConfigurePageState();
}

class _ConfigurePageState extends State<ConfigurePage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        (!sshService.isConnected)
            ? DeviceDisconnectError(
                onConnected: () => setState(() {}),
              )
            : SizedBox(
                height: 0,
              ),
        Expanded(
          child: Center(
            child: ConfigureForm(),
          ),
        ),
      ],
    );
  }
}

class DeviceDisconnectError extends StatefulWidget {
  const DeviceDisconnectError({super.key, required this.onConnected});

  final VoidCallback onConnected;

  @override
  State<DeviceDisconnectError> createState() => _DeviceDisconnectErrorState();
}

class _DeviceDisconnectErrorState extends State<DeviceDisconnectError> {
  bool isConnecting = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return MaterialBanner(
      padding: EdgeInsets.symmetric(horizontal: 16),
      content: Text(
        AppStrings.configurePage.deviceNotConnect,
        style: TextStyle(color: colorScheme.onErrorContainer),
      ),
      leading: Icon(Icons.directions_car),
      backgroundColor: colorScheme.errorContainer,
      actions: [
        isConnecting
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  color: colorScheme.primary,
                  strokeWidth: 3,
                ),
              )
            : TextButton(
                onPressed: () async {
                  setState(() {
                    isConnecting = true;
                  });

                  try {
                    await sshService.connect();
                  } catch (e) {
                    print('[configure] connecting error!');
                  } finally {
                    setState(() {
                      isConnecting = false;
                    });
                    widget.onConnected();
                  }
                },
                child: Text(AppStrings.ssh.connect),
              )
      ],
    );
  }
}

class ConfigureForm extends StatefulWidget {
  const ConfigureForm({super.key});

  @override
  State<ConfigureForm> createState() => _ConfigureFormState();
}

class _ConfigureFormState extends State<ConfigureForm> {
  final _formGlobalKey = GlobalKey<FormState>();

  // 输入框控制器，对应Keys
  final Map<String, TextEditingController> _formTextControllers = {};

  // 配置信息
  Map<String, dynamic>? _config;

  // 配置信息Map的键列表，相当于通过映射用下标访问。
  List<String>? _configKeys;

  // 本地、远程配置信息一致性
  bool isConsistentConfig = false;

  @override
  void initState() {
    super.initState();
    // TODO: 初始化应当只从本地加载配置
    loadConfig();
  }

  // 读取远程配置，并更新本地文件
  Future<Map<String, dynamic>> _getConfigFromRemote() async {
    var prefs = await SharedPreferences.getInstance();
    var cfgLocalPath = await Paths.getAppDataPath(joinPath: 'config.json');
    var cfgRemotePath = prefs.getString(AppStrings.spKeyword.configJSONPath);

    // 读取远程配置
    String contents = await sshService.getRemoteFileAsString(cfgRemotePath);

    // 异步保存到本地
    final localFile = File(cfgLocalPath);
    localFile.writeAsString(contents); // 不写 await 就是异步的

    return json.decode(contents);
  }

  // 读取本地配置，在这里处理本地文件标志
  Future<Map<String, dynamic>?> _getConfigFromLocal() async {
    var cfgLocalPath = await Paths.getAppDataPath(joinPath: 'config.json');

    try {
      final file = File(cfgLocalPath);
      final contents = await file.readAsString();
      return json.decode(contents);
    } catch (e) {
      // 本地没有这个文件
      return null;
    }
  }

  void downloadConfig(){

  }

  // 清理配置并加载，并设置文本的控制器。已连接使用远程，未连接使用本地
  void loadConfig() async {
    Map<String, dynamic>? configAsMap;

    if (sshService.isConnected) {
      configAsMap = await _getConfigFromRemote();
    } else {
      configAsMap = await _getConfigFromLocal();
    }

    // TODO: loadConfig 应当只负责加载本地的配置
    // configAsMap = await _getConfigFromLocal();

    // 不为空时进一步处理
    if (configAsMap != null) {
      configAsMap.remove('record'); // 清理注释项
      setState(() {
        _config = configAsMap; // 载入配置
        _configKeys = _config!.keys.toList(); // 下标映射
        _configKeys!.sort((String a, String b) => a.compareTo(b));
      });
      setTextFieldWithConfig();
    }
  }

  // 上载配置，此时一定是不为空也联网的
  void uploadConfig() {
    Map<String, dynamic> configMap = {};
    for (var i in _configKeys!) {}
  }

  void setTextFieldWithConfig() {
    if (_configKeys != null) {
      for (var key in _configKeys!) {
        // 配置控制器并同步当前值
        _formTextControllers[key] = TextEditingController();
        if (sshService.isConnected) {
          _formTextControllers[key]!.text = _config![key].toString();
        }
      }
    }
  }

  // 远程和本地内容的一致性检查
  void check() {}

  @override
  void dispose() {
    for (var key in _configKeys!) {
      _formTextControllers[key]!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // setTextFieldWithConfig();
    return (_config != null)
        ? Form(
            key: _formGlobalKey,
            child: Column(
              children: [
                Expanded(
                  child: GridView.builder(
                    shrinkWrap: true,
                    itemCount: _config!.length,
                    physics: ClampingScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 16,
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisExtent: 70,
                      crossAxisSpacing: 20,
                      childAspectRatio: 1.2,
                    ),
                    itemBuilder: (context, index) {
                      final String key = _configKeys![index];
                      return TextFormField(
                        controller: _formTextControllers[key],
                        enabled: sshService.isConnected,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: key,
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FilledButton.tonal(
                        // TODO：这里
                        onPressed:
                            sshService.isConnected ? loadConfig : null,
                        child: Text(AppStrings.configurePage.recovery),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      FilledButton(
                        // TODO
                        onPressed: sshService.isConnected ? null : null,
                        child: Text(AppStrings.configurePage.upload),
                      ),
                    ],
                  ),
                )
                // 没有历史配置就加载空页面
              ],
            ),
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(AppStrings.configurePage.noLocalConfig,
                  style: TextStyle(fontSize: 20)),
              SizedBox(
                height: 40,
              ),
              ElevatedButton(
                  onPressed: sshService.isConnected ? loadConfig : null,
                  // 此处必定远程加载
                  child: Text(AppStrings.configurePage.load)),
            ],
          );
  }
}
