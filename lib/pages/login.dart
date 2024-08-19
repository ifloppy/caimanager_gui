import 'package:caimanager_gui/main.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '/data/server_info.dart';
import 'package:caimanager_gui/global.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late List<ServerInfo> serverList = [];

  @override
  void initState() {
    super.initState();
    loadServerInfo();
  }

  void loadServerInfo() {
    setState(() {
      serverList = boxServerInfo.values.toList();
      print(serverList);
    });
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController inputServerAddress = new TextEditingController();
    TextEditingController inputServerToken = new TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: const Text('$VersionInfo'),
      ),
      body: ListView.builder(
        itemCount: serverList.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(serverList[index].serverAddress),
            onTap: () {
              // Try to enter the app
              context.goNamed("server",
                  pathParameters: {"s_id": index.toString()});
            },
            onLongPress: () {
              //Edit the configuration
              showDialog(
                context: context,
                builder: (context) {
                  inputServerAddress.text = serverList[index].serverAddress;
                  inputServerToken.text = serverList[index].token;
                  return AlertDialog(
                    title: Text('Edit Server Configuration'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Server address",
                          ),
                          controller: inputServerAddress,
                        ),
                        SizedBox(height: 10),
                        TextField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Token",
                          ),
                          controller: inputServerToken,
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          boxServerInfo.delete(index);
                          loadServerInfo();
                        },
                        child: Text('Delete'),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          serverList[index].serverAddress =
                              inputServerAddress.text;
                          serverList[index].token = inputServerToken.text;
                          await serverList[index].save();
                          loadServerInfo();
                        },
                        child: Text('Save'),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          // Implement server configuration addition here
          showDialog(
            context: context,
            builder: (context) {
              inputServerToken.clear;
              inputServerAddress.clear;
              return AlertDialog(
                title: Text('Add Server Configuration'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Server address",
                      ),
                      controller: inputServerAddress,
                    ),
                    SizedBox(height: 10),
                    TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Token",
                      ),
                      controller: inputServerToken,
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () async {
                      // Add server configuration logic here
                      Navigator.of(context).pop();
                      var config = ServerInfo()
                        ..serverAddress = inputServerAddress.text
                        ..token = inputServerToken.text;
                      await boxServerInfo.add(config);
                      loadServerInfo();
                    },
                    child: Text('Add'),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
