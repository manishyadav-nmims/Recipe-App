import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class NetworkLoggerInterceptor extends Interceptor {
  static const int _maxLineWidth = 90;

  @override
  void onRequest(
      RequestOptions options,
      RequestInterceptorHandler handler,
      ) {
    _printBoxed('Request ║ ${options.method}');
    _printLine('║  ${options.baseUrl}${options.path}');
    _printDivider();

    _printSectionHeader('Headers');
    options.headers.forEach((key, value) {
      _printLine('║ $key: $value');
    });
    _printDivider();

    if (options.data != null) {
      _printSectionHeader('Body');
      _prettyPrintJson(options.data);
      _printDivider();
    }

    handler.next(options);
  }

  @override
  void onResponse(
      Response response,
      ResponseInterceptorHandler handler,
      ) {
    _printBoxed(
      'Response ║ ${response.requestOptions.method} '
          '║ Status: ${response.statusCode} ${response.statusMessage}',
    );
    _printLine(
      '║  ${response.requestOptions.baseUrl}${response.requestOptions.path}',
    );
    _printDivider();

    _printSectionHeader('Headers');
    response.headers.map.forEach((key, value) {
      _printLine('║ $key: $value');
    });
    _printDivider();

    _printSectionHeader('Body');
    _prettyPrintJson(response.data);
    _printDivider();

    handler.next(response);
  }

  @override
  void onError(
      DioException err,
      ErrorInterceptorHandler handler,
      ) {
    _printBoxed(
      'Error ║ ${err.requestOptions.method} '
          '║ Status: ${err.response?.statusCode}',
    );
    _printLine(
      '║  ${err.requestOptions.baseUrl}${err.requestOptions.path}',
    );
    _printDivider();

    _printSectionHeader('Error Message');
    _printLine('║ ${err.message}');
    _printDivider();

    if (err.response?.data != null) {
      _printSectionHeader('Error Body');
      _prettyPrintJson(err.response?.data);
      _printDivider();
    }

    handler.next(err);
  }

  // ──────────────────────────────────────────────
  // Helpers
  // ──────────────────────────────────────────────

  void _prettyPrintJson(dynamic data) {
    try {
      final encoder = const JsonEncoder.withIndent('  ');
      final jsonString = encoder.convert(data);
      jsonString.split('\n').forEach((line) {
        _printLine('║ $line');
      });
    } catch (_) {
      _printLine('║ $data');
    }
  }

  void _printBoxed(String message) {
    debugPrint('╔╣ $message');
  }

  void _printDivider() {
    debugPrint('╚══════════════════════════════════════════════════════════════════════════════════════════╝');
  }

  void _printSectionHeader(String title) {
    debugPrint('╔ $title');
  }

  void _printLine(String line) {
    debugPrint(line.length > _maxLineWidth
        ? line.substring(0, _maxLineWidth)
        : line);
  }
}