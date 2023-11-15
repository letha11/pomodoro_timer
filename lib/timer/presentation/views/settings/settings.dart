import 'package:flutter/material.dart';
import 'package:pomodoro_timer/timer/presentation/widgets/styled_container.dart';

import 'sounds.dart';
import 'timer.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final List<String> _tabs = ['Timer', 'Sounds'];
  double heightContainer = 500;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DefaultTabController(
        initialIndex: 0,
        length: _tabs.length,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            centerTitle: true,
            title: Text(
              'Settings',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              children: [
                const SizedBox(
                  height: 15,
                ),
                StyledContainer(
                  child: TabBar(
                    labelStyle: Theme.of(context).textTheme.bodySmall,
                    unselectedLabelColor: Colors.black,
                    unselectedLabelStyle: Theme.of(context).textTheme.bodySmall,
                    indicator: const BoxDecoration(
                      color: Colors.black,
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    overlayColor: MaterialStateProperty.all(Colors.transparent),
                    tabs: _tabs
                        .map(
                          (e) => Tab(
                            text: e,
                          ),
                        )
                        .toList(),
                  ),
                ),
                Flexible(
                  // height: heightContainer,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    child: StyledContainer(
                      child: TabBarView(
                        children: [
                          TimerSettings(),
                          const SoundsSetting(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
