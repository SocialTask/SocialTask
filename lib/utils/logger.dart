import 'package:logger/logger.dart';

class CustomLogger {
  final Logger _logger = Logger(
    printer: PrettyPrinter(), // You can customize the log format here
    level: Level
        .debug, // Set the logging level as needed (debug, info, warning, error)
  );

  void logInfo(String message) {
    _logger.i(message);
  }

  void logError(String message) {
    _logger.e(message);
  }
}

final customLogger = CustomLogger();