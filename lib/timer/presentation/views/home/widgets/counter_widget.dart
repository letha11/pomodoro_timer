import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/timer_counter/timer_counter_bloc.dart';
import 'timer_set_widget.dart';

class CounterWidget extends StatelessWidget {
  const CounterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            BlocBuilder<TimerCounterBloc, TimerCounterState>(
              bloc: context.read<TimerCounterBloc>(),
              builder: (context, state) {
                return Column(
                  children: [
                    Text(
                      state.duration,
                      style:
                          Theme.of(context).textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    Text(
                      state.toString(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 25),
            Wrap(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => context
                      .read<TimerCounterBloc>()
                      .add(TimerCounterStarted()),
                  child: const Text('start'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => context
                      .read<TimerCounterBloc>()
                      .add(TimerCounterPaused()),
                  child: const Text('pause'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => context.read<TimerCounterBloc>().add(
                        TimerCounterResumed(),
                      ),
                  child: const Text('resume'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => context.read<TimerCounterBloc>().add(
                        TimerCounterReset(),
                      ),
                  child: const Text('reset'),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () => context.read<TimerCounterBloc>().add(
                    const TimerCounterTypeChange(TimerType.breakTime),
                  ),
              child: const Text('Change timer type to Break Time'),
            ),
            ElevatedButton(
              onPressed: () => context.read<TimerCounterBloc>().add(
                    const TimerCounterTypeChange(TimerType.pomodoro),
                  ),
              child: const Text('Change timer type to Pomodoro Time'),
            ),

            /// Timer set
            Text(
              'Set Timer',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const TimerSetForm(),
          ],
        ),
      ),
    );
  }
}
