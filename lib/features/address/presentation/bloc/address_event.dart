part of 'address_bloc.dart';

sealed class AddressEvent extends Equatable {
  const AddressEvent();

  @override
  List<Object?> get props => [];
}

class AddressListRequested extends AddressEvent {
  const AddressListRequested();
}
