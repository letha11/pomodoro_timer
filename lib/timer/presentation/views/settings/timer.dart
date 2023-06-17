import 'package:flutter/material.dart';

import '../../widgets/styled_container.dart';
import 'widgets/title_switch.dart';

class TimerSettings extends StatelessWidget {
  TimerSettings({Key? key}) : super(key: key);

  final _pomodoroTimeController = TextEditingController(text: '25');
  final _breakTimeController = TextEditingController(text: '5');
  final _longBreakTimeController = TextEditingController(text: '15');

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
            style: Theme.of(ctx).textTheme.titleSmall?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 11, vertical: 6),
              isDense: true,
            ),
          ),
        ),
        Text('minutes', style: Theme.of(ctx).textTheme.titleSmall),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _timeForm(context, 'pomodoro', _pomodoroTimeController),
                _timeForm(context, 'break', _breakTimeController),
                _timeForm(context, 'long break', _longBreakTimeController),
              ],
            ),
            const SizedBox(height: 16),
            TitleSwitch(
              title: "Pomodoro Sequence",
              onToggle: (val) => print(val),
            ),
          ],
        ),
      ),
    );
  }
}
