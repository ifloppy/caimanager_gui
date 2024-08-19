import 'dart:convert';

import 'package:caimanager_gui/global.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart';

class ServerInfoPage extends StatefulWidget {
  final int id;
  const ServerInfoPage({super.key, required this.id});

  @override
  State<ServerInfoPage> createState() => _ServerInfoPageState();
}

class _ServerInfoPageState extends State<ServerInfoPage> {
  late String base_url, token;
  List<Map<String, dynamic>> instance_list = [];

  @override
  void initState() {
    super.initState();
    var serverinfo = boxServerInfo.values.toList()[widget.id];
    base_url = serverinfo.serverAddress;
    token = serverinfo.token;
    loadServerInstances();
  }

  Future<void> saveInstance() async {
    final url = Uri.parse('$base_url/api/instances/save');
    final response = await post(
      url,
      headers: {
        'authorization': 'Bearer $token', // Replace with actual token
      },
    );

    if (response.statusCode == 200) {
      // Handle successful save
      print('Instance saved successfully');
    } else {
      // Handle error
      final errorMessage = jsonDecode(response.body)['message'];
      print('Failed to save instance: $errorMessage');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to save instance: $errorMessage'),
      ));
    }
  }

  void loadServerInstances() async {
    try {
      var resp = await get(Uri.parse("$base_url/api/instances"), headers: {
        "authorization": "Bearer $token",
      });

      if (resp.statusCode == 200) {
        setState(() {
          instance_list =
              List<Map<String, dynamic>>.from(jsonDecode(resp.body));
        });
      } else {
        // Handle server errors
        final errorMessage = jsonDecode(resp.body)['message'];
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Server error: $errorMessage'),
        ));
      }
    } catch (e) {
      // Handle network or parsing errors
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(base_url),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              context.goNamed("login");
            },
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.save),
              onPressed: saveInstance,
            ),
          ]),
      body: ListView.builder(
        itemCount: instance_list.length,
        itemBuilder: (context, index) {
          Icon leading;
          if (instance_list[index]["status"] == "Running") {
            leading = Icon(Icons.play_arrow);
          } else {
            leading = Icon(Icons.pause);
          }
          return ListTile(
            title: Text(instance_list[index]["name"]),
            leading: leading,
            onTap: () {
              context.goNamed("instance", pathParameters: {
                "s_id": widget.id.toString(),
                "i_name": instance_list[index]["name"]
              });
            },
            onLongPress: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  TextEditingController pathController =
                      TextEditingController(text: instance_list[index]["path"]);
                  TextEditingController appController =
                      TextEditingController(text: instance_list[index]["app"]);
                  TextEditingController parameterController =
                      TextEditingController(
                          text: instance_list[index]["parameter"].join(" "));
                  TextEditingController stopCommandController =
                      TextEditingController(
                          text: instance_list[index]["stop_command"] ?? "stop");
                  bool autoRun = instance_list[index]["auto_run"];
                  bool autoRestart =
                      instance_list[index]["auto_restart"] ?? false;

                  return StatefulBuilder(
                    builder: (context, setState) {
                      return AlertDialog(
                        title: Text(instance_list[index]["name"]),
                        content: SingleChildScrollView(
                          child: ListBody(
                            children: <Widget>[
                              TextField(
                                controller: pathController,
                                decoration: InputDecoration(labelText: "Path"),
                              ),
                              TextField(
                                controller: appController,
                                decoration: InputDecoration(labelText: "App"),
                              ),
                              TextField(
                                controller: parameterController,
                                decoration:
                                    InputDecoration(labelText: "Parameter"),
                              ),
                              TextField(
                                controller: stopCommandController,
                                decoration:
                                    InputDecoration(labelText: "Stop Command"),
                              ),
                              SwitchListTile(
                                title: Text("Auto Run"),
                                value: autoRun,
                                onChanged: (bool value) {
                                  setState(() {
                                    autoRun = value;
                                  });
                                },
                              ),
                              SwitchListTile(
                                title: Text("Auto Restart"),
                                value: autoRestart,
                                onChanged: (bool value) {
                                  setState(() {
                                    autoRestart = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: Text("Cancel"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: Text("Remove"),
                            onPressed: () async {
                              var instanceName = instance_list[index]["name"];
                              var resp = await delete(
                                Uri.parse(
                                    "$base_url/api/instances/$instanceName"),
                                headers: {
                                  "authorization": "Bearer $token",
                                },
                              );
                              if (resp.statusCode == 200) {
                                // Handle successful save
                              } else {
                                // Handle error
                                final errorMessage =
                                    jsonDecode(resp.body)['message'];
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text('Server error: $errorMessage'),
                                ));
                              }
                              loadServerInstances();
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: Text("Save"),
                            onPressed: () async {
                              var instanceName = instance_list[index]["name"];
                              var resp = await post(
                                Uri.parse(
                                    "$base_url/api/instances/$instanceName"),
                                headers: {
                                  "authorization": "Bearer $token",
                                  "Content-Type": "application/json",
                                },
                                body: jsonEncode({
                                  "name": instanceName,
                                  "path": pathController.text,
                                  "app": appController.text,
                                  "parameter":
                                      parameterController.text.split(" "),
                                  "auto_run": autoRun,
                                  "auto_restart": autoRestart,
                                  "stop_command": stopCommandController.text,
                                }),
                              );
                              if (resp.statusCode == 200) {
                                // Handle successful save
                              } else {
                                // Handle error
                                final errorMessage =
                                    jsonDecode(resp.body)['message'];
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text('Server error: $errorMessage'),
                                ));
                              }
                              loadServerInstances();
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              TextEditingController nameController = TextEditingController();
              TextEditingController pathController = TextEditingController();
              TextEditingController appController = TextEditingController();
              TextEditingController parameterController =
                  TextEditingController();
              TextEditingController stopCommandController =
                  TextEditingController(text: "stop");
              bool autoRun = false;
              bool autoRestart = false;

              return StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    title: Text("New Instance"),
                    content: SingleChildScrollView(
                      child: ListBody(
                        children: <Widget>[
                          TextField(
                            controller: nameController,
                            decoration: InputDecoration(labelText: "Name"),
                          ),
                          TextField(
                            controller: pathController,
                            decoration: InputDecoration(labelText: "Path"),
                          ),
                          TextField(
                            controller: appController,
                            decoration: InputDecoration(labelText: "App"),
                          ),
                          TextField(
                            controller: parameterController,
                            decoration: InputDecoration(labelText: "Parameter"),
                          ),
                          TextField(
                            controller: stopCommandController,
                            decoration:
                                InputDecoration(labelText: "Stop Command"),
                          ),
                          SwitchListTile(
                            title: Text("Auto Run"),
                            value: autoRun,
                            onChanged: (bool value) {
                              setState(() {
                                autoRun = value;
                              });
                            },
                          ),
                          SwitchListTile(
                            title: Text("Auto Restart"),
                            value: autoRestart,
                            onChanged: (bool value) {
                              setState(() {
                                autoRestart = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: Text("Cancel"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: Text("Create"),
                        onPressed: () async {
                          var resp = await put(
                            Uri.parse("$base_url/api/instances/create"),
                            headers: {
                              "authorization": "Bearer $token",
                              "Content-Type": "application/json",
                            },
                            body: jsonEncode({
                              "name": nameController.text,
                              "path": pathController.text,
                              "app": appController.text,
                              "parameter": parameterController.text.split(" "),
                              "auto_run": autoRun,
                              "auto_restart": autoRestart,
                              "stop_command": stopCommandController.text,
                            }),
                          );
                          if (resp.statusCode == 200) {
                            // Handle successful creation
                          } else {
                            // Handle error
                            final errorMessage =
                                jsonDecode(resp.body)['message'];
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Server error: $errorMessage'),
                            ));
                          }
                          loadServerInstances();
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
