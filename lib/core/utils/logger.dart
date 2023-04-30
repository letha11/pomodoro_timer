import 'package:logger/logger.dart';
export 'package:logger/logger.dart';

abstract class ILogger {
  void log(Level level, String message,
      [dynamic error, StackTrace? stackTrace]);
}

class LoggerImpl implements ILogger {
  final Logger _logger;

  /// this makes we can make a Mocked Logger classes when testing
  LoggerImpl({Logger? logger}) : _logger = logger ?? Logger();

  @override
  void log(Level? level, String message, [error, StackTrace? stackTrace]) {
    switch (level) {
      case Level.debug:
        _logger.d("[DEBUG]: $message", error, stackTrace);
        break;
      case Level.info:
        _logger.i("[INFO]: $message", error, stackTrace);
        break;
      case Level.warning:
        _logger.w("[WARNING]: $message", error, stackTrace);
        break;
      case Level.error:
        _logger.e("[ERROR]: $message", error, stackTrace);
        break;
      case Level.wtf:
        _logger.wtf("[FATAL]: $message", error, stackTrace);
        break;
      default:
        _logger.v("[VERBOSE]: $message", error, stackTrace);
    }
  }
}
