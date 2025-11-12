part of 'passwords_cubit.dart';

abstract class PasswordsState extends Equatable {
  const PasswordsState();

  @override
  List<Object> get props => [];
}

class PasswordsInitial extends PasswordsState {}

class PasswordsLoading extends PasswordsState {}

class PasswordsLoaded extends PasswordsState {
  final List<PasswordModel> passwords;

  const PasswordsLoaded(this.passwords);

  @override
  List<Object> get props => [passwords];
}

class PasswordsError extends PasswordsState {
  final String message;

  const PasswordsError(this.message);

  @override
  List<Object> get props => [message];
}