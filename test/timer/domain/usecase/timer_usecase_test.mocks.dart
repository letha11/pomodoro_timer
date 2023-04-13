// Mocks generated by Mockito 5.4.0 from annotations
// in pomodoro_timer/test/timer/domain/usecase/timer_usecase_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i4;

import 'package:dartz/dartz.dart' as _i2;
import 'package:mockito/mockito.dart' as _i1;
import 'package:pomodoro_timer/core/exceptions/failures.dart' as _i5;
import 'package:pomodoro_timer/core/success.dart' as _i7;
import 'package:pomodoro_timer/timer/domain/entity/timer_entity.dart' as _i6;
import 'package:pomodoro_timer/timer/domain/repository/timer_repository.dart'
    as _i3;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeEither_0<L, R> extends _i1.SmartFake implements _i2.Either<L, R> {
  _FakeEither_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [TimerRepository].
///
/// See the documentation for Mockito's code generation for more information.
class MockTimerRepository extends _i1.Mock implements _i3.TimerRepository {
  @override
  _i4.Future<_i2.Either<_i5.Failure, _i6.TimerEntity>> getTimer() =>
      (super.noSuchMethod(
        Invocation.method(
          #getTimer,
          [],
        ),
        returnValue: _i4.Future<_i2.Either<_i5.Failure, _i6.TimerEntity>>.value(
            _FakeEither_0<_i5.Failure, _i6.TimerEntity>(
          this,
          Invocation.method(
            #getTimer,
            [],
          ),
        )),
        returnValueForMissingStub:
            _i4.Future<_i2.Either<_i5.Failure, _i6.TimerEntity>>.value(
                _FakeEither_0<_i5.Failure, _i6.TimerEntity>(
          this,
          Invocation.method(
            #getTimer,
            [],
          ),
        )),
      ) as _i4.Future<_i2.Either<_i5.Failure, _i6.TimerEntity>>);
  @override
  _i4.Future<_i2.Either<_i5.Failure, _i7.Success>> setTimer({
    int? pomodoroTime,
    int? breakTime,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #setTimer,
          [],
          {
            #pomodoroTime: pomodoroTime,
            #breakTime: breakTime,
          },
        ),
        returnValue: _i4.Future<_i2.Either<_i5.Failure, _i7.Success>>.value(
            _FakeEither_0<_i5.Failure, _i7.Success>(
          this,
          Invocation.method(
            #setTimer,
            [],
            {
              #pomodoroTime: pomodoroTime,
              #breakTime: breakTime,
            },
          ),
        )),
        returnValueForMissingStub:
            _i4.Future<_i2.Either<_i5.Failure, _i7.Success>>.value(
                _FakeEither_0<_i5.Failure, _i7.Success>(
          this,
          Invocation.method(
            #setTimer,
            [],
            {
              #pomodoroTime: pomodoroTime,
              #breakTime: breakTime,
            },
          ),
        )),
      ) as _i4.Future<_i2.Either<_i5.Failure, _i7.Success>>);
}
