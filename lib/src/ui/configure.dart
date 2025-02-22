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
  final _formKey = GlobalKey<FormState>();
  final testController = TextEditingController();
  final Map<String, TextEditingController> _configTextControllers =
      {}; // 输入框控制器，对应Keys
  Map<String, dynamic>? _configAsMap; // 配置信息
  List<String>? _configAsMapKeys; // 配置信息Map的键列表，相当于通过映射用下标访问。

  @override
  void initState() {
    super.initState();
    // 初始化时根据配置解析加载UI，有就加载，没有就空白页
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

  // 清理配置并加载，并设置文本的控制器。已连接使用远程，未连接使用本地
  void loadConfig() async {
    Map<String, dynamic>? configAsMap;

    if (sshService.isConnected) {
      configAsMap = await _getConfigFromRemote();
    } else {
      configAsMap = await _getConfigFromLocal();
    }

    // 不为空时进一步处理
    if (configAsMap != null) {
      configAsMap.remove('record'); // 清理注释项
      setState(() {
        _configAsMap = configAsMap; // 载入配置
        _configAsMapKeys = _configAsMap!.keys.toList(); // 下标映射
      });
      setTextFieldWithConfig();
    }
  }

  void setTextFieldWithConfig() {
    for (var key in _configAsMapKeys!) {
      // 配置控制器并同步当前值
      _configTextControllers[key] = TextEditingController();
      if (sshService.isConnected) {
        _configTextControllers[key]!.text = _configAsMap![key].toString();
      }
    }
  }

  @override
  void dispose() {
    testController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    setTextFieldWithConfig();

    return (_configAsMap != null)
        ? Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: GridView.builder(
                    shrinkWrap: true,
                    itemCount: _configAsMap!.length,
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
                      final String key = _configAsMapKeys![index];
                      return TextFormField(
                        controller: _configTextControllers[key],
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
                        // 此处必定远程加载并有配置
                        onPressed: sshService.isConnected ? loadConfig : null,
                        child: Text(AppStrings.configurePage.sync),
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
              Text(
                '🧐',
                style: TextStyle(fontSize: 180),
              ),
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
