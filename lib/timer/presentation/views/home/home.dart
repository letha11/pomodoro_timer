import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../blocs/timer/timer_bloc.dart';
import '../../blocs/timer_counter/timer_counter_bloc.dart';
import '../../widgets/styled_container.dart';
// import 'widgets/counter_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey,
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/bg.png"),
              fit: BoxFit.fill,
            ),
          ),
          child: BlocConsumer<TimerBloc, TimerState>(
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
  final List<String> _tabs = ["pomodoro", "break", "long break"];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
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

                  return Padding(
                    padding: EdgeInsets.only(
                        right: index != (_tabs.length - 1) ? 20.0 : 0.0),
                    child: StyledContainer(
                      padding: const EdgeInsets.only(
                          left: 15, right: 15, bottom: 5, top: 3),
                      active: _activeIndex == index,
                      text: e,
                      onTap: () {
                        setState(() {
                          _activeIndex = index;
                        });
                      },
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
              const SizedBox(height: 33),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  StyledContainer(
                    padding: const EdgeInsets.all(15),
                    borderRadius: 50,
                    onTap: () {},
                    child: SvgPicture.asset(
                      'assets/images/pause.svg',
                      width: 30,
                    ),
                  ),
                  const SizedBox(width: 32),
                  StyledContainer(
                    padding: const EdgeInsets.all(15),
                    borderRadius: 50,
                    onTap: () {},
                    child: SvgPicture.asset(
                      'assets/images/play.svg',
                      width: 30,
                    ),
                  ),
                  const SizedBox(width: 32),
                  StyledContainer(
                    padding: const EdgeInsets.all(15),
                    borderRadius: 50,
                    onTap: () {},
                    child: SvgPicture.asset(
                      'assets/images/stop.svg',
                      width: 30,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          top: 25,
          right: 25,
          child: StyledContainer(
            padding: const EdgeInsets.all(5),
            borderRadius: 50,
            onTap: () {},
            child: SvgPicture.asset(
              'assets/images/setting.svg',
              width: 24,
            ),
          ),
        ),
      ],
    );
  }
}

