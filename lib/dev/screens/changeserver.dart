import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socialtask/utils/constants.dart';

class ChangeServerScreen extends StatefulWidget {
  const ChangeServerScreen({Key? key})
      : super(key: key ?? const Key('ChangeServer'));

  @override
  _ChangeServerScreenState createState() => _ChangeServerScreenState();
}

class _ChangeServerScreenState extends State<ChangeServerScreen> {
  List<String> servers = [];

  @override
  void initState() {
    super.initState();
    _getServers();
  }

  Future<void> _getServers() async {
    final url = Uri.parse('https://api.npoint.io/c8e4abc483884bbbfcef');
    try {
      final response = await http.get(url);
      final jsonData = json.decode(response.body);
      if (jsonData['servers'] != null) {
        setState(() {
          servers = List<String>.from(jsonData['servers']);
        });
      }
    } catch (error) {
      print('Error fetching servers: $error');
    }
  }

  Future<void> _saveSelectedServer(String selectedServer) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedServer', selectedServer);
    setState(() {
      Constants.baseUrl = selectedServer;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change Server'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Center(
        child: servers.isEmpty
            ? CircularProgressIndicator()
            : ListView.builder(
                itemCount: servers.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(servers[index]),
                    onTap: () {
                      _saveSelectedServer(servers[index]);
                      print('Selected server: ${servers[index]}');
                    },
                  );
                },
              ),
      ),
    );
  }
}
