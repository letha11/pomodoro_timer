import 'package:equatable/equatable.dart';

/// Failure
/// Domain Level Failure
abstract class Failure extends Equatable {
  @override
  List<Object?> get props => [];
}

class DBFailure extends Failure {}
