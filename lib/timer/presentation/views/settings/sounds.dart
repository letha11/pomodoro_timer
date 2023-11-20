import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomodoro_timer/timer/presentation/blocs/setting/setting_bloc.dart';
import 'package:pomodoro_timer/timer/presentation/views/settings/widgets/title_switch.dart';

class SoundsSetting extends StatelessWidget {
  const SoundsSetting({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 12.0),
        child: Column(
          children: [
            TitleSwitch(
              title: "Play Sound",
              onToggle: (val) => context.read<SettingBloc>().add(SettingSet(playSound: val)), 
            ),
          ],
        ),
      ),
    );
  }
}
