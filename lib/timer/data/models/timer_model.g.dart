// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timer_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TimerModel _$TimerModelFromJson(Map<String, dynamic> json) => TimerModel(
      pomodoroTime: json['pomodoro_time'] as int?,
      breakTime: json['break_time'] as int?,
      longBreak: json['long_break'] as int?,
    );

Map<String, dynamic> _$TimerModelToJson(TimerModel instance) =>
    <String, dynamic>{
      'pomodoro_time': instance.pomodoroTime,
      'break_time': instance.breakTime,
      'long_break': instance.longBreak,
    };
