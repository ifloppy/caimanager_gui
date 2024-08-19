import 'package:caimanager_gui/global.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:xterm/xterm.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class InstancePage extends StatefulWidget {
  final int server_id;
  final String instance_name;

  const InstancePage(
      {super.key, required this.server_id, required this.instance_name});

  @override
  _InstancePageState createState() => _InstancePageState();
}

class _InstancePageState extends State<InstancePage> {
  late String base_url, token;
  late WebSocketChannel channel;
  final Terminal terminal = Terminal();
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    var serverinfo = boxServerInfo.values.toList()[widget.server_id];
    base_url = serverinfo.serverAddress;
    token = serverinfo.token;

    _initializeWebSocket();
  }

  void _initializeWebSocket() async {
    try {
      // Establish WebSocket connection
      final ws_base_url = base_url.replaceFirst('http', 'ws');
      channel = WebSocketChannel.connect(
        Uri.parse(
            '$ws_base_url/api/instances/log_reader/${widget.instance_name}'),
      );

      channel.sink.add("Bearer $token");

      // Listen for log messages
      channel.stream.listen(
        (message) {
          setState(() {
            terminal.write('$message\n');
          });
        },
        onError: (error) {
          // Handle WebSocket error with detailed information
          String errorMessage =
              'WebSocket error: ${error.runtimeType} - ${error.toString()}';
          _showSnackBar(errorMessage);
        },
        onDone: () {
          // Handle WebSocket closure
          _showSnackBar('WebSocket closed');
        },
      );
    } catch (e) {
      _showSnackBar(
          'Failed to establish WebSocket connection: ${e.runtimeType} - ${e.toString()}');
    }
  }

  @override
  void dispose() {
    try {
      channel.sink.close();
    } catch (e) {
      // Handle the exception, e.g., log it or show a message to the user
      print('Error closing WebSocket: $e');
    }
    _controller.dispose();
    super.dispose();
  }

  void _handleInput(String input) {
    if (input.isNotEmpty) {
      setState(() {
        terminal.write('$input\n');
      });
      _controller.clear();
    }
  }

  Future<void> _startInstance() async {
    try {
      final response = await http.post(
        Uri.parse('$base_url/api/instances/start/${widget.instance_name}'),
        headers: {'Authorization': 'Bearer $token'},
      );
      _showSnackBar(response.statusCode == 200
          ? 'Instance started successfully'
          : 'Failed to start instance');
    } catch (e) {
      _showSnackBar('Failed to start instance: $e');
    }
  }

  Future<void> _stopInstance() async {
    try {
      final response = await http.post(
        Uri.parse('$base_url/api/instances/stop/${widget.instance_name}'),
        headers: {'Authorization': 'Bearer $token'},
      );
      _showSnackBar(response.statusCode == 200
          ? 'Instance stopped successfully'
          : 'Failed to stop instance');
    } catch (e) {
      _showSnackBar('Failed to stop instance: $e');
    }
  }

  Future<void> _haltInstance() async {
    try {
      final response = await http.post(
        Uri.parse('$base_url/api/instances/halt/${widget.instance_name}'),
        headers: {'Authorization': 'Bearer $token'},
      );
      _showSnackBar(response.statusCode == 200
          ? 'Instance halted successfully'
          : 'Failed to halt instance');
    } catch (e) {
      _showSnackBar('Failed to halt instance: $e');
    }
  }

  Future<void> _sendCommand(String command) async {
    try {
      final response = await http.post(
        Uri.parse('$base_url/api/instances/execute/${widget.instance_name}'),
        headers: {'Authorization': 'Bearer $token'},
        body: command,
      );
      if (response.statusCode != 200) {
        _showSnackBar('Failed to execute command');
      }
    } catch (e) {
      _showSnackBar('Failed to execute command: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('InstancePage'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            context.goNamed("server",
                pathParameters: {"s_id": widget.server_id.toString()});
          },
        ),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _startInstance,
                child: Text('Start'),
              ),
              ElevatedButton(
                onPressed: _stopInstance,
                child: Text('Stop'),
              ),
              ElevatedButton(
                onPressed: _haltInstance,
                child: Text('Halt'),
              ),
            ],
          ),
          Expanded(
            child:
                TerminalView(terminal, alwaysShowCursor: false, readOnly: true),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controller,
              onSubmitted: (input) {
                _handleInput(input);
                _sendCommand(input);
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter command',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
