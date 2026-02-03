import 'package:dio/dio.dart';
import 'package:frontend/core/app_logger.dart';
import '../constants.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;
  DioClient._internal();

  late final Dio dio;

  void init() {
    dio = Dio(
      BaseOptions(
        baseUrl: apiBaseUrl,
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          Log.netRequest(
            "→ → → REQUEST [${options.method}] ${options.uri}",
            {'data': options.data, 'headers': options.headers},
          );
          return handler.next(options);
        },
        onResponse: (response, handler) {
          Log.netResponse(
            "← ← ← RESPONSE [${response.statusCode}] ${response.requestOptions.uri}",
            {'data': response.data},
          );
          return handler.next(response);
        },
        onError: (DioException err, handler) {
          Log.netError(
            "!!! ERROR [${err.response?.statusCode ?? 'no response'}] ${err.requestOptions.uri}",
            {
              'type': err.type.toString(),
              'message': err.message,
              'response': err.response?.data,
            },
          );
          return handler.next(err);
        },
      ),
    );
  }
}
