import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:pomodoro_timer/core/utils/image_utils.dart';
import 'package:pomodoro_timer/timer/presentation/blocs/setting/setting_bloc.dart';

import 'core/utils/service_locator.dart';
import 'firebase_options.dart';
import 'timer/data/models/setting_hive_model.dart';
import 'timer/presentation/blocs/timer_counter/timer_counter_bloc.dart';
import 'timer/presentation/views/home/home.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

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
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // Specifies orientation for the application to portrait only
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ImageUtils.precacheSvgImages();
    ImageUtils.precacheImages(context);
  }

  Widget _build(AsyncSnapshot snapshot) {
    if (snapshot.hasData) {
      return MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => sl<SettingBloc>()..add(SettingGet()),
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
