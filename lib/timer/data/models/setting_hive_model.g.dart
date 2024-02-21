// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'setting_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SettingHiveModelAdapter extends TypeAdapter<SettingHiveModel> {
  @override
  final int typeId = 0;

  @override
  SettingHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SettingHiveModel(
      timerSetting: fields[0] as TimerSettingModel?,
      soundSetting: fields[1] as SoundSettingModel?,
    );
  }

  @override
  void write(BinaryWriter writer, SettingHiveModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.timerSetting)
      ..writeByte(1)
      ..write(obj.soundSetting);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TimerSettingModelAdapter extends TypeAdapter<TimerSettingModel> {
  @override
  final int typeId = 1;

  @override
  TimerSettingModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TimerSettingModel(
      pomodoroTime: fields[0] as int?,
      shortBreak: fields[1] as int?,
      longBreak: fields[2] as int?,
      pomodoroSequence: fields[3] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, TimerSettingModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.pomodoroTime)
      ..writeByte(1)
      ..write(obj.shortBreak)
      ..writeByte(2)
      ..write(obj.longBreak)
      ..writeByte(3)
      ..write(obj.pomodoroSequence);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimerSettingModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SoundSettingModelAdapter extends TypeAdapter<SoundSettingModel> {
  @override
  final int typeId = 2;

  @override
  SoundSettingModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SoundSettingModel(
      playSound: fields[0] as bool?,
      defaultAudioPath: fields[1] as String?,
      type: fields[2] as String?,
      bytesData: fields[3] as Uint8List?,
      importedFileName: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SoundSettingModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.playSound)
      ..writeByte(1)
      ..write(obj.defaultAudioPath)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.bytesData)
      ..writeByte(4)
      ..write(obj.importedFileName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SoundSettingModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
