import 'package:hive/hive.dart';

part 'server_info.g.dart';

@HiveType(typeId: 0)
class ServerInfo extends HiveObject {
  @HiveField(0)
  late String serverAddress;

  @HiveField(1)
  late String token;
}
