// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'setting_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SettingModel _$SettingModelFromJson(Map<String, dynamic> json) => SettingModel(
      pomodoroSequence: json['pomodoro_sequence'] as bool?,
      playSound: json['play_sound'] as bool?,
    );

Map<String, dynamic> _$SettingModelToJson(SettingModel instance) =>
    <String, dynamic>{
      'pomodoro_sequence': instance.pomodoroSequence,
      'play_sound': instance.playSound,
    };
