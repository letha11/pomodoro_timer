import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomodoro_timer/timer/presentation/blocs/setting/setting_bloc.dart';
import 'dart:async';

import '../../../../core/utils/service_locator.dart';
import '../../../../core/utils/time_converter.dart';
import '../../widgets/styled_container.dart';
import 'widgets/title_switch.dart';

// ignore: must_be_immutable
class TimerSettings extends StatelessWidget {
  TimerSettings({
    Key? key,
  }) : super(key: key);

  late int pomodoroTime;
  late int breakTime;
  late int longBreakTime;

  Timer? _debounce;
  bool _snackbarActivated = false;

  final _pomodoroTimeController = TextEditingController(text: '0');
  final _breakTimeController = TextEditingController(text: '0');
  final _longBreakTimeController = TextEditingController(text: '0');

  void _setTimer(BuildContext ctx) {
    ctx.read<SettingBloc>().add(
          SettingSet(
            pomodoroTime: sl<TimeConverter>().minuteToSecond(
              int.parse(_pomodoroTimeController.text),
            ),
            shortBreak: sl<TimeConverter>().minuteToSecond(
              int.parse(_breakTimeController.text),
            ),
            longBreak: sl<TimeConverter>().minuteToSecond(
              int.parse(_longBreakTimeController.text),
            ),
          ),
        );
    if (!_snackbarActivated) {
      _snackbarActivated = true;
      ScaffoldMessenger.of(ctx)
          .showSnackBar(
            SnackBar(
              width: 80,
              duration: const Duration(seconds: 2),
              content: const Center(child: Text("Saved!")),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)),
              elevation: 2,
              behavior: SnackBarBehavior.floating,
            ),
          )
          .closed
          .then((reason) => _snackbarActivated = false);
    }
  }

  _timeForm(BuildContext ctx, String title, TextEditingController controller) {
    return Column(
      children: [
        Text(title, style: Theme.of(ctx).textTheme.bodySmall),
        const SizedBox(height: 5),
        StyledContainer(
          width: 75,
          child: TextFormField(
            controller: controller,
            cursorColor: Colors.black,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,

            onChanged: (val) {
              if (_debounce?.isActive ?? false) _debounce?.cancel();
              _debounce = Timer(const Duration(seconds: 2), () {
                _setTimer(ctx);
              });
            },
            onEditingComplete: () {
              _setTimer(ctx);
            },
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            style: Theme.of(ctx).textTheme.titleSmall?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 11, vertical: 6),
              isDense: true,
            ), //
          ),
        ),
        Text('minutes', style: Theme.of(ctx).textTheme.titleSmall),
      ],
    );
  }

  @override
Widget build(BuildContext context) {
    pomodoroTime = sl<TimeConverter>().secondToMinutes(
        (context.read<SettingBloc>().state as SettingLoaded).timer.pomodoroTime);
    breakTime = sl<TimeConverter>().secondToMinutes(
        (context.read<SettingBloc>().state as SettingLoaded).timer.shortBreak);
    longBreakTime = sl<TimeConverter>().secondToMinutes(
        (context.read<SettingBloc>().state as SettingLoaded).timer.longBreak);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _timeForm(
                  context,
                  'pomodoro',
                  _pomodoroTimeController..text = "$pomodoroTime",
                ),
                _timeForm(
                  context,
                  'shortbreak',
                  _breakTimeController..text = "$breakTime",
                ),
                _timeForm(
                  context,
                  'longbreak',
                  _longBreakTimeController..text = "$longBreakTime",
                )
              ],
            ),
            const SizedBox(height: 16),
            TitleSwitch(
              title: "Pomodoro Sequence",
              initialState: (context.read<SettingBloc>().state as SettingLoaded).timer.pomodoroSequence,
              onToggle: (val) => context.read<SettingBloc>().add(SettingSet(pomodoroSequence: val)),
            ),
          ],
        ),
      ),
    );
  }
}
