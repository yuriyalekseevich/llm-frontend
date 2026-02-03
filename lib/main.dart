import 'package:flutter/material.dart';
import 'core/dio_client.dart';
import 'core/app_logger.dart';
import 'presentation/screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Init network client
  DioClient().init();

  // Filter noisy framework assertion floods (e.g. repeated
  // 'debugFrameWasSentToEngine' messages) while keeping other
  // errors visible. We log a compact entry via AppLogger and
  // avoid dumping huge repeated stacks to the console.
  FlutterError.onError = (FlutterErrorDetails details) {
    final message = details.exceptionAsString();
    if (message.contains('debugFrameWasSentToEngine')) {
      AppLogger.d('Filtered framework assertion: ${details.exception}');
      // Optionally forward to zone or remote error reporting here.
    } else {
      // For other errors, preserve default behavior
      FlutterError.presentError(details);
    }
  };

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LLM Practicum',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
    );
  }
}
