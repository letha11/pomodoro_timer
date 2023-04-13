import 'package:json_annotation/json_annotation.dart';

import '../../domain/entity/timer_entity.dart';

part 'timer_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class TimerModel extends TimerEntity {
  /// Will set default pomodoroTime to 25 minutes, and brekaTime 5 minutes
  /// if params not given
  const TimerModel({int? pomodoroTime, int? breakTime})
      : super(pomodoroTime: pomodoroTime ?? 1500, breakTime: breakTime ?? 300);

  factory TimerModel.fromJson(Map<String, dynamic> json) => _$TimerModelFromJson(json);

  Map<String, dynamic> toJson() => _$TimerModelToJson(this);
}
