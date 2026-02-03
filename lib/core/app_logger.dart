import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Центральный логгер приложения с красивым форматированием
class AppLogger {
  // Один экземпляр PrettyPrinter с разумными настройками
  static final PrettyPrinter _prettyPrinter = PrettyPrinter(
    methodCount: 2, // 2 метода в стеке для обычных логов
    errorMethodCount: 8, // больше для ошибок — удобно отлаживать
    lineLength: 120, // ширина строки
    colors: true, // цвета в консоли (VS Code / Android Studio)
    printEmojis: true, // эмодзи для уровней (очень помогает визуально)
    dateTimeFormat: DateTimeFormat.dateAndTime, // время лога
    noBoxingByDefault: true, // без лишних рамок вокруг сообщений
    // dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart, // если хочешь "HH:mm:ss (от старта)"
    // levelColors: { ... },     // можно кастомизировать цвета уровней
    // levelEmojis: { ... },     // или эмодзи
  );

  // Основной логгер (используется в debug)
  static final Logger _logger = Logger(
    printer: _prettyPrinter,
    level: kDebugMode ? Level.debug : Level.off, // ничего в release по умолчанию
    output: ConsoleOutput(),
    filter: DevelopmentFilter(), // только в debug по умолчанию (можно переопределить)
  );

  // Логгер без стека (для info/warning, чтобы не засорять консоль)
  static final Logger _noStackLogger = Logger(
    printer: PrettyPrinter(methodCount: 0),
    level: kDebugMode ? Level.debug : Level.off,
    output: ConsoleOutput(),
  );

  // Минимальный принтер для сетевых логов: без рамок, без цветов, без стека
  // Выводит только уровень, заголовок и полезную нагрузку (payload).

  // Отдельный логгер для сетевых сообщений — компактный и чистый
  static final Logger _netLogger = Logger(
    printer: _MinimalPrinter(),
    level: kDebugMode ? Level.debug : Level.off,
    output: ConsoleOutput(),
  );

  // ──────────────────────────────────────────────
  // Методы с поддержкой error + stackTrace

  static void t(dynamic message, [Object? error, StackTrace? stackTrace]) =>
      _logger.t(message, error: error, stackTrace: stackTrace);

  static void d(dynamic message, [Object? error, StackTrace? stackTrace]) =>
      _logger.d(message, error: error, stackTrace: stackTrace);

  static void i(dynamic message, [Object? error, StackTrace? stackTrace]) =>
      _noStackLogger.i(message, error: error, stackTrace: stackTrace);

  static void w(dynamic message, [Object? error, StackTrace? stackTrace]) =>
      _noStackLogger.w(message, error: error, stackTrace: stackTrace);

  static void e(dynamic message, [Object? error, StackTrace? stackTrace]) =>
      _logger.e(message, error: error, stackTrace: stackTrace);

  static void f(dynamic message, [Object? error, StackTrace? stackTrace]) =>
      _logger.f(message, error: error, stackTrace: stackTrace); // fatal / wtf

  // Компактные методы для логирования запросов/ответов (используются в Dio)
  static void netRequest(String title, dynamic payload) => _netLogger.d('$title\n$payload');

  static void netResponse(String title, dynamic payload) => _netLogger.i('$title\n$payload');

  static void netError(String title, dynamic payload) => _netLogger.e('$title\n$payload');

  // Удобный универсальный метод
  static void log(
    dynamic message, {
    Level level = Level.info,
    Object? error,
    StackTrace? stackTrace,
  }) {
    switch (level) {
      case Level.trace:
        t(message, error, stackTrace);
        break;
      case Level.debug:
        d(message, error, stackTrace);
        break;
      case Level.info:
        i(message, error, stackTrace);
        break;
      case Level.warning:
        w(message, error, stackTrace);
        break;
      case Level.error:
        e(message, error, stackTrace);
        break;
      case Level.fatal: // или wtf
        f(message, error, stackTrace);
        break;
      default:
        i(message, error, stackTrace);
    }
  }

  // Пример: логировать объект красиво (JSON-like)
  static void json(dynamic object, {Level level = Level.debug}) {
    _logger.log(level, object);
  }
}

// Глобальный алиас — пиши просто Log.i(...), Log.e(...) и т.д.
typedef Log = AppLogger;

class _MinimalPrinter extends LogPrinter {
  @override
  List<String> log(LogEvent event) {
    final level = event.level.toString().split('.').last.toUpperCase();
    final message = event.message;
    final error = event.error;
    final buffer = StringBuffer();
    buffer.write('$level: $message');
    if (error != null) {
      buffer.write('\n$error');
    }
    return [buffer.toString()];
  }
}
