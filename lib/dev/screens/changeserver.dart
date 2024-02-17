import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socialtask/utils/constants.dart';

class ChangeServerScreen extends StatefulWidget {
  const ChangeServerScreen({super.key});

  @override
  _ChangeServerScreenState createState() => _ChangeServerScreenState();
}

class _ChangeServerScreenState extends State<ChangeServerScreen> {
  late List<Map<String, dynamic>> servers;
  late Map<String, Duration> responseTimes;

  @override
  void initState() {
    super.initState();
    servers = [];
    responseTimes = {};
    _getServers();
  }

  Future<void> _getServers() async {
    final url = Uri.parse('https://api.npoint.io/c8e4abc483884bbbfcef');
    final response = await http.get(url);
    final jsonData = json.decode(response.body);
    if (jsonData['servers'] != null) {
      setState(() {
        servers = List<Map<String, dynamic>>.from(jsonData['servers']);
      });
      await _checkServers();
    }
  }

  Future<void> _saveSelectedServer(String selectedServer) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedServer', selectedServer);
    setState(() {
      Constants.baseUrl = selectedServer;
    });
  }

  Future<void> _checkServers() async {
    for (var server in servers) {
      final url = server['url'];
      final startTime = DateTime.now();
      try {
        await http.get(Uri.parse('$url/ping'));
        final endTime = DateTime.now();
        final duration = endTime.difference(startTime);
        setState(() {
          responseTimes[url] = duration;
        });
      } catch (error) {
        setState(() {
          responseTimes[url] = Duration.zero;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Server'),
      ),
      body: Center(
        child: servers.isEmpty
            ? const CircularProgressIndicator()
            : ListView.builder(
                itemCount: servers.length,
                itemBuilder: (context, index) {
                  final server = servers[index];
                  final url = server['url'];
                  final responseTime = responseTimes[url];
                  IconData icon =
                      responseTime != null && responseTime.inMilliseconds > 0
                          ? Icons.check_circle
                          : Icons.error;
                  Color color =
                      responseTime != null && responseTime.inMilliseconds > 0
                          ? Colors.green
                          : Colors.red;
                  return ListTile(
                    title: Text(server['name']),
                    subtitle: responseTime != null
                        ? Text(
                            'Response Time: ${responseTime.inMilliseconds} ms')
                        : null,
                    trailing: Icon(icon, color: color),
                    onTap: () {
                      _saveSelectedServer(url);
                    },
                  );
                },
              ),
      ),
    );
  }
}
