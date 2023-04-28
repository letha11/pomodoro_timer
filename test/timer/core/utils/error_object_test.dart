// ignore_for_file: prefer_const_constructors

import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_timer/core/constants.dart';
import 'package:pomodoro_timer/core/exceptions/failures.dart';
import 'package:pomodoro_timer/core/utils/error_object.dart';

void main() {
  late ErrorObject errorObject;

  setUp(() {
    errorObject = ErrorObject();
  });

  group('constructor', () {
    test('should create ErrorObject object with the given message', () {
      final eo = ErrorObject(message: 'dummy');

      expect(
        eo,
        isA<ErrorObject>().having((p0) => p0.message, 'message', 'dummy'),
      );
    });
  });

  group('mapFailureToError', () {
    test(
        'should create ErrorObject with message ${errorMessage['default']} when Failure is not handled by the if\'s',
        () {
      final eo = ErrorObject.mapFailureToError(FormatFailure());

      expect(
        eo,
        isA<ErrorObject>().having((p0) => p0.message, 'message', errorMessage['default']),
      );
    });

    test(
        'should create ErrorObject with message ${errorMessage['default']} when Failure is `UnhandledFailure`',
        () {
      final eo = ErrorObject.mapFailureToError(UnhandledFailure());

      expect(
        eo,
        isA<ErrorObject>().having((p0) => p0.message, 'message', errorMessage['default']),
      );
    });

    test('should create ErrorObject with message ${errorMessage['db']} when Failure is `DBFailure`',
        () {
      final eo = ErrorObject.mapFailureToError(DBFailure());

      expect(
        eo,
        isA<ErrorObject>().having((p0) => p0.message, 'message', errorMessage['db']),
      );
    });
  });
}
