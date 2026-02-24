// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patient_server_id_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PatientsServerIdEntityAdapter
    extends TypeAdapter<PatientsServerIdEntity> {
  @override
  final int typeId = 2;

  @override
  PatientsServerIdEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PatientsServerIdEntity(
      serverType: fields[0] as String,
      patientId: fields[1] as String,
      patientName: fields[2] as String,
      id: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PatientsServerIdEntity obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.serverType)
      ..writeByte(1)
      ..write(obj.patientId)
      ..writeByte(2)
      ..write(obj.patientName)
      ..writeByte(3)
      ..write(obj.id);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PatientsServerIdEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
