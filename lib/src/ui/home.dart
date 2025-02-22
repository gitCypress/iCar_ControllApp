import 'package:shared_preferences/shared_preferences.dart';

import 'ui_export.dart';
import '../constant/constant_export.dart';
import '../service/service_export.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StatusCard(),
      ],
    );
  }
}


class StatusCard extends StatefulWidget {
  const StatusCard({super.key});

  @override
  State<StatusCard> createState() => _StatusCardState();
}

class _StatusCardState extends State<StatusCard> {
  final sshService = SSHService();
  var isConnecting = false;
  String sshInfo = '';

  @override
  void initState() {
    setSSHInfo();
    super.initState();
  }

  Future<void> toggleConnection() async {
    setState(() {
      isConnecting = true;
    });

    if (sshService.isConnected) {
      await sshService.disconnect();
      setState(() {
        isConnecting = false;
      });
    } else {
      try {
        await sshService.connect();
      } catch (e) {
        if (sshService.isConnected) {
          await sshService.disconnect();
        }
      } finally {
        setState(() {
          isConnecting = false;
        });
      }
    }
  }

  Future<void> setSSHInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final user = prefs.getString(AppStrings.spKeyword.username);
    final ip = prefs.getString(AppStrings.spKeyword.ipAddress);

    setState(() {
      sshInfo = '$user@$ip';
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      // mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: isConnecting ? 4 : 0,
          child: isConnecting ? const LinearProgressIndicator() : null,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            color: colorScheme.primaryContainer,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: ListTile(
                    leading: Icon(
                      sshService.isConnected ? Icons.check_circle : Icons.error,
                      color: sshService.isConnected ? Colors.green : Colors.red,
                    ),
                    title: Text(
                      sshService.isConnected
                          ? AppStrings.homePage.carConnected
                          : AppStrings.homePage.carDisconnect,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(sshService.isConnected
                        ? sshInfo
                        : AppStrings.homePage.whenDisconnectPrompt),
                    trailing: ConnectButton(
                      isConnected: sshService.isConnected,
                      isConnecting: isConnecting,
                      onPressed: toggleConnection,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ConnectButton extends StatelessWidget {
  const ConnectButton({
    super.key,
    required this.isConnected,
    required this.onPressed,
    required this.isConnecting,
  });

  final bool isConnected;
  final bool isConnecting;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {

    return FilledButton.icon(
      onPressed: isConnecting ? null : onPressed,
      icon: Icon(
        isConnected ? Icons.link_off : Icons.link,
      ),
      label: Text(isConnected
          ? AppStrings.ssh.disconnect
          : AppStrings.ssh.connect),
    );
  }
}
