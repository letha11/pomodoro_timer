import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/timer/timer_bloc.dart';
import '../../blocs/timer_counter/timer_counter_bloc.dart';
import 'widgets/counter_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey,
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
                // } else if (state is TimerLoaded) {
                //   context.read<TimerCounterBloc>().add(
                //         TimerCounterChange(state.timer),
                //       );
                // }
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
                  // print('rebuilt TimerLoaded');
                  // Success
                  /// Will create a `TimerCounterBloc` instance everytime `TimerLoaded` state get emitted

                  // timerCounterBloc = sl<TimerCounterBloc>(param1: state.timer);
                  /// Using BlocProvider.value instead of BlocProvider because
                  /// I need to update the `TimerCounterBloc` depending the `state.timer`
                  /// so when this rebuilt, it will create a new `TimerCounterBloc` with the updated `state.timer`
                  return BlocProvider<TimerCounterBloc>.value(
                    value: context.read<TimerCounterBloc>(),
                    child: const Home(),
                  );
                  // return BlocProvider<TimerCounterBloc>.value(
                  //   // create: (c) => sl<TimerCounterBloc>(param1: state.timer),
                  //   value: sl<TimerCounterBloc>(param1: state.timer),
                  //   child: const CounterWidget(),
                  // );
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

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _activeIndex = 0;
  List<String> _tabs = ["pomodoro", "break", "long break"];

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _tabs.map((e) {
                int index = _tabs.indexOf(e);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _activeIndex = index;
                    });
                  },
                  child: Padding(
                    padding: EdgeInsets.only(right: index != (_tabs.length - 1) ? 20.0 : 0.0),
                    child: StyledContainer(
                      active: _activeIndex == index,
                      text: e,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 33),
            StyledContainer(
              width: 125,
              text: "25:00",
              textStyle: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class StyledContainer extends StatelessWidget {
  const StyledContainer({
    super.key,
    this.text,
    this.child,
    this.width,
    this.textStyle,
    this.active = false,
  }) : assert(text != null ? child == null : child != null);

  final bool active;
  final double? width;
  final Widget? child;
  final String? text;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? 100, // TODO: find a way to make it responsive or smthg
      padding: const EdgeInsets.only(bottom: 5, top: 3),
      decoration: BoxDecoration(
        color: active ? Colors.black : Colors.white,
        boxShadow: [
          BoxShadow(
            color: active ? Colors.white : Colors.black, // active
            offset: const Offset(3, 3),
          ),
        ],
        border: Border.all(
          // color: Colors.black,
          color: active ? Colors.white : Colors.black,
          width: 1,
        ),
      ),
      child: Center(
        child: child ??
            Text(
              text!,
              style: textStyle ?? Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: active ? Colors.white : Colors.black,
                  ),
            ),
      ),
    );
  }
}

