import 'package:equatable/equatable.dart';

import '../exceptions/failures.dart';
import '../constants.dart';

class ErrorObject extends Equatable {
  final String? message;

  // const ErrorObject({this.message = errorMessage["default"]!});
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
  // TODO: implement props
  List<Object?> get props => [message];
}
