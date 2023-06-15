import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/adapters.dart';

import 'core/utils/service_locator.dart';
import 'firebase_options.dart';
import 'timer/presentation/blocs/timer/timer_bloc.dart';
import 'timer/presentation/blocs/timer_counter/timer_counter_bloc.dart';
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
      return MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => sl<TimerBloc>()..add(TimerGet()),
          ),
          BlocProvider(
            create: (context) => sl<TimerCounterBloc>(),
          ),
        ],
        child: const HomeScreen(),
      );
    } else {
      return const Scaffold(body: CircularProgressIndicator());
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: "Darker Grotesque",
        textTheme: const TextTheme(
          bodyLarge: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w600, // SemiBold
            color: Colors.black,
          ),
          bodySmall: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600, // SemiBold
            color: Colors.black,
          ),
        ),
      ),
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
