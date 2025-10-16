import 'package:equatable/equatable.dart';

/// Base UseCase interface - all use cases must implement this
/// Type: Return type, Params: Parameter object type
abstract class UseCase<Type, Params> {
  Future<Type> call(Params params);
}

/// For use cases with no parameters
class NoParams extends Equatable {
  @override
  List<Object> get props => [];
}
