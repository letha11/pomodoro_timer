import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/service_locator.dart';
import '../../blocs/timer/timer_bloc.dart';
import '../../blocs/timer_counter/timer_counter_bloc.dart';
import 'widgets/counter_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            BlocConsumer<TimerBloc, TimerState>(
              bloc: context.read<TimerBloc>(),
              listener: (context, state) {
                if (state is TimerFailed) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.error.message!),
                    ),
                  );
                }
              },
              buildWhen: (previous, current) {
                if (previous is TimerLoaded && current is TimerLoaded) {
                  if (previous.timer != current.timer) {
                    return true;
                  } else {
                    return false;
                  }
                } else if (current is TimerLoaded) {
                  return true;
                } else if (current is TimerFailed) {
                  return true;
                } else {
                  return false;
                }
              },
              builder: (context, state) {
                if (state is TimerLoaded) {
                  // Success
                  /// Will create a `TimerCounterBloc` instance everytime `TimerLoaded` state get emitted
                  // final timerCounterBloc =
                  //     sl<TimerCounterBloc>(param1: state.timer);

                  /// Using BlocProvider.value instead of BlocProvider because
                  /// I need to update the `TimerCounterBloc` depending the `state.timer`
                  /// so when this rebuilt, it will create a new `TimerCounterBloc` with the updated `state.timer`
                  return BlocProvider<TimerCounterBloc>.value(
                    value: sl<TimerCounterBloc>(param1: state.timer),
                    child: const CounterWidget(),
                  );
                } else if (state is TimerFailed) {
                  // Failure
                  return const Text('0');
                } else {
                  // Loading
                  return const CircularProgressIndicator();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
