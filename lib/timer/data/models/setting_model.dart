import 'package:json_annotation/json_annotation.dart';

import '../../domain/entity/setting_entity.dart';

part 'setting_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class SettingModel extends SettingEntity{
  const SettingModel({bool? pomodoroSequence, bool? playSound})
      : super(
          pomodoroSequence: pomodoroSequence ?? false,
          playSound: playSound ?? false,
        );

  factory SettingModel.fromJson(Map<String, dynamic> json) => _$SettingModelFromJson(json);

  Map<String, dynamic> toJson() => _$SettingModelToJson(this);
}