import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:pomodoro_timer/timer/presentation/blocs/timer/timer_bloc.dart';

import 'core/utils/service_locator.dart';
import 'firebase_options.dart';
import 'timer/presentation/views/home/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // initialize hive
  await Hive.initFlutter();

  // initialize service locator
  init();

  // initialize firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Pass all uncaught "fatal" errors from the framework to Crashlytics
  // TODO: uncomment this line to enable crashlytics
  // FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  Widget _build(AsyncSnapshot snapshot) {
    if (snapshot.hasData) {
      return BlocProvider(
        create: (context) => sl<TimerBloc>()..add(TimerGet()),
        child: const HomeScreen(),
      );
    } else {
      return const Scaffold(body: CircularProgressIndicator());
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SafeArea(
        child: FutureBuilder(
          future: sl.allReady(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            return _build(snapshot);
          },
        ),
      ),
    );
  }
}
