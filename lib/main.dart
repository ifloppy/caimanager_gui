import 'dart:io';

import 'package:caimanager_gui/pages/instance.dart';
import 'package:caimanager_gui/pages/login.dart';
import 'package:caimanager_gui/pages/server.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'data/server_info.dart';
import 'global.dart';

void main() async {
  HttpOverrides.global = MyHttpOverrides();
  await Hive.initFlutter();
  Hive.registerAdapter(ServerInfoAdapter());
  boxServerInfo = await Hive.openBox<ServerInfo>('caimanager_server_info');
  runApp(const MainApp());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: GoRouter(routes: [
        GoRoute(
            path: '/', name: "login", builder: (context, state) => LoginPage()),
        GoRoute(
            path: '/:s_id',
            name: 'server',
            builder: (context, state) =>
                ServerInfoPage(id: int.parse(state.pathParameters['s_id']!))),
        GoRoute(
            path: '/:s_id/:i_name',
            name: 'instance',
            builder: (context, state) => InstancePage(
                  server_id: int.parse(state.pathParameters['s_id']!),
                  instance_name: state.pathParameters['i_name']!,
                )),
      ]),
      themeMode: ThemeMode.system,
      theme: ThemeData(
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
