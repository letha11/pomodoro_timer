import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/adapters.dart';

import 'core/utils/service_locator.dart';
import 'firebase_options.dart';
import 'timer/data/models/setting_hive_model.dart';
import 'timer/presentation/blocs/timer/timer_bloc.dart';
import 'timer/presentation/blocs/timer_counter/timer_counter_bloc.dart';
import 'timer/presentation/views/home/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(SoundSettingModelAdapter());
  Hive.registerAdapter(TimerSettingModelAdapter());
  Hive.registerAdapter(SettingHiveModelAdapter());

  // initialize service locator
  init();

  // initialize firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Pass all uncaught "fatal" errors from the framework to Crashlytics
  // TODO: uncomment this line to enable crashlytics
  // FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // Specifies orientation for the application to portrait only
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

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
        appBarTheme: const AppBarTheme(
          iconTheme: IconThemeData(
            color: Colors.black,
          ),
        ),
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
          titleSmall: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500, // SemiBold
            color: Color(0xFF515151),
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
