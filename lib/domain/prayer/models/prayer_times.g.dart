// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prayer_times.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PrayerTimesAdapter extends TypeAdapter<PrayerTimes> {
  @override
  final int typeId = 2;

  @override
  PrayerTimes read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PrayerTimes(
      fajr: fields[0] as DateTime,
      dhuhr: fields[1] as DateTime,
      asr: fields[2] as DateTime,
      maghrib: fields[3] as DateTime,
      isha: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, PrayerTimes obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.fajr)
      ..writeByte(1)
      ..write(obj.dhuhr)
      ..writeByte(2)
      ..write(obj.asr)
      ..writeByte(3)
      ..write(obj.maghrib)
      ..writeByte(4)
      ..write(obj.isha);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrayerTimesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
