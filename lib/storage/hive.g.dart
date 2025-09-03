// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BirthdayAdapter extends TypeAdapter<Birthday> {
  @override
  final int typeId = 0;

  @override
  Birthday read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Birthday(
      name: fields[0] as String,
      birthDate: fields[1] as DateTime,
      alarmDate: fields[2] as DateTime?,
      alarmTimeHour: fields[3] as String?,
      alarmTimeMinute: fields[4] as String?,
      alarmId: fields[5] as String?,
      isReminderEnabled: fields[6] == null ? false : fields[6] as bool,
      profileImagePath: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Birthday obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.birthDate)
      ..writeByte(2)
      ..write(obj.alarmDate)
      ..writeByte(3)
      ..write(obj.alarmTimeHour)
      ..writeByte(4)
      ..write(obj.alarmTimeMinute)
      ..writeByte(5)
      ..write(obj.alarmId)
      ..writeByte(6)
      ..write(obj.isReminderEnabled)
      ..writeByte(7)
      ..write(obj.profileImagePath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BirthdayAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
