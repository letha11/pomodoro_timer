import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../blocs/timer/timer_bloc.dart';
import '../../blocs/timer_counter/timer_counter_bloc.dart';
import '../../widgets/styled_container.dart';
import '../settings/settings.dart';

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
              } else if (state is TimerLoaded && state.error != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.error!.message!),
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is TimerLoaded) {
                return const Home();
              } else if (state is TimerFailed) {
                // Failure
                return const Text('0');
              } else {
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
              TimerTypeWidget(),
              const SizedBox(height: 33),
              BlocBuilder<TimerCounterBloc, TimerCounterState>(
                builder: (context, state) => StyledContainer(
                  width: 125,
                  text: state.duration,
                  textStyle: Theme.of(context).textTheme.bodyLarge,
                  padding: const EdgeInsets.only(bottom: 5),
                ),
              ),
              const SizedBox(height: 33),
              BlocBuilder<TimerCounterBloc, TimerCounterState>(
                builder: (context, state) => _actionsWidget(state),
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
            onTap: () => Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (_) => BlocProvider.value(
                  value: BlocProvider.of<TimerBloc>(context),
                  child: const SettingsScreen(),
                ),
              ),
            ),
            child: SvgPicture.asset(
              'assets/images/setting.svg',
              width: 24,
            ),
          ),
        ),
      ],
    );
  }

  Widget _actionsWidget(TimerCounterState state) {
    void play() => context.read<TimerCounterBloc>().add(TimerCounterStarted());
    void resume() =>
        context.read<TimerCounterBloc>().add(TimerCounterResumed());
    void pause() => context.read<TimerCounterBloc>().add(TimerCounterPaused());
    void reset() => context.read<TimerCounterBloc>().add(TimerCounterReset());

    Widget actionWrapper(String asset, void Function() onTap) =>
        StyledContainer(
          padding: const EdgeInsets.all(15),
          borderRadius: 50,
          onTap: onTap,
          child: SvgPicture.asset(
            asset,
            width: 30,
          ),
        );

    if (state is TimerCounterPause) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          actionWrapper("assets/images/play.svg", resume),
          const SizedBox(width: 32),
          actionWrapper("assets/images/stop.svg", reset),
        ],
      );
    } else if (state is TimerCounterInProgress) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          actionWrapper("assets/images/pause.svg", pause),
          const SizedBox(width: 32),
          actionWrapper("assets/images/stop.svg", reset),
        ],
      );
    } else if (state is TimerCounterInitial) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          actionWrapper("assets/images/play.svg", play),
        ],
      );
    } else {
      return const SizedBox();
    }
  }
}

class TimerTypeWidget extends StatelessWidget {
  final List<TimerType> _tabs = [
    TimerType.pomodoro,
    TimerType.breakTime,
    TimerType.longBreak
  ];

  TimerTypeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    TimerType type = context.select<TimerCounterBloc, TimerType>((b) => b.type);
    int activeIndex = _tabs.indexOf(type);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _tabs.map((e) {
        int index = _tabs.indexOf(e);
        return Padding(
          padding:
              EdgeInsets.only(right: index != (_tabs.length - 1) ? 20.0 : 0.0),
          child: StyledContainer(
            padding:
                const EdgeInsets.only(left: 15, right: 15, bottom: 5, top: 3),
            active: activeIndex == index,
            text: e.toShortString(),
            onTap: () =>
                context.read<TimerCounterBloc>().add(TimerCounterTypeChange(e)),
          ),
        );
      }).toList(),
    );
  }
}
