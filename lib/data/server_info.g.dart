// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server_info.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ServerInfoAdapter extends TypeAdapter<ServerInfo> {
  @override
  final int typeId = 0;

  @override
  ServerInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ServerInfo()
      ..serverAddress = fields[0] as String
      ..token = fields[1] as String;
  }

  @override
  void write(BinaryWriter writer, ServerInfo obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.serverAddress)
      ..writeByte(1)
      ..write(obj.token);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServerInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
