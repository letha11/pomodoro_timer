import 'package:equatable/equatable.dart';

import '../constants.dart';
import '../exceptions/failures.dart';

class ErrorObject extends Equatable {
  final String? message;

  ErrorObject({String? message}) : message = message ?? errorMessage['default'];

  factory ErrorObject.mapFailureToError(Failure f) {
    if (f is UnhandledFailure) {
      return ErrorObject();
    } else if (f is DBFailure) {
      return ErrorObject(message: errorMessage['db']);
    } else {
      return ErrorObject();
    }
  }

  @override
  List<Object?> get props => [message];
}
