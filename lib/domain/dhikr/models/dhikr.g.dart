// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dhikr.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DhikrAdapter extends TypeAdapter<Dhikr> {
  @override
  final int typeId = 0;

  @override
  Dhikr read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Dhikr(
      id: fields[0] as String,
      userId: fields[1] as String,
      name: fields[2] as String,
      targetCount: fields[3] as int,
      currentCount: fields[4] as int,
      day: fields[5] as DateTime,
      isCompleted: fields[6] as bool,
      createdAt: fields[7] as DateTime,
      lastUpdatedAt: fields[8] as DateTime,
      isSynced: fields[9] as bool,
      isDeleted: fields[10] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Dhikr obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.targetCount)
      ..writeByte(4)
      ..write(obj.currentCount)
      ..writeByte(5)
      ..write(obj.day)
      ..writeByte(6)
      ..write(obj.isCompleted)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.lastUpdatedAt)
      ..writeByte(9)
      ..write(obj.isSynced)
      ..writeByte(10)
      ..write(obj.isDeleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DhikrAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
