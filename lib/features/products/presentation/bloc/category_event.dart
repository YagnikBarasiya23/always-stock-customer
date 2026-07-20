part of 'category_bloc.dart';

sealed class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object?> get props => [];
}

class CategoryListRequested extends CategoryEvent {
  const CategoryListRequested();
}

/// Creates when [id] is null, updates otherwise.
class CategoryUpsertRequested extends CategoryEvent {
  const CategoryUpsertRequested({this.id, required this.name, this.nameTranslations});

  final String? id;
  final String name;
  final Map<String, String>? nameTranslations;

  @override
  List<Object?> get props => [id, name, nameTranslations];
}
