import 'package:fpdart/fpdart.dart';
import 'package:x_demo_app/core/core.dart';

typedef FutureEither<T> = Future<Either<Failure, T>>;
typedef FutureEitherVoid = FutureEither<void>;
