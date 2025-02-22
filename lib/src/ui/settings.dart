import 'package:icar/src/constant/app_strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ui_export.dart';
import '../utils/utils_export.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ConnectionCard(),
      ],
    );
  }
}

class ConnectionCard extends StatefulWidget {
  const ConnectionCard({super.key});

  @override
  State<ConnectionCard> createState() => _ConnectionCardState();
}

class _ConnectionCardState extends State<ConnectionCard> {
  final _ipController = TextEditingController();
  final _portController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _jsonPathController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _ipController.dispose();
    _portController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _jsonPathController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    var prefs = await SharedPreferences.getInstance();

    setState(() {
      _ipController.text =
          prefs.getString(AppStrings.spKeyword.ipAddress) ?? '';
      _portController.text = prefs.getString(AppStrings.spKeyword.port) ?? '';
      _usernameController.text =
          prefs.getString(AppStrings.spKeyword.username) ?? '';
      _passwordController.text =
          prefs.getString(AppStrings.spKeyword.password) ?? '';
      _jsonPathController.text =
          prefs.getString(AppStrings.spKeyword.configJSONPath) ?? '';
    });
  }

  Future<void> _saveSettings() async {
    var prefs = await SharedPreferences.getInstance();

    await prefs.setString(AppStrings.spKeyword.ipAddress, _ipController.text);
    await prefs.setString(AppStrings.spKeyword.port, _portController.text);
    await prefs.setString(
        AppStrings.spKeyword.username, _usernameController.text);
    await prefs.setString(
        AppStrings.spKeyword.password, _passwordController.text);
    await prefs.setString(
        AppStrings.spKeyword.configJSONPath, _jsonPathController.text);

    Tips.snackBar(AppStrings.settingsPage.settingSaved);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Card(
            color: colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.settingsPage.connectionConfigure,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Divider(
                    color: Colors.grey,
                    thickness: 1,
                    indent: 8,
                    endIndent: 8,
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _ipController,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: AppStrings.settingsPage.upperMonitorIP),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _portController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: AppStrings.settingsPage.port),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: AppStrings.settingsPage.username),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: AppStrings.settingsPage.password),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _jsonPathController,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: AppStrings.settingsPage.configJsonPath),
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                      onPressed: _saveSettings,
                      child: Text(AppStrings.settingsPage.save))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
