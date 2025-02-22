import '../ui/ui_export.dart';
import '../constant/constant_export.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MaterialApplication extends StatelessWidget {
  const MaterialApplication({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
      ),
      home: Navigation(),
      navigatorKey: navigatorKey,
    );
  }
}

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int currentPageIndex = 0; // 导航栏当前指向页面下标

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context); // 获取当前主题数据（热重载重置）

    return Scaffold(
      appBar: AppBar(
        title: Text(switch (currentPageIndex) {
          0 => AppStrings.basic.appName,
          1 => AppStrings.navigation.configurePage,
          2 => AppStrings.navigation.settingsPage,
          _ => "Undefined PageIndex",
        }),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: null,
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        // 标签被选择时执行的操作
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: theme.colorScheme.primary,
        // 指定被选定的标签
        selectedIndex: currentPageIndex,
        // 标签
        destinations: <Widget>[
          NavigationDestination(
              selectedIcon: Icon(
                Icons.home,
                color: theme.colorScheme.onPrimary,
              ),
              icon: Icon(
                Icons.home_outlined,
                color: theme.colorScheme.primary,
              ),
              label: AppStrings.navigation.homePage),
          NavigationDestination(
            selectedIcon: Icon(
              Icons.tune,
              color: theme.colorScheme.onPrimary,
            ),
            icon: Icon(
              Icons.tune_outlined,
              color: theme.colorScheme.primary,
            ),
            label: AppStrings.navigation.configurePage,
          ),
          NavigationDestination(
            selectedIcon: Icon(
              Icons.settings,
              color: theme.colorScheme.onPrimary,
            ),
            icon: Icon(
              Icons.settings_outlined,
              color: theme.colorScheme.primary,
            ),
            label: AppStrings.navigation.settingsPage,
          ),
        ],
      ),
      body: IndexedStack(
        index: currentPageIndex,
        children: [
          HomePage(),
          ConfigurePage(),
          SettingsPage(),
        ],
      ),
      // 这里两个中括号，前面的是列表，后面的是列表索引，这样获取的就是其中的一个页面
    );
  }
}
