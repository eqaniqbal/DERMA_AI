import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {
  static String _backendUrl = 'http://192.168.18.96:5000';
  static bool _discovered = false;

  static String get backendUrl => _backendUrl;
  static String get scanUrl => '$_backendUrl/api/scan/analyze';
  static String get chatbotUrl => '$_backendUrl/api/chatbot/message';

  // Call this once when app starts
  static Future<void> discoverServer() async {
    if (_discovered) return;

    // Try saved URL first
    final prefs = await SharedPreferences.getInstance();
    final savedUrl = prefs.getString('backend_url');
    if (savedUrl != null) {
      if (await _testUrl(savedUrl)) {
        _backendUrl = savedUrl;
        _discovered = true;
        print('Using saved URL: $_backendUrl');
        return;
      }
    }

    // Get device's local IP to determine subnet
    final interfaces = await NetworkInterface.list();
    String subnet = '192.168.1';

    for (var interface in interfaces) {
      for (var addr in interface.addresses) {
        if (addr.type == InternetAddressType.IPv4 &&
            !addr.isLoopback &&
            addr.address.startsWith('192.168')) {
          final parts = addr.address.split('.');
          subnet = '${parts[0]}.${parts[1]}.${parts[2]}';
          print('Scanning subnet: $subnet.x');
          break;
        }
      }
    }

    // Scan common IPs in parallel
    print('Discovering server on $subnet.x...');
    final futures = <Future>[];

    for (int i = 1; i <= 254; i++) {
      final ip = '$subnet.$i';
      futures.add(_testUrl('http://$ip:5000').then((found) {
        if (found && !_discovered) {
          _discovered = true;
          _backendUrl = 'http://$ip:5000';
          prefs.setString('backend_url', _backendUrl);
          print('Server found at: $_backendUrl');
        }
      }));
    }

    // Wait max 5 seconds for discovery
    await Future.wait(futures).timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        print('Discovery timeout - using default');
        return [];
      },
    );
  }

  static Future<bool> _testUrl(String url) async {
    try {
      final socket = await Socket.connect(
        Uri.parse(url).host,
        5000,
        timeout: const Duration(milliseconds: 300),
      );
      socket.destroy();
      return true;
    } catch (_) {
      return false;
    }
  }

  // Call this to reset discovery (when changing networks)
  static Future<void> resetDiscovery() async {
    _discovered = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('backend_url');
  }
}