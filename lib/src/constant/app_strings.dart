class AppStrings {
  static const basic = (appName: 'iCar',);

  static const navigation = (
    homePage: '主页',
    configurePage: '配置',
    settingsPage: '设置',
  );

  static const homePage = (
    carDisconnect: '未连接车辆',
    carConnected: '已连接车辆',
    whenDisconnectPrompt: '点击右侧连接车辆',
  );

  static const configurePage = (
    deviceNotConnect: '未连接车辆',
    noLocalConfig: '尚未加载过配置',
    load: '加载',
    upload: '上载',
    sync: '手动同步',
  );

  static const settingsPage = (
    connectionConfigure: '连接配置',
    settingSaved: '设置已保存',
    upperMonitorIP: '上位机IP',
    port: 'SSH端口号',
    username: '用户名',
    password: '用户密码',
    configJsonPath: '配置文件路径',
    save: '保存',
  );

  static const spKeyword = (
    ipAddress: 'ipAddress',
    port: 'port',
    username: 'username',
    password: 'password',
    configJSONPath: 'config_json_path',
  );

  static const ssh = (
    connectFailed: '连接失败，检查网络、设备或配置',
    connectSuccess: '已连接',
    disconnectSuccess: '已断开连接',
    connect: '连接',
    disconnect: '断连',
  );
}
