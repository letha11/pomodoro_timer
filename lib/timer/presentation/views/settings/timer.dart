import 'package:flutter/material.dart';
import 'package:pomodoro_timer/timer/presentation/widgets/styled_container.dart';

class TimerSettings extends StatelessWidget {
  const TimerSettings({Key? key}) : super(key: key);

  _timeForm(BuildContext ctx, String title, String time) {
    return Column(
      children: [
        Text(title, style: Theme.of(ctx).textTheme.bodySmall),
        const SizedBox(height: 5),
        StyledContainer(
          text: time,
          padding: const EdgeInsets.only(left: 15, right: 15, bottom: 3),
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
                _timeForm(context, 'pomodoro', '25:00'),  
                _timeForm(context, 'break', '05:00'),
                _timeForm(context, 'long break', '10:00'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                  Text('Pomodoro Sequence', style: Theme.of(context).textTheme.bodySmall),

              ],
            ),
            // Container(width: 100, height: 100, color: Colors.blue),
          ],
        ),
      ),
    );
  }
}
