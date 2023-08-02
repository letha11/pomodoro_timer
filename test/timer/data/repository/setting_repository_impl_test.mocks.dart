// Mocks generated by Mockito 5.4.0 from annotations
// in pomodoro_timer/test/timer/data/repository/setting_repository_impl_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:hive/hive.dart' as _i2;
import 'package:mockito/mockito.dart' as _i1;
import 'package:pomodoro_timer/timer/data/datasource/local/setting_repository_db.dart'
    as _i4;
import 'package:pomodoro_timer/timer/data/models/setting_model.dart' as _i3;

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

class _FakeBox_0<E> extends _i1.SmartFake implements _i2.Box<E> {
  _FakeBox_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeSettingModel_1 extends _i1.SmartFake implements _i3.SettingModel {
  _FakeSettingModel_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [SettingRepositoryHiveDB].
///
/// See the documentation for Mockito's code generation for more information.
class MockSettingRepositoryHiveDB extends _i1.Mock
    implements _i4.SettingRepositoryHiveDB {
  @override
  _i2.Box<dynamic> get box => (super.noSuchMethod(
        Invocation.getter(#box),
        returnValue: _FakeBox_0<dynamic>(
          this,
          Invocation.getter(#box),
        ),
        returnValueForMissingStub: _FakeBox_0<dynamic>(
          this,
          Invocation.getter(#box),
        ),
      ) as _i2.Box<dynamic>);
  @override
  set box(_i2.Box<dynamic>? _box) => super.noSuchMethod(
        Invocation.setter(
          #box,
          _box,
        ),
        returnValueForMissingStub: null,
      );
  @override
  _i3.SettingModel get() => (super.noSuchMethod(
        Invocation.method(
          #get,
          [],
        ),
        returnValue: _FakeSettingModel_1(
          this,
          Invocation.method(
            #get,
            [],
          ),
        ),
        returnValueForMissingStub: _FakeSettingModel_1(
          this,
          Invocation.method(
            #get,
            [],
          ),
        ),
      ) as _i3.SettingModel);
  @override
  void store({
    bool? pomodoroSequence,
    bool? playSound,
  }) =>
      super.noSuchMethod(
        Invocation.method(
          #store,
          [],
          {
            #pomodoroSequence: pomodoroSequence,
            #playSound: playSound,
          },
        ),
        returnValueForMissingStub: null,
      );
}
